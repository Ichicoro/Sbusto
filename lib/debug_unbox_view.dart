import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbusto/card_data_store.dart';
import 'package:sbusto/debug_card_view.dart';
import 'package:sbusto/user_card_store.dart';
import 'package:scryfall_api/scryfall_api.dart';

class DebugUnboxView extends StatefulWidget {
  const DebugUnboxView({super.key});

  @override
  DebugUnboxViewState createState() => DebugUnboxViewState();
}

class DebugUnboxViewState extends State<DebugUnboxView> {
  List<BoosterCard> cards = [];

  @override
  Widget build(BuildContext context) {
    return Consumer2<CardDataStoreModel, UserCardStoreModel>(
      builder: (_, cardDataStore, userCardsStore, __) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Text("DebugUnboxView"),
              FilledButton(
                onPressed: () {
                  print("Starting unpack");
                  final unboxed = cardDataStore.unpackBooster(
                    AvailableBooster.otjSetBooster,
                  );
                  userCardsStore.addCardsFromBooster(unboxed);
                  setState(() {
                    cards = unboxed;
                  });
                },
                child: Text("prova"),
              ),
              Container(
                child: GridView(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.72,
                  ),
                  children: [
                    for (final card in cards) ...[
                      Card(
                        child: Stack(
                          children: [
                            Ink.image(
                              image: NetworkImage(
                                card.card.imageUris?.small.toString() ?? "",
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  print(
                                    "Tapped on ${card.card.name} (isFoil: ${card.isFoil})",
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return DebugCardView(card: card.card);
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
              ),
            ],
          ),
        );
      },
    );
  }
}
