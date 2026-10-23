import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/movie.dart';

class OmdbException implements Exception {
  final String message;
  OmdbException(this.message);
  @override
  String toString() => message;
}

class SearchPage {
  final List<MovieSummary> movies;
  final int total;
  const SearchPage(this.movies, this.total);
}

class OmdbService {
  OmdbService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  String get _key =>
      dotenv.isInitialized ? (dotenv.env['OMDB_API_KEY'] ?? '') : '';

  Future<Map<String, dynamic>> _get(Map<String, String> params) async {
    if (_key.isEmpty || _key == 'your_key_here') {
      throw OmdbException('Missing OMDB API key. Add it to your .env file.');
    }
    try {
      final uri = Uri.https('www.omdbapi.com', '/', {
        ...params,
        'apikey': _key,
      });
      final res = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 401) throw OmdbException('Invalid API key.');
      if (res.statusCode != 200) {
        throw OmdbException('Server error (${res.statusCode}). Try again.');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on TimeoutException {
      throw OmdbException('The request timed out. Check your connection.');
    } on http.ClientException {
      throw OmdbException('No internet connection.');
    } on FormatException {
      throw OmdbException('Unexpected response from the server.');
    }
  }

  Future<SearchPage> search(String query, {int page = 1, String? type}) async {
    final queryParams = <String, String>{'s': query, 'page': '$page'};
    if (type != null) {
      queryParams['type'] = type;
    }
    final data = await _get(queryParams);
    if (data['Response'] == 'False') {
      final err = data['Error']?.toString() ?? '';
      // "Movie not found!" / "Too many results." for empty states
      if (err.contains('not found') || err.contains('Too many')) {
        return const SearchPage([], 0);
      }
      throw OmdbException(err.isEmpty ? 'Search failed.' : err);
    }
    final list = (data['Search'] as List)
        .map((e) => MovieSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    return SearchPage(
      list,
      int.tryParse('${data['totalResults']}') ?? list.length,
    );
  }

  Future<MovieDetail> getDetail(String imdbId) async {
    final data = await _get({'i': imdbId, 'plot': 'full'});
    if (data['Response'] == 'False') {
      throw OmdbException(data['Error']?.toString() ?? 'Film not found.');
    }
    return MovieDetail.fromJson(data);
  }
}
