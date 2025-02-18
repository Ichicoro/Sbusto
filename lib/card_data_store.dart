import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scryfall_api/scryfall_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardDataStoreModel extends ChangeNotifier {
  ScryfallApiClient client = ScryfallApiClient();
  List<MtgCard>? _catalog;
  List<MtgCard>? get catalog => _catalog;
  bool isLoading = false;
  bool _areCardsCached = false;
  bool get areCardsCached => _areCardsCached;

  Future<bool> checkCardCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("cards");
  }

  CardDataStoreModel() {
    checkCardCache().then((value) {
      _areCardsCached = value;
      // notifyListeners();
    });
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

  void clearCatalogFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("cards");
  }

  void loadCards() async {
    // final String response = await rootBundle.loadString('assets/db.json');
    // final data = await json.decode(response);

    isLoading = true;
    notifyListeners();

    _catalog = await _loadCatalogFromPrefs();
    bool wasEmpty = _catalog == null;

    if (wasEmpty) {
      bool isFinished = false;
      int idx = 0;
      while (!isFinished) {
        final response = await client.searchCards("set:AFR", page: idx++);
        final catalog = response.data;
        _catalog ??= List<MtgCard>.empty(growable: true);
        _catalog?.addAll(catalog);
        if (!response.hasMore) {
          isFinished = true;
        }
      }
    }

    _catalog?.forEach((element) {
      print(element.toString());
    });

    isLoading = false;
    _catalog = catalog;
    if (wasEmpty) {
      _saveCatalogToPrefs();
    }
    notifyListeners();
  }
}
