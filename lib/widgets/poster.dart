import 'package:flutter/material.dart';

/// Network poster that displays images
class Poster extends StatelessWidget {
  const Poster({super.key, this.url, this.width = 56, this.height = 84});
  final String? url;
  final double width, height;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.movie_outlined),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, p) => p == null ? child : placeholder,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
