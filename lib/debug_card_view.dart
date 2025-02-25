import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbusto/libs/rotation_three_d_effect.dart';
import 'package:sbusto/card_data_store.dart';
import 'package:sbusto/user_card_store.dart';
import 'package:scryfall_api/scryfall_api.dart';

class DebugCardView extends StatelessWidget {
  final MtgCard card;

  const DebugCardView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Consumer2<CardDataStoreModel, UserCardStoreModel>(
      builder: (_, cardStore, userCardStore, __) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
            backgroundColor: theme.colorScheme.inversePrimary,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Container(
                padding: EdgeInsets.all(25),
                child: Rotation3DEffect.limitedReturnsInPlace(
                  returnInPlaceDuration: Duration(milliseconds: 150),
                  child:
                      (offset) => ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: CachedNetworkImage(
                          imageUrl: card.imageUris?.png.toString() ?? "",
                          placeholder:
                              (context, url) => Stack(
                                children: [
                                  Image.asset("assets/mtg_card_back.png"),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [CircularProgressIndicator()],
                                  ),
                                ],
                              ),
                        ),
                      ),
                ),
              ),
              Text(card.name),
              Text(card.oracleText ?? ""),
            ],
          ),
        );
      },
    );
  }
}
