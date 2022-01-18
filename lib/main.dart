import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vernet/pages/location_consent_page.dart';
import 'helper/app_settings.dart';
import 'helper/consent_loader.dart';
import 'models/dark_theme_provider.dart';
import 'package:vernet/api/update_checker.dart';
import 'package:vernet/pages/settings_page.dart';

import 'pages/home_page.dart';

late AppSettings appSettings;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool allowed = await ConsentLoader.isConsentPageShown();

  appSettings = AppSettings.instance..load();
  runApp(MyApp(allowed));
}

class MyApp extends StatefulWidget {
  final bool allowed;
  const MyApp(this.allowed, {Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget? child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: themeChangeProvider.darkTheme
                ? ThemeData.dark()
                : ThemeData.light(),
            home: widget.allowed ? TabBarPage() : LocationConsentPage(),
          );
        },
      ),
    );
  }
}

class TabBarPage extends StatefulWidget {
  TabBarPage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<TabBarPage> {
  int _currentIndex = 0;
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    checkForUpdates(context);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [HomePage(), SettingsPage()];
    return Scaffold(
      body: Container(
        padding: MediaQuery.of(context).padding,
        child: _children[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
