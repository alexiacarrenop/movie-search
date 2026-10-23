import 'package:flutter/material.dart';
import '../models/movie.dart';

/// A temporary stub screen for displaying individual movie details.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.movie});
  final MovieSummary movie;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(movie.title)),
        body: Center(
          child: Text('Details for ${movie.title} (${movie.year})'),
        ),
      );
}