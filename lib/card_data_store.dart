import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scryfall_api/scryfall_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> serializeCard(MtgCard card) {
  return {
    'arena_id': card.arenaId,
    'mtgo_id': card.mtgoId,
    'mtgo_foil_id': card.mtgoFoilId,
    'multiverse_ids': card.multiverseIds,
    'tcgplayer_id': card.tcgplayerId,
    'tcgplyer_etched_id': card.tcgplyerEtchedId,
    'cardmarket_id': card.cardmarketId,
    'oracle_id': card.oracleId,
    'prints_search_uri': '${card.printsSearchUri}',
    'rulings_uri': '${card.rulingsUri}',
    'scryfall_uri': '${card.scryfallUri}',
    'all_parts': card.allParts,
    'card_faces': card.cardFaces,
    'color_identity': card.colorIdentity.map((e) => e.toString()).toList(),
    'color_indicator': card.colorIndicator?.map((e) => e.toString()).toList(),
    'edhrec_rank': card.edhrecRank,
    'hand_modifier': card.handModifier,
    'life_modifier': card.lifeModifier,
    'mana_cost': card.manaCost,
    'oracle_text': card.oracleText,
    'produced_mana': card.producedMana?.map((e) => e.toString()).toList(),
    'type_line': card.typeLine,
    'artist_ids': card.artistIds,
    'attraction_lights': card.attractionLights,
    'border_color': card.borderColor.name,
    'card_back_id': card.cardBackId,
    'collector_number': card.collectorNumber,
    'content_warning': card.contentWarning,
    'flavor_name': card.flavorName,
    'flavor_text': card.flavorText,
    'frame_effects': card.frameEffects,
    'full_art': card.fullArt,
    'highres_image': card.highresImage,
    'illustration_id': card.illustrationId,
    'image_status': card.imageStatus.toString(),
    // 'image_uris': card.imageUris,
    'printed_name': card.printedName,
    'printed_text': card.printedText,
    'printed_type_line': card.printedTypeLine,
    'promo_type': card.promoType,
    // 'purchase_uris': card.purchaseUris,
    // 'related_uris': card.relatedUris,
    'released_at': card.releasedAt,
    'scryfall_set_uri': '${card.scryfallSetUri}',
    'set_name': card.setName,
    'set_search_uri': '${card.setSearchUri}',
    'set_type': card.setType,
    'set_uri': '${card.setUri}',
    'set_id': card.setId,
    'story_spotlight': card.storySpotlight,
    'variation_of': card.variationOf,
    'security_stamp': card.securityStamp,
  };
}

class CardDataStoreModel extends ChangeNotifier {
  ScryfallApiClient client = ScryfallApiClient();
  List<MtgCard>? _catalog;
  List<MtgCard>? get catalog => _catalog;
  bool isLoading = false;

  void _saveCatalogToPrefs() async {
    if (_catalog == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final List<String> json =
        (_catalog?.map((item) => jsonEncode(serializeCard(item))).toList())!;
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
