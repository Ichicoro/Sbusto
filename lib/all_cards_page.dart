import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbusto/card_data_store.dart';
import 'package:sbusto/debug_card_view.dart';
import 'package:sbusto/user_card_store.dart';
import 'package:scryfall_api/scryfall_api.dart';

class AllCardsPage extends StatefulWidget {
  const AllCardsPage({super.key});

  @override
  State<AllCardsPage> createState() => _AllCardsPageState();
}

class _AllCardsPageState extends State<AllCardsPage> {
  CachedNetworkImage tryGettingImage(MtgCard card) {
    // try {
    return CachedNetworkImage(imageUrl: card.imageUris?.small.toString() ?? "");
    // } catch (ex) {
    // return Image.asset("assets/mtg_card_back.png");
    // }
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
            return Center(
              child: SizedBox(
                width: 300,
                height: 150,
                child: Card(
                  elevation: 0,
                  child: Column(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("No cards loaded", style: theme.textTheme.bodyLarge),
                      Column(
                        children: [
                          TextButton(
                            child: Text(
                              "Load cards (from ${cardStore.areCardsCached ? 'cache' : 'network'})",
                            ),
                            onPressed: () {
                              cardStore.loadData();
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              cardStore.clearCatalogFromPrefs();
                            },
                            child: Text("Reset cache"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
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
                    Text(
                      "${set.name} (${set.code.toUpperCase()})",
                      style: theme.textTheme.titleMedium,
                    ),
                    GridView(
                      shrinkWrap: true,
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.7475,
                      ),
                      children:
                          cardStore.catalog!
                              .where((card) => card.setId == set.id)
                              .map((card) {
                                final image = tryGettingImage(card);

                                return Card(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Stack(
                                      children: [
                                        // FadeInImage(
                                        //   imageErrorBuilder:
                                        //       (context, error, stackTrace) =>
                                        //           Image.asset(
                                        //             "assets/mtg_card_back.png",
                                        //           ),
                                        //   placeholder: AssetImage(
                                        //     "assets/mtg_card_back.png",
                                        //   ),
                                        //   image: image.image,
                                        // ),
                                        CachedNetworkImage(
                                          imageUrl:
                                              card.imageUris?.small
                                                  .toString() ??
                                              "",
                                          placeholder:
                                              (context, url) => Image.asset(
                                                "assets/mtg_card_back.png",
                                              ),
                                        ),
                                        Ink(
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            onTap: () {
                                              print("Tapped on ${card.name}");
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return DebugCardView(
                                                      card: card,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
