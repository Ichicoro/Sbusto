import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sbusto/all_cards_page.dart';
import 'package:sbusto/card_data_store.dart';
import 'package:sbusto/collection_page.dart';
import 'package:sbusto/debug_unbox_view.dart';
import 'package:sbusto/user_card_store.dart';

import 'settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => CardDataStoreModel(),
      child: ChangeNotifierProvider(
        create:
            (context) => UserCardStoreModel(
              cardDataStore: Provider.of<CardDataStoreModel>(
                context,
                listen: false,
              ),
            ),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.rubikTextTheme(Typography.whiteMountainView),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(10),
    ),
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final cardDataStore = Provider.of<CardDataStoreModel>(
      context,
      listen: true,
    );
    Widget view;
    if (cardDataStore.hasLoaded) {
      view = const NavigationWrapper();
    } else {
      // if (!cardDataStore.isLoading) {
      // Future.delayed(Duration.zero, () {
      //   cardDataStore.loadData();
      // });
      // }
      view = Scaffold(
        // color: theme.bottomSheetTheme.backgroundColor,
        body: Center(
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator(), Text('Loading...')],
          ),
        ),
      );
    }
    return MaterialApp(
      title: 'Sbusto',
      theme: theme,
      home: view,
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
    return Scaffold(
      appBar: AppBar(
        title:
            [
              const Text('Home'),
              const Text("All cards"),
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
          DebugUnboxView(),
          AllCardsPage(),
          CollectionPageView(),
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
            icon: Icon(Icons.all_inclusive_rounded),
            label: 'All cards',
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
