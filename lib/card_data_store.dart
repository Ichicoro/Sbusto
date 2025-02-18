import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scryfall_api/scryfall_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:collection/collection.dart';

class CardDataStoreModel extends ChangeNotifier {
  ScryfallApiClient client = ScryfallApiClient();
  List<MtgCard>? _catalog;
  List<MtgSet>? _sets;
  List<MtgCard>? get catalog => _catalog;
  List<MtgSet>? get sets => _sets;
  bool isLoading = false;
  bool _areCardsCached = false;
  bool get areCardsCached => _areCardsCached;

  static List<String> activeSets = ["AFR", "OTJ"];

  Future<bool> checkCardCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("cards") && prefs.containsKey("sets");
  }

  CardDataStoreModel() {
    checkCardCache().then((value) {
      _areCardsCached = value;
      notifyListeners();
    });
  }

  MtgCard? getCardBySetAndCollector(String set, int collectorNumber) {
    return _catalog?.firstWhereOrNull(
      (element) =>
          element.set == set &&
          element.collectorNumber == collectorNumber.toString(),
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
        final response = await client.searchCards(
          "game:paper (${activeSets.map((e) => "set:$e").join(" OR ")})",
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
    _catalog = catalog;
    _sets = sets;
    if (wasEmpty) {
      _saveCatalogToPrefs();
      _saveSetsToPrefs();
    }
    notifyListeners();
  }
}
