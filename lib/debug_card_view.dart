import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            children: [
              Image.network(card.imageUris?.png.toString() ?? ""),
              Text(card.name),
              Text(card.oracleText ?? ""),
            ],
          ),
        );
      },
    );
  }
}
