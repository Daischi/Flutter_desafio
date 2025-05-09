import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/media_model.dart';
import '../theme.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final bool isFeatured;

  const MediaCard({
    Key? key,
    required this.item,
    required this.onTap,
    this.isFeatured = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFeatured ? double.infinity : 140,
        margin: EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: isFeatured ? 0 : 8.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Poster image
                    CachedNetworkImage(
                      imageUrl: item.posterUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                      errorWidget:
                          (context, url, error) => const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                    ),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Rating badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.formattedRating,
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Media type indicator
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              item.type == MediaType.movie
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.type == MediaType.movie ? 'Filme' : 'Serie',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isFeatured) ...[
              const SizedBox(height: 8),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                item.releaseDate.isNotEmpty
                    ? item.releaseDate.substring(0, 4)
                    : 'Unknown',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Loading placeholder for media cards
class MediaCardPlaceholder extends StatelessWidget {
  final bool isFeatured;

  const MediaCardPlaceholder({Key? key, this.isFeatured = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFeatured ? double.infinity : 140,
      margin: EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: isFeatured ? 0 : 8.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
              ),
            ),
            if (!isFeatured) ...[
              const SizedBox(height: 8),
              Container(width: 100, height: 12, color: Colors.white),
              const SizedBox(height: 4),
              Container(width: 60, height: 10, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
