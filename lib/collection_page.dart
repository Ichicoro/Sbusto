import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbusto/card_data_store.dart' show BoosterCard;
import 'package:sbusto/debug_card_view.dart';
import 'package:sbusto/libs/bouncing_button.dart';
// import 'package:sbusto/card_data_store.dart';
import 'package:sbusto/user_card_store.dart';
import 'package:sbusto/utils.dart';

class CollectionPageView extends StatefulWidget {
  const CollectionPageView({super.key});

  @override
  State<CollectionPageView> createState() => _CollectionPageViewState();
}

class _CollectionPageViewState extends State<CollectionPageView> {
  @override
  Widget build(BuildContext context) {
    final userCollectionStore = Provider.of<UserCardStoreModel>(
      context,
      listen: true,
    );

    print(userCollectionStore.cards.length);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                "Your collection: ${userCollectionStore.cards.length} cards",
              ),
              GridView(
                shrinkWrap: true,
                primary: false,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: cardAspectRatio,
                ),
                children: [
                  for (final userCard in userCollectionStore.cardsWithoutDupes
                      .sorted(
                        (a, b) =>
                            a.cardData?.name.compareTo(
                              b.cardData?.name ?? "",
                            ) ??
                            0,
                      )) ...[UserCardView(userCard: userCard)],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserCardView extends StatelessWidget {
  final UserCard userCard;
  final String size;

  const UserCardView({super.key, required this.userCard, this.size = "normal"});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userCollectionStore = Provider.of<UserCardStoreModel>(
      context,
      listen: true,
    );

    final inCollectionCountNonFoil = userCollectionStore.getCardCount(
      userCard,
      foilness: UserCardFoilness.nonFoil,
    );
    final inCollectionCountFoil = userCollectionStore.getCardCount(
      userCard,
      foilness: UserCardFoilness.foil,
    );

    return Bouncing(
      onPressed: () {
        showCardPopup(
          context,
          BoosterCard(card: userCard.cardData!, isFoil: false),
        );
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
              imageUrl: userCard.cardData?.imageUris?.normal.toString() ?? "",
              placeholder:
                  (context, url) => Image.asset("assets/mtg_card_back.png"),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              // color: Colors.black.withValues(alpha: 0.5),
              margin: EdgeInsets.fromLTRB(4, 1, 4, 3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(3, 1, 3, 1),
                      decoration: foilDecoration(
                        blendMode: BlendMode.src,
                        opacity: 1,
                      ),
                      child: Text(
                        "$inCollectionCountFoil",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(3, 1, 3, 1),
                      color: theme.colorScheme.secondaryContainer,
                      child: Text(
                        "$inCollectionCountNonFoil",
                        style: TextStyle(
                          color: theme.colorScheme.inverseSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
