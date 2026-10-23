import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';

class WatchlistProvider extends ChangeNotifier {
  static const _storageKey = 'watchlist_v1';
  final List<WatchlistItem> _items = [];
  bool loaded = false;

  List<WatchlistItem> get items => List.unmodifiable(_items);

  bool contains(String imdbId) => _items.any((i) => i.movie.imdbId == imdbId);
  bool isWatched(String imdbId) =>
      _items.any((i) => i.movie.imdbId == imdbId && i.watched);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        _items.addAll((jsonDecode(raw) as List)
            .map((e) => WatchlistItem.fromJson(e as Map<String, dynamic>)));
      }
    } catch (_) {
      // Corrupt data: start fresh rather than crash.
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_items.map((i) => i.toJson()).toList()));
  }

  void toggle(MovieSummary movie) {
    if (contains(movie.imdbId)) {
      remove(movie.imdbId);
    } else {
      _items.insert(0, WatchlistItem(movie));
      notifyListeners();
      _save();
    }
  }

  void remove(String imdbId) {
    _items.removeWhere((i) => i.movie.imdbId == imdbId);
    notifyListeners();
    _save();
  }

  void toggleWatched(String imdbId) {
    final idx = _items.indexWhere((i) => i.movie.imdbId == imdbId);
    if (idx == -1) return;
    _items[idx] = _items[idx].copyWith(watched: !_items[idx].watched);
    notifyListeners();
    _save();
  }
}