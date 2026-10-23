// Main search screen with real-time queries, category filtering, infinite scroll pagination and state handling.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/search_provider.dart';
import '../widgets/poster.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
        context.read<SearchProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SearchProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Search films')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _controller,
            onChanged: (v) {
              sp.onQueryChanged(v);
              setState(() {});
            },
            onSubmitted: sp.search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by title…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        sp.search('');
                        setState(() {});
                      },
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Wrap(spacing: 8, children: [
            for (final f in const [(null, 'All'), ('movie', 'Movies'), ('series', 'Series')])
              ChoiceChip(
                label: Text(f.$2),
                selected: sp.typeFilter == f.$1,
                onSelected: (_) => sp.setType(f.$1),
              ),
          ]),
        ),
        Expanded(child: _body(sp)),
      ]),
    );
  }

  Widget _body(SearchProvider sp) {
    switch (sp.status) {
      case SearchStatus.idle:
        return const MessageView(
            icon: Icons.local_movies_outlined, text: 'Type at least 3 letters to find a film.');
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchStatus.empty:
        return const MessageView(icon: Icons.search_off, text: 'No films matched your search.');
      case SearchStatus.error:
        return MessageView(
            icon: Icons.error_outline, text: sp.error ?? 'Something went wrong.', onRetry: sp.retry);
      case SearchStatus.loaded:
        return ListView.builder(
          controller: _scroll,
          itemCount: sp.results.length + (sp.loadingMore ? 1 : 0),
          itemBuilder: (_, i) {
            if (i >= sp.results.length) {
              return const Padding(
                  padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
            }
            return _ResultTile(movie: sp.results[i]);
          },
        );
    }
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.movie});
  final MovieSummary movie;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Poster(url: movie.poster),
      title: Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('${movie.year} · ${movie.type}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetailScreen(movie: movie))),
    );
  }
}