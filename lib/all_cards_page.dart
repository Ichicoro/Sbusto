import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbusto/card_data_store.dart';
import 'package:sbusto/debug_card_view.dart';
import 'package:sbusto/debug_unbox_view.dart';
import 'package:sbusto/libs/bouncing_button.dart';
import 'package:sbusto/user_card_store.dart';
import 'package:sbusto/utils.dart';
import 'package:scryfall_api/scryfall_api.dart';

class AllCardsPage extends StatefulWidget {
  const AllCardsPage({super.key});

  @override
  State<AllCardsPage> createState() => _AllCardsPageState();
}

class _AllCardsPageState extends State<AllCardsPage> {
  CachedNetworkImage tryGettingImage(MtgCard card) {
    return CachedNetworkImage(imageUrl: card.imageUris?.small.toString() ?? "");
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Consumer2<CardDataStoreModel, UserCardStoreModel>(
      builder: (_, cardStore, userStore, __) {
        if (cardStore.catalog == null) {
          if (cardStore.isLoading) {
            return Center(
              child: Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), Text('Loading...')],
              ),
            );
          } else {
            return Center();
          }
        }

        return ListView(
          children: [
            for (var set in cardStore.sets!) ...[
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${set.name} (${set.code.toUpperCase()})"),
                    GridView(
                      shrinkWrap: true,
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: cardAspectRatio,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                      ),
                      children:
                          cardStore.catalog!
                              .where((card) => card.setId == set.id)
                              .map((card) {
                                final image = tryGettingImage(card);

                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Bouncing(
                                      onPressed: () {
                                        showCardPopup(
                                          context,
                                          BoosterCard(card: card),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                                    child: Image(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          imageUrl:
                                              card.imageUris?.png.toString() ??
                                              "",
                                          fadeInDuration: Duration.zero,
                                          fadeOutDuration: Duration.zero,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              })
                              .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
