// Manages the reactive state, business logic, and API interactions for the app's search feature.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../services/omdb_service.dart';

// Tracks current state of search
enum SearchStatus { idle, loading, loaded, empty, error }

class SearchProvider extends ChangeNotifier {
  SearchProvider(this._service);
  final OmdbService _service;

  Timer? _debounce; // delay api calls while typing
  String _query = '';
  int _page = 1, _total = 0; // pagination trackers (position)

  final List<MovieSummary> results = [];
  SearchStatus status = SearchStatus.idle;
  String? error;
  bool loadingMore = false;
  String? typeFilter; // null = all, 'movie', 'series'

  // To see if more pages can be fetched
  bool get hasMore => results.length < _total;

  /// Debounced so it doesn't burn the 1,000 requests/day free while typing.
  void onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => search(q));
  }

  void setType(String? type) {
    typeFilter = type;
    search(_query);
  }

  // Perform search request with validation and race-condition checks
  Future<void> search(String q) async {
    _query = q.trim();
    if (_query.length < 3) {
      results.clear();
      status = SearchStatus.idle;
      notifyListeners();
      return;
    }

    status = SearchStatus.loading;
    notifyListeners();

    // for stale responses
    final requested = _query;
    try {
      final page = await _service.search(requested, type: typeFilter);
      if (requested != _query) return; // stale response, a newer search is in flight
      _page = 1;
      _total = page.total;
      results
        ..clear()
        ..addAll(page.movies);
      status = results.isEmpty ? SearchStatus.empty : SearchStatus.loaded;
    } catch (e) {
      if (requested != _query) return;
      error = e.toString();
      status = SearchStatus.error;
    }
    notifyListeners();
  }

  // fecth next page of results
  Future<void> loadMore() async {
    if (loadingMore || !hasMore || status != SearchStatus.loaded) return;
    loadingMore = true;
    notifyListeners();
    final requested = _query;
    try {
      final page = await _service.search(requested, page: _page + 1, type: typeFilter);
      if (requested == _query) {
        _page++;
        results.addAll(page.movies);
      }
    } catch (_) {
      // Keep what it has; the user can scroll again to retry.
    }
    loadingMore = false;
    notifyListeners();
  }

  // retries last query if error
  void retry() => search(_query);

  @override
  void dispose() {
    _debounce?.cancel(); // clean up
    super.dispose();
  }
}
