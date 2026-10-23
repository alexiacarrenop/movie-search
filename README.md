# Movie Search

A Flutter app that searches the [OMDB API](https://www.omdbapi.com/) and shows film details.

## Features
- **Search** with debounced input, type filter (all/movies/series) and infinite-scroll pagination
- **Details** screen: poster, genres, plot, cast, awards and IMDb / Rotten Tomatoes / Metacritic rating bars
- Loading, empty, error (no internet, bad key, timeout) and missing-poster states

## Run it
1. Get a free key at https://www.omdbapi.com/apikey.aspx
2. `cp .env.example .env` and put your key in `.env` (git-ignored)
3. `flutter pub get && flutter run`

## Structure
```
lib/
  models/     data classes + JSON parsing
  services/   OMDB HTTP client
  providers/  search state (provider / ChangeNotifier)
  screens/    search, detail
  widgets/    poster, message/error view
```

## Decisions
- **provider**: lightweight and enough for the shared search state; Riverpod/Bloc would be overkill here.
- **Debounce (500ms) + 3-char minimum** protect the 1,000 calls/day free quota.
- **Stale-response guard** in `SearchProvider` stops slow old requests overwriting newer results.
- **flutter_dotenv** keeps the API key out of source control (any key shipped in a client app can still be extracted).

## With more time
- Watchlist screen persisted with shared_preferences
- Cache detail responses
- Hero poster transitions, tablet layout
