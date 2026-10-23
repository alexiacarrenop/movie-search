import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/watchlist_provider.dart';
import '../services/omdb_service.dart';
import '../widgets/poster.dart';
import '../widgets/state_views.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.movie});
  final MovieSummary movie;
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<MovieDetail> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() =>
      _future = context.read<OmdbService>().getDetail(widget.movie.imdbId);

  @override
  Widget build(BuildContext context) {
    final wl = context.watch<WatchlistProvider>();
    final saved = wl.contains(widget.movie.imdbId);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: saved ? 'Remove from watchlist' : 'Add to watchlist',
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () => wl.toggle(widget.movie),
          ),
        ],
      ),
      body: FutureBuilder<MovieDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return MessageView(
              icon: Icons.error_outline,
              text: snap.error.toString(),
              onRetry: () => setState(_load),
            );
          }
          return _Content(detail: snap.data!, summary: widget.movie);
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.detail, required this.summary});
  final MovieDetail detail;
  final MovieSummary summary;

  @override
  Widget build(BuildContext context) {
    final wl = context.watch<WatchlistProvider>();
    final text = Theme.of(context).textTheme;
    final meta = [
      detail.year,
      detail.rated,
      detail.runtime,
    ].whereType<String>().join(' · ');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Poster(url: detail.poster, width: 120, height: 180),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(detail.title, style: text.titleLarge),
                  const SizedBox(height: 4),
                  Text(meta, style: text.bodyMedium),
                  if (detail.genre != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final g in detail.genre!.split(', '))
                          Chip(label: Text(g)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (wl.contains(summary.imdbId))
          FilledButton.icon(
            onPressed: () => wl.toggleWatched(summary.imdbId),
            icon: Icon(
              wl.isWatched(summary.imdbId)
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
            ),
            label: Text(
              wl.isWatched(summary.imdbId) ? 'Watched' : 'Mark as watched',
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () => wl.toggle(summary),
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Add to watchlist'),
          ),
        if (detail.ratings.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Ratings', style: text.titleMedium),
          const SizedBox(height: 8),
          for (final e in detail.ratings.entries)
            _RatingBar(source: e.key, value: e.value),
        ],
        if (detail.plot != null) ...[
          const SizedBox(height: 24),
          Text('Plot', style: text.titleMedium),
          const SizedBox(height: 8),
          Text(detail.plot!),
        ],
        _Fact('Director', detail.director),
        _Fact('Cast', detail.actors),
        _Fact('Awards', detail.awards),
      ],
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.source, required this.value});
  final String source, value;

  @override
  Widget build(BuildContext context) {
    final frac = ratingFraction(value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(source),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: frac, minHeight: 8),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(value!),
        ],
      ),
    );
  }
}
