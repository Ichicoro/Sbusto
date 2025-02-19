import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbusto/card_data_store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final cardStore = Provider.of<CardDataStoreModel>(context, listen: true);
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
    );
  }
}
