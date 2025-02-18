import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sbusto/all_cards_page.dart';
import 'package:sbusto/card_data_store.dart';
import 'package:sbusto/debug_card_view.dart';
import 'package:sbusto/user_card_store.dart';

import 'settings_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CardDataStoreModel()),
        ChangeNotifierProvider(create: (context) => UserCardStoreModel()),
      ],
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
          Center(child: Text('Home')),
          AllCardsPage(),
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
