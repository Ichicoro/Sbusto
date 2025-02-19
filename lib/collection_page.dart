import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:sbusto/card_data_store.dart';
import 'package:sbusto/user_card_store.dart';

class CollectionPageView extends StatefulWidget {
  const CollectionPageView({super.key});

  @override
  State<CollectionPageView> createState() => _CollectionPageViewState();
}

class _CollectionPageViewState extends State<CollectionPageView> {
  @override
  Widget build(BuildContext context) {
    // ThemeData theme = Theme.of(context);
    // final cardStore = Provider.of<CardDataStoreModel>(context, listen: true);
    final userCollectionStore = Provider.of<UserCardStoreModel>(
      context,
      listen: true,
    );

    print(userCollectionStore.cards.length);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Your collection: ${userCollectionStore.cards.length} cards"),
            GridView(
              shrinkWrap: true,
              primary: false,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.52,
              ),
              children: [
                for (final userCard in userCollectionStore.cardsWithoutDupes
                    .sorted(
                      (a, b) =>
                          a.cardData?.name.compareTo(b.cardData?.name ?? "") ??
                          0,
                    )) ...[UserCardView(userCard: userCard)],
              ],
            ),
          ],
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
    // final cardStore = Provider.of<CardDataStoreModel>(context, listen: true);
    final userCollectionStore = Provider.of<UserCardStoreModel>(
      context,
      listen: true,
    );

    final inCollectionCount = userCollectionStore.getCardCount(userCard);

    return Card(
      child: Column(
        children: [
          Image.network(
            userCard.cardData?.imageUris?.normal.toString() ??
                "http://google.com/favicon.ico",
          ),
          Text(userCard.cardData?.name ?? "no card"),
          Text("In collection: $inCollectionCount"),
        ],
      ),
    );
  }
}
