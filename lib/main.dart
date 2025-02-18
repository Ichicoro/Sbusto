import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbusto/card_data_store.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CardDataStoreModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sbusto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const NavigationWrapper(),
    );
  }
}

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _navbarPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sbusto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              // Navigate to the settings page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Scaffold(
                      appBar: AppBar(title: Text('Settings')),
                      body: Center(child: Text('Settings Page')),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _navbarPageIndex,
          children: const <Widget>[
            MyHomePage(title: 'Home Page'),
            Center(child: Text('Search Page')),
            Center(child: Text('Collections Page')),
            Center(child: Text('Profile Page')),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navbarPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _navbarPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_rounded),
            label: 'Collections',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<CardDataStoreModel>(
      builder: (context, store, child) {
        if (store.catalog == null) {
          // store.loadCards();
          // return const Center(child: CircularProgressIndicator());
          if (store.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), Text('Loading...')],
              ),
            );
          } else {
            return Center(
              child: Column(children: [
                FilledButton(
                    child: const Text(
                      "Load cards (from ${store.areCardsCached ? 'cache' : 'network'})",
                    ),
                    onPressed: () {
                      store.loadCards();
                    },
                  )
              ],),
            );
          }
        }

        return ListView(
          children: [
            for (final card in store.catalog!) ...[
              ListTile(
                title: Text(card.name),
                // subtitle: Text(card.type),
                // leading: Image.network(card.imageUris?.png.toString() ?? ""),
              ),
              const Divider(),
            ],
          ],
        );

        // return Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     Text('ziopera', style: Theme.of(context).textTheme.headlineMedium),
        //   ],
        // );
      },
    );
  }
}
