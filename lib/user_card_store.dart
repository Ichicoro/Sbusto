import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:scryfall_api/scryfall_api.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UserCard {
  final int id;
  final String setCode;
  final String collectorNumber;
  final bool foil;
  final DateTime foundAt;

  const UserCard({
    required this.id,
    required this.setCode,
    required this.collectorNumber,
    this.foil = false,
    required this.foundAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "setCode": setCode,
      "collectorNumber": collectorNumber,
      "foil": foil,
      "foundAt": foundAt.toIso8601String(),
    };
  }
}

class UserCardStoreModel extends ChangeNotifier {
  final List<UserCard> _cards = [];
  List<UserCard> get cards => _cards;

  Database? _database;

  Future<Database> get db async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  final dbPath = getDatabasesPath();

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), "user_cards.db"),
      onCreate: (db, version) {
        return db.execute("""
CREATE TABLE user_cards (
    id INTEGER PRIMARY KEY, 
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

  void addCardFromMtgCard(MtgCard card) async {
    var client = await db;
    final userCard = UserCard(
      id:
          (Sqflite.firstIntValue(
                await client.rawQuery("SELECT MAX(id) FROM user_cards"),
              ) ??
              0) +
          1,
      setCode: card.set,
      collectorNumber: card.collectorNumber,
      foundAt: DateTime.now(),
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
}
