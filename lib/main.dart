import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/search_provider.dart';
import 'providers/watchlist_provider.dart';
import 'screens/search_screen.dart';
import 'services/omdb_service.dart';
import 'screens/watchlist_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Missing .env: the service surfaces a friendly "missing API key" error.
  }
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    final service = OmdbService();
    return MultiProvider(
      providers: [
        Provider<OmdbService>.value(value: service),
        ChangeNotifierProvider(create: (_) => SearchProvider(service)),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()..load())
      ],
      child: MaterialApp(
        title: 'Movie Search',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo, brightness: Brightness.dark, useMaterial3: true),
        home: const HomeShell(),
      ),
    );
  }
  
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final count = context.select<WatchlistProvider, int>((w) => w.items.length);
    return Scaffold(
      body: IndexedStack(index: _index, children: const [SearchScreen(), WatchlistScreen()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(
            icon: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: const Icon(Icons.bookmark_border)),
            selectedIcon: const Icon(Icons.bookmark),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }
}