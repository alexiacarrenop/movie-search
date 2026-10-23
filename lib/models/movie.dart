/// OMDB returns the literal string "N/A" for missing values.
String? clean(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return (s.isEmpty || s == 'N/A') ? null : s;
}

class MovieSummary {
  final String title, year, imdbId, type;
  final String? poster;

  const MovieSummary({
    required this.title,
    required this.year,
    required this.imdbId,
    required this.type,
    this.poster,
  });

  factory MovieSummary.fromJson(Map<String, dynamic> j) => MovieSummary(
    title: clean(j['Title']) ?? 'Untitled',
    year: clean(j['Year']) ?? '',
    imdbId: j['imdbID'] ?? '',
    type: clean(j['Type']) ?? '',
    poster: clean(j['Poster']),
  );

  Map<String, dynamic> toJson() => {
    'Title': title,
    'Year': year,
    'imdbID': imdbId,
    'Type': type,
    'Poster': poster ?? 'N/A',
  };
}

class MovieDetail {
  final String imdbId, title;
  final String? year,
      rated,
      runtime,
      genre,
      director,
      actors,
      plot,
      poster,
      awards,
      type;
  final Map<String, String> ratings; // source -> value

  const MovieDetail({
    required this.imdbId,
    required this.title,
    required this.ratings,
    this.year,
    this.rated,
    this.runtime,
    this.genre,
    this.director,
    this.actors,
    this.plot,
    this.poster,
    this.awards,
    this.type,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> j) {
    final ratings = <String, String>{};
    for (final r in (j['Ratings'] as List? ?? [])) {
      final src = clean(r['Source']);
      final val = clean(r['Value']);
      if (src != null && val != null) ratings[src] = val;
    }
    return MovieDetail(
      imdbId: j['imdbID'] ?? '',
      title: clean(j['Title']) ?? 'Untitled',
      year: clean(j['Year']),
      rated: clean(j['Rated']),
      runtime: clean(j['Runtime']),
      genre: clean(j['Genre']),
      director: clean(j['Director']),
      actors: clean(j['Actors']),
      plot: clean(j['Plot']),
      poster: clean(j['Poster']),
      awards: clean(j['Awards']),
      type: clean(j['Type']),
      ratings: ratings,
    );
  }
}

/// Converts "8.1/10", "93%" or "71/100" into 0..1 (null if unparseable).
double? ratingFraction(String v) {
  final s = v.trim();
  if (s.endsWith('%')) {
    final n = double.tryParse(s.substring(0, s.length - 1));
    return n == null ? null : (n / 100).clamp(0.0, 1.0).toDouble();
  }
  final p = s.split('/');
  if (p.length == 2) {
    final a = double.tryParse(p[0]), b = double.tryParse(p[1]);
        if (a != null && b != null && b > 0) {
      return (a / b).clamp(0.0, 1.0).toDouble();
    }
  }
  return null;
}

class WatchlistItem {
  final MovieSummary movie;
  final bool watched;
  const WatchlistItem(this.movie, {this.watched = false});

  WatchlistItem copyWith({bool? watched}) =>
      WatchlistItem(movie, watched: watched ?? this.watched);

  factory WatchlistItem.fromJson(Map<String, dynamic> j) => WatchlistItem(
    MovieSummary.fromJson(j['movie']),
    watched: j['watched'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'movie': movie.toJson(),
    'watched': watched,
  };
}
