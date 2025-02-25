import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbusto/libs/rotation_three_d_effect.dart';
import 'package:sbusto/card_data_store.dart';
import 'package:sbusto/user_card_store.dart';
import 'package:sbusto/utils.dart';
import 'package:scryfall_api/scryfall_api.dart' show MtgCard;
// import 'package:scryfall_api/scryfall_api.dart';

enum UnboxingStatus { idle, loading, unpacking, unpacked }

class DebugUnboxView extends StatefulWidget {
  const DebugUnboxView({super.key});

  @override
  DebugUnboxViewState createState() => DebugUnboxViewState();
}

class DebugUnboxViewState extends State<DebugUnboxView> {
  List<BoosterCard> cards = [];
  UnboxingStatus status = UnboxingStatus.idle;
  int unboxingCardPosition = 0;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Consumer2<CardDataStoreModel, UserCardStoreModel>(
      builder: (_, cardDataStore, userCardsStore, __) {
        if (status == UnboxingStatus.idle) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  child:
                      status == UnboxingStatus.idle
                          ? Text("Unbox a booster")
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.onSecondary,
                                ),
                              ),
                              Text("Loading..."),
                            ],
                          ),
                  onPressed: () async {
                    setState(() {
                      status = UnboxingStatus.loading;
                    });
                    final booster = cardDataStore.unpackBooster(
                      AvailableBooster.otjSetBooster,
                    );
                    // Preload all images
                    for (final card in booster) {
                      await precacheImage(
                        CachedNetworkImageProvider(
                          card.card.imageUris?.png.toString() ?? "",
                        ),
                        context,
                      );
                    }
                    setState(() {
                      cards = booster;
                      status = UnboxingStatus.unpacking;
                    });
                  },
                ),
              ],
            ),
          );
        } else if (status == UnboxingStatus.loading) {
          return Center(
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [CircularProgressIndicator(), Text("Loading...")],
            ),
          );
        } else if (status == UnboxingStatus.unpacking) {
          final remainingCards = cards.skip(unboxingCardPosition).toList();
          return Center(
            child: Container(
              margin: EdgeInsets.all(15),
              child: DuringUnboxCardView(
                card: remainingCards.first,
                onTap: () async {
                  print("Unboxing card");
                  setState(() {
                    unboxingCardPosition++;
                    if (unboxingCardPosition >= cards.length) {
                      status = UnboxingStatus.unpacked;
                      unboxingCardPosition = 0;
                    }
                  });
                },
              ),
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 20,
                children: [
                  FilledButton.tonal(
                    child: Text("Save unboxed cards!"),
                    onPressed: () {
                      userCardsStore.addCardsFromBooster(cards);
                      setState(() {
                        status = UnboxingStatus.idle;
                      });
                    },
                  ),
                  GridView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 15,
                    ),
                    children: [
                      for (final card in cards)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(19),
                              child: Container(
                                foregroundDecoration:
                                    card.isFoil
                                        ? foilDecoration(
                                          alignment: Alignment.center,
                                        )
                                        : null,
                                child: CachedNetworkImage(
                                  imageUrl:
                                      card.card.imageUris?.png.toString() ?? "",
                                  fadeInDuration: Duration.zero,
                                  fadeOutDuration: Duration.zero,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  // for (final card in cards) DebugCardView(card: card.card),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class DuringUnboxCardView extends StatefulWidget {
  final BoosterCard card;
  final GestureTapCallback? onTap;

  const DuringUnboxCardView({super.key, required this.card, this.onTap});

  @override
  State<DuringUnboxCardView> createState() => DuringUnboxCardViewState();
}

class DuringUnboxCardViewState extends State<DuringUnboxCardView> {
  Offset desiredPosition = Offset(0, 0);

  Image tryGetCardImage(MtgCard card) {
    try {
      return Image.network(card.imageUris?.png.toString() ?? "");
    } catch (ex) {
      return Image.asset("assets/mtg_card_back.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: (details) {
        // print("Pan update: ${details.delta}");
        // setState(() {
        //   desiredPosition += details.delta;
        //   print("Desired position: $desiredPosition");
        // });
      },
      // onPanEnd: (details) => print("Pan end: ${details.velocity}"),
      child: Rotation3DEffect.limitedReturnsInPlace(
        child: (offset) {
          print(offset);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Container(
                      foregroundDecoration:
                          widget.card.isFoil
                              ? foilDecoration(
                                alignment: offsetToAlignment(
                                  offset,
                                  constraints.biggest / 5,
                                ),
                              )
                              : null,
                      child: CachedNetworkImage(
                        imageUrl:
                            widget.card.card.imageUris?.png.toString() ?? "",
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
