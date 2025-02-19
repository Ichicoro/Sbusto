import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sbusto/user_card_store.dart';
import 'package:scryfall_api/scryfall_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:collection/collection.dart';

enum AvailableBooster { otjSetBooster }

class BoosterCard {
  final MtgCard card;
  final bool isFoil;

  BoosterCard({required this.card, this.isFoil = false});
}

class CardDataStoreModel extends ChangeNotifier {
  ScryfallApiClient client = ScryfallApiClient();
  List<MtgCard>? _catalog;
  List<MtgSet>? _sets;
  List<MtgCard>? get catalog => _catalog;
  List<MtgSet>? get sets => _sets;
  bool isLoading = false;
  bool hasLoaded = false;
  bool _areCardsCached = false;
  bool get areCardsCached => _areCardsCached;

  static List<String> activeSets = ["OTJ", "OTP"];

  CardDataStoreModel() {
    Future.delayed(Duration.zero, () {
      checkCardCache().then((value) {
        _areCardsCached = value;
        notifyListeners();
      });
      loadData();
    });
  }

  Future<bool> checkCardCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("cards") && prefs.containsKey("sets");
  }

  MtgCard? getCardBySetAndCollector(String set, String collectorNumber) {
    return _catalog?.firstWhereOrNull(
      (element) =>
          element.set == set && element.collectorNumber == collectorNumber,
    );
  }

  void _saveCatalogToPrefs() async {
    if (_catalog == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final List<String> json =
        (_catalog?.map((item) => jsonEncode(item.toJson())))!.toList();
    prefs.setStringList("cards", json);
  }

  Future<List<MtgCard>?> _loadCatalogFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? json = prefs.getStringList("cards");
    if (json == null) {
      return null;
    }
    try {
      final result =
          json.map((item) => MtgCard.fromJson(jsonDecode(item))).toList();
      return result;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void _saveSetsToPrefs() async {
    if (_sets == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final List<String> json =
        (_sets?.map((item) => jsonEncode(item.toJson())))!.toList();
    prefs.setStringList("sets", json);
  }

  Future<List<MtgSet>?> _loadSetsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? json = prefs.getStringList("sets");
    if (json == null) {
      return null;
    }
    try {
      final result =
          json.map((item) => MtgSet.fromJson(jsonDecode(item))).toList();
      return result;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void clearCatalogFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("cards");
    prefs.remove("sets");
    _areCardsCached = false;
    notifyListeners();
  }

  void loadData() async {
    // final String response = await rootBundle.loadString('assets/db.json');
    // final data = await json.decode(response);
    if (hasLoaded) {
      return;
    }

    isLoading = true;
    notifyListeners();

    _catalog = await _loadCatalogFromPrefs();
    _sets = await _loadSetsFromPrefs();
    bool wasEmpty = _catalog == null || _sets == null;

    if (wasEmpty) {
      bool isFinished = false;
      int idx = 0;

      // Load cards
      while (!isFinished) {
        print("loading data page $idx");
        final response = await client.searchCards(
          "game:paper unique:prints (${activeSets.map((e) => "set:$e").join(" OR ")})",
          page: idx++,
        );
        final catalog = response.data;
        _catalog ??= List<MtgCard>.empty(growable: true);
        _catalog?.addAll(catalog);
        if (!response.hasMore) {
          isFinished = true;
        }
      }

      for (var set in activeSets) {
        final response = await client.getSetByCode(set);
        _sets ??= List<MtgSet>.empty(growable: true);
        _sets?.add(response);
      }
    }

    // _catalog?.forEach((element) {
    //   print(element.toString());
    // });

    isLoading = false;
    hasLoaded = true;
    _catalog = catalog;
    _sets = sets;
    if (wasEmpty) {
      _saveCatalogToPrefs();
      _saveSetsToPrefs();
    }
    print("Loaded ${_catalog?.length} cards");
    print("Loaded ${_sets?.length} sets");
    notifyListeners();
  }

  List<MtgCard> getRandomCardsFromSet(
    String setCode, {
    int? amount = 1,
    Rarity? rarity,
    bool? foil,
    bool? land,
  }) {
    final List<MtgCard> result = [];
    final List<MtgCard> cards =
        _catalog!
            .where((element) {
              return element.set == setCode &&
                  (rarity == null || element.rarity == rarity) &&
                  (foil == null || element.foil == foil);
            })
            .toList()
            .shuffled();

    for (int i = 0; i < amount!; i++) {
      result.add(cards[i]);
    }
    return [];
  }

  List<BoosterCard> unpackBooster(AvailableBooster booster) {
    if (_catalog == null || _catalog!.isEmpty) {
      return [];
    }
    var rng = Random();
    // final List<MtgCard> result = [];
    List<MtgCard> cards =
        _catalog!.where((element) => element.set == "otj").toList();

    final List<MtgCard> commons =
        cards
            .where(
              (element) =>
                  element.rarity == Rarity.common &&
                  !element.typeLine.contains("Land"),
            )
            .shuffled()
            .take(7) // should be 6 + 1 that can be the list
            .toList();

    final List<MtgCard> uncommons =
        cards
            .where(
              (element) =>
                  element.rarity == Rarity.uncommon &&
                  !element.typeLine.contains("Land"),
            )
            .shuffled()
            .take(3)
            .toList();

    final MtgCard randomAnyRarity =
        cards
            .where((element) => !element.typeLine.contains("Land"))
            .shuffled()
            .first;

    final rareOrMythic =
        cards
            .where(
              (element) =>
                  (element.rarity == Rarity.rare ||
                      element.rarity == Rarity.mythic) &&
                  !element.typeLine.contains("Land"),
            )
            .shuffled()
            .first;

    final bool breakingNewsIsRareOrMythic = rng.nextInt(3) == 0;
    final breakingNews =
        _catalog!
            .where(
              (element) =>
                  element.set == "otp" &&
                  element.borderColor == BorderColor.borderless &&
                  (!breakingNewsIsRareOrMythic ||
                      (element.rarity == Rarity.rare ||
                          element.rarity == Rarity.mythic)),
            )
            .shuffled()
            .first;

    final traditionalFoil =
        cards
            .where(
              (element) => element.foil && !element.typeLine.contains("Land"),
            )
            .shuffled()
            .first;

    print("Commons: ${commons.map((e) => e.name)}");
    print("Uncommons: ${uncommons.map((e) => e.name)}");
    print("randomAnyRarity: ${randomAnyRarity.name}");
    print(
      "breakingNews: ${breakingNews.name}, (should be rare/mythic? -> $breakingNewsIsRareOrMythic)",
    );
    print("rareOrMythic: ${rareOrMythic.name}");
    print("traditionalFoil: ${traditionalFoil.name}");

    final List<BoosterCard> drops = [
      ...commons.map((e) => BoosterCard(card: e)),
      ...uncommons.map((e) => BoosterCard(card: e)),
      BoosterCard(card: randomAnyRarity),
      BoosterCard(card: rareOrMythic),
      BoosterCard(card: breakingNews),
      BoosterCard(card: traditionalFoil, isFoil: true),
    ];

    for (final drop in drops) {
      print("Dropped: ${drop.card.name} (isFoil: ${drop.isFoil})");
    }

    // final List<MtgCard> result = [
    //   ...commons,
    //   ...uncommons,
    //   randomAnyRarity,
    //   rareOrMythic,
    //   breakingNews,
    //   traditionalFoil,
    // ];

    // print("Result: ${result.map((e) => e.name)}");

    return drops;
  }
}
