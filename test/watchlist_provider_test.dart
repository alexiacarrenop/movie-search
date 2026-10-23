import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search/models/movie.dart';
import 'package:movie_search/providers/watchlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const film = MovieSummary(title: 'A', year: '2001', imdbId: 'tt1', type: 'movie');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('toggle adds then removes a film', () async {
    final wl = WatchlistProvider();
    await wl.load();
    wl.toggle(film);
    expect(wl.contains('tt1'), isTrue);
    wl.toggle(film);
    expect(wl.contains('tt1'), isFalse);
  });

  test('toggleWatched flips the watched flag', () async {
    final wl = WatchlistProvider();
    await wl.load();
    wl.toggle(film);
    wl.toggleWatched('tt1');
    expect(wl.isWatched('tt1'), isTrue);
  });

  test('watchlist persists across provider instances', () async {
    final a = WatchlistProvider();
    await a.load();
    a.toggle(film);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final b = WatchlistProvider();
    await b.load();
    expect(b.contains('tt1'), isTrue);
  });
}