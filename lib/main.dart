import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/search_provider.dart';
import 'providers/watchlist_provider.dart';
import 'screens/search_screen.dart';
import 'services/omdb_service.dart';

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
        home: const SearchScreen(),
      ),
    );
  }
}
