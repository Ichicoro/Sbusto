import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sbusto/card_data_store.dart';
import 'package:scryfall_api/scryfall_api.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

enum UserCardFoilness { nonFoil, foil, both }

class UserCard {
  final String id;
  final String setCode;
  final String collectorNumber;
  final bool foil;
  final DateTime foundAt;
  MtgCard? cardData;

  UserCard({
    required this.id,
    required this.setCode,
    required this.collectorNumber,
    this.foil = false,
    required this.foundAt,
    this.cardData,
  });

  factory UserCard.fromMap(Map<String, dynamic> map) {
    return UserCard(
      id: map["id"] as String,
      setCode: map["setCode"] as String,
      collectorNumber: map["collectorNumber"] as String,
      foil: map["foil"] == 1,
      foundAt: DateTime.parse(map["foundAt"] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "setCode": setCode,
      "collectorNumber": collectorNumber,
      "foil": foil ? 1 : 0,
      "foundAt": foundAt.toIso8601String(),
    };
  }
}

class UserCardStoreModel extends ChangeNotifier {
  final List<UserCard> _cards = [];
  List<UserCard> get cards => _cards;
  CardDataStoreModel cardDataStore;

  List<UserCard> get cardsWithoutDupes {
    return _cards.fold<List<UserCard>>([], (previousValue, element) {
      if (previousValue.any(
        (e) =>
            e.setCode == element.setCode &&
            e.collectorNumber == element.collectorNumber,
      )) {
        return previousValue;
      }
      return [...previousValue, element];
    });
  }

  Uuid uuid = Uuid();

  Database? _database;

  Future<Database> get db async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  UserCardStoreModel({required this.cardDataStore}) {
    // this.cardDataStore.addListener()
    db.then((client) {
      client.query("user_cards").then((value) {
        _cards.addAll(
          value.map((e) {
            return UserCard.fromMap(e);
          }),
        );
        for (final card in _cards) {
          card.cardData = cardDataStore.getCardBySetAndCollector(
            card.setCode,
            card.collectorNumber,
          );
        }
        notifyListeners();
      });
    });
    cardDataStore.addListener(() {
      for (final card in _cards) {
        card.cardData = cardDataStore.getCardBySetAndCollector(
          card.setCode,
          card.collectorNumber,
        );
      }
      notifyListeners();
    });
  }

  final dbPath = getDatabasesPath();

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), "user_cards.db"),
      version: 1,
      onCreate: (db, version) {
        return db.execute("""
CREATE TABLE user_cards (
    id TEXT PRIMARY KEY, 
    setCode TEXT NOT NULL,
    collectorNumber TEXT NOT NULL,
    foil INTEGER NOT NULL CHECK (foil IN (0,1)),
    foundAt INTEGER NOT NULL
);

CREATE INDEX idx_user_cards_set ON user_cards(setCode);
CREATE INDEX idx_user_cards_collector ON user_cards(collectorNumber);
""");
      },
    );
  }

  int countMtgCardInCollection(MtgCard card) {
    return _cards
        .where(
          (element) =>
              element.setCode == card.set &&
              element.collectorNumber == card.collectorNumber.toString() &&
              element.foil == card.foil,
        )
        .length;
  }

  void addCardFromMtgCard(MtgCard card, {bool isFoil = false}) async {
    var client = await db;
    final userCard = UserCard(
      id: uuid.v4(),
      setCode: card.set,
      collectorNumber: card.collectorNumber,
      foil: isFoil,
      foundAt: DateTime.now(),
      cardData: card,
    );
    _cards.add(userCard);
    client.insert("user_cards", userCard.toMap());
    notifyListeners();
  }

  void removeCardFromMtgCard(MtgCard card) async {
    var client = await db;
    var cardToRemove = _cards.firstWhereOrNull(
      (element) =>
          element.setCode == card.set &&
          element.collectorNumber == card.collectorNumber.toString() &&
          element.foil == card.foil,
    );
    if (cardToRemove != null) {
      _cards.remove(cardToRemove);
      client.delete(
        "user_cards",
        where: "id = ?",
        whereArgs: [cardToRemove.id],
      );
      notifyListeners();
    }
  }

  void addCard(UserCard card) async {
    var client = await db;
    card.cardData = cardDataStore.getCardBySetAndCollector(
      card.setCode,
      card.collectorNumber,
    );
    _cards.add(card);
    client.insert("user_cards", card.toMap());
    notifyListeners();
  }

  void removeCard(UserCard card) async {
    var client = await db;
    _cards.remove(card);
    client.delete("user_cards", where: "id = ?", whereArgs: [card.id]);
    notifyListeners();
  }

  int getCardCount(
    UserCard card, {
    UserCardFoilness foilness = UserCardFoilness.both,
  }) {
    return _cards
        .where(
          (element) =>
              element.setCode == card.setCode &&
              element.collectorNumber == card.collectorNumber &&
              (foilness == UserCardFoilness.both
                  ? element.foil == card.foil
                  : (foilness == UserCardFoilness.foil
                      ? element.foil
                      : !element.foil)),
        )
        .length;
  }

  void addCardsFromBooster(List<BoosterCard> cards) {
    for (var card in cards) {
      print("adding to collection ${card.card.name}");
      addCardFromMtgCard(card.card, isFoil: card.isFoil);
    }
    notifyListeners();
  }
}
