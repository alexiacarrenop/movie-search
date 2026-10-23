import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search/models/movie.dart';

void main() {
  group('ratingFraction', () {
    test('parses x/10', () => expect(ratingFraction('8.1/10'), closeTo(0.81, 1e-9)));
    test('parses percentage', () => expect(ratingFraction('93%'), closeTo(0.93, 1e-9)));
    test('parses x/100', () => expect(ratingFraction('71/100'), closeTo(0.71, 1e-9)));
    test('returns null for junk', () => expect(ratingFraction('great'), isNull));
  });

  group('MovieSummary.fromJson', () {
    test('treats N/A poster as null', () {
      final m = MovieSummary.fromJson(
          {'Title': 'X', 'Year': '2000', 'imdbID': 'tt1', 'Type': 'movie', 'Poster': 'N/A'});
      expect(m.poster, isNull);
    });
  });

  group('MovieDetail.fromJson', () {
    test('collects ratings and drops N/A fields', () {
      final d = MovieDetail.fromJson({
        'imdbID': 'tt1',
        'Title': 'X',
        'Plot': 'N/A',
        'Ratings': [
          {'Source': 'Internet Movie Database', 'Value': '8.0/10'}
        ],
      });
      expect(d.plot, isNull);
      expect(d.ratings['Internet Movie Database'], '8.0/10');
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search/models/movie.dart';

void main() {
  group('ratingFraction', () {
    test('parses x/10', () => expect(ratingFraction('8.1/10'), closeTo(0.81, 1e-9)));
    test('parses percentage', () => expect(ratingFraction('93%'), closeTo(0.93, 1e-9)));
    test('parses x/100', () => expect(ratingFraction('71/100'), closeTo(0.71, 1e-9)));
    test('returns null for junk', () => expect(ratingFraction('great'), isNull));
  });

  group('MovieSummary.fromJson', () {
    test('treats N/A poster as null', () {
      final m = MovieSummary.fromJson(
          {'Title': 'X', 'Year': '2000', 'imdbID': 'tt1', 'Type': 'movie', 'Poster': 'N/A'});
      expect(m.poster, isNull);
    });
  });

  group('MovieDetail.fromJson', () {
    test('collects ratings and drops N/A fields', () {
      final d = MovieDetail.fromJson({
        'imdbID': 'tt1',
        'Title': 'X',
        'Plot': 'N/A',
        'Ratings': [
          {'Source': 'Internet Movie Database', 'Value': '8.0/10'}
        ],
      });
      expect(d.plot, isNull);
      expect(d.ratings['Internet Movie Database'], '8.0/10');
    });
  });
}
