import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbusto/card_data_store.dart';
import 'package:sbusto/debug_card_view.dart';
import 'package:sbusto/user_card_store.dart';

class AllCardsPage extends StatefulWidget {
  const AllCardsPage({super.key});

  @override
  State<AllCardsPage> createState() => _AllCardsPageState();
}

class _AllCardsPageState extends State<AllCardsPage> {
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
                        childAspectRatio: 0.72,
                      ),
                      children: [
                        for (final card in cardStore.catalog!.where(
                          (card) => card.setId == set.id,
                        )) ...[
                          Card(
                            child: Stack(
                              children: [
                                Ink.image(
                                  image: NetworkImage(
                                    card.imageUris?.small.toString() ?? "",
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      print("Tapped on ${card.name}");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return DebugCardView(card: card);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
