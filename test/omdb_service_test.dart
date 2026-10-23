import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:movie_search/services/omdb_service.dart';

OmdbService serviceReturning(Object body, {int status = 200}) =>
    OmdbService(client: MockClient((_) async => http.Response(jsonEncode(body), status)));

void main() {
  setUpAll(() => dotenv.testLoad(fileInput: 'OMDB_API_KEY=test'));

  test('search returns movies and total', () async {
    final s = serviceReturning({
      'Response': 'True',
      'totalResults': '2',
      'Search': [
        {'Title': 'A', 'Year': '2001', 'imdbID': 'tt1', 'Type': 'movie', 'Poster': 'N/A'},
        {'Title': 'B', 'Year': '2002', 'imdbID': 'tt2', 'Type': 'movie', 'Poster': 'N/A'},
      ],
    });
    final page = await s.search('abc');
    expect(page.movies.length, 2);
    expect(page.total, 2);
  });

  test('"Movie not found!" is an empty result, not an error', () async {
    final s = serviceReturning({'Response': 'False', 'Error': 'Movie not found!'});
    final page = await s.search('zzzzzz');
    expect(page.movies, isEmpty);
  });

  test('invalid API key throws a friendly error', () async {
    final s = serviceReturning({'Response': 'False', 'Error': 'Invalid API key!'});
    expect(() => s.search('abc'), throwsA(isA<OmdbException>()));
  });

  test('network failure maps to "No internet"', () async {
    final s = OmdbService(client: MockClient((_) async => throw http.ClientException('x')));
    expect(
      () => s.search('abc'),
      throwsA(predicate((e) => e is OmdbException && e.message.contains('internet'))),
    );
  });

  test('getDetail parses a film', () async {
    final s = serviceReturning({'Response': 'True', 'imdbID': 'tt1', 'Title': 'A', 'Ratings': []});
    final d = await s.getDetail('tt1');
    expect(d.title, 'A');
  });
}
