import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/watchlist_provider.dart';
import '../widgets/poster.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

enum _Filter { all, toWatch, watched }

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});
  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final wl = context.watch<WatchlistProvider>();
    final items = wl.items.where((i) {
      switch (_filter) {
        case _Filter.all:
          return true;
        case _Filter.toWatch:
          return !i.watched;
        case _Filter.watched:
          return i.watched;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My watchlist')),
      body: !wl.loaded
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SegmentedButton<_Filter>(
                  segments: const [
                    ButtonSegment(value: _Filter.all, label: Text('All')),
                    ButtonSegment(value: _Filter.toWatch, label: Text('To watch')),
                    ButtonSegment(value: _Filter.watched, label: Text('Watched')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (s) => setState(() => _filter = s.first),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const MessageView(
                        icon: Icons.bookmark_border,
                        text: 'Nothing here yet. Bookmark films from the search tab.')
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final item = items[i];
                          final m = item.movie;
                          return Dismissible(
                            key: ValueKey(m.imdbId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Theme.of(context).colorScheme.errorContainer,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: const Icon(Icons.delete_outline),
                            ),
                            onDismissed: (_) => wl.remove(m.imdbId),
                            child: ListTile(
                              leading: Poster(url: m.poster),
                              title: Text(m.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                              subtitle: Text('${m.year} · ${m.type}'),
                              trailing: Checkbox(
                                value: item.watched,
                                onChanged: (_) => wl.toggleWatched(m.imdbId),
                              ),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => DetailScreen(movie: m))),
                            ),
                          );
                        },
                      ),
              ),
            ]),
    );
  }
}