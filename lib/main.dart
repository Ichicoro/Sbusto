import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sbusto/card_data_store.dart';
import 'package:sbusto/debug_card_view.dart';

import 'settings_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CardDataStoreModel(),
      child: MyApp(),
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.rubikTextTheme(Typography.whiteMountainView),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
        ),
      ),
      home: const NavigationWrapper(),
      themeMode: ThemeMode.light,
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
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title:
            [
              const Text('Home'),
              const Text("Search"),
              const Text("Collections"),
              const Text("Profile"),
            ][_navbarPageIndex],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              // Navigate to the settings page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsPage();
                  },
                ),
              );
            },
          ),
        ],
        // backgroundColor: theme.appBarTheme.backgroundColor?.withAlpha(200),
        // forceMaterialTransparency: true,
        // flexibleSpace: ClipRRect(
        //   child: BackdropFilter(
        //     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        //     child: Container(
        //       color: theme.appBarTheme.backgroundColor?.withAlpha(100),
        //     ),
        //   ),
        // ),
      ),
      // extendBodyBehindAppBar: true,
      body: IndexedStack(
        index: _navbarPageIndex,
        children: const <Widget>[
          HomePage(title: 'Home'),
          Center(child: Text('Search Page')),
          Center(child: Text('Collections Page')),
          Center(child: Text('Profile Page')),
        ],
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

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Consumer<CardDataStoreModel>(
      builder: (context, store, child) {
        if (store.catalog == null) {
          if (store.isLoading) {
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
                              "Load cards (from ${store.areCardsCached ? 'cache' : 'network'})",
                            ),
                            onPressed: () {
                              store.loadCards();
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              store.clearCatalogFromPrefs();
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

        return GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
          ),
          children: [
            for (final card in store.catalog!) ...[
              Card(
                child: Stack(
                  children: [
                    Ink.image(
                      image: NetworkImage(card.imageUris?.png.toString() ?? ""),
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
        );
      },
    );
  }
}
