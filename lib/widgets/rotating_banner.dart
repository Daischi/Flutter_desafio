import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/media_model.dart';
import '../theme.dart';

class RotatingBanner extends StatefulWidget {
  final List<MediaItem> items;
  final Function(MediaItem) onItemTap;

  const RotatingBanner({Key? key, required this.items, required this.onItemTap})
    : super(key: key);

  @override
  State<RotatingBanner> createState() => _RotatingBannerState();
}

class _RotatingBannerState extends State<RotatingBanner> {
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.items.isNotEmpty && mounted) {
        final nextIndex = (_currentIndex + 1) % widget.items.length;
        setState(() {
          _currentIndex = nextIndex;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        CarouselSlider.builder(
          // Note: Using CarouselSlider built-in autoplay instead of our custom implementation
          itemCount: widget.items.length,
          itemBuilder: (context, index, _) {
            final item = widget.items[index];
            return GestureDetector(
              onTap: () => widget.onItemTap(item),
              child: Hero(
                tag: 'banner-${item.id}-${item.type}',
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Backdrop image
                        CachedNetworkImage(
                          imageUrl: item.backdropUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[900],
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                        ),
                        // Gradient overlay for text visibility
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                        // Content overlay
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 6.0,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      item.type == MediaType.movie
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
                                          : Theme.of(
                                            context,
                                          ).colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Text(
                                  item.type == MediaType.movie
                                      ? 'FILME'
                                      : 'SERIE',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelSmall?.copyWith(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSecondary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              // Title with animation
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.8, end: 1.0),
                                duration: const Duration(milliseconds: 300),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    alignment: Alignment.centerLeft,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              // Rating
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    item.formattedRating,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    item.releaseDate.isNotEmpty
                                        ? item.releaseDate.substring(0, 4)
                                        : 'Unknown',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              // Watch now button
                              ElevatedButton(
                                onPressed: () => widget.onItemTap(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                    vertical: 12.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline_rounded,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      'Assista agora',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelLarge?.copyWith(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            aspectRatio: 16 / 9,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, _) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        // Carousel indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              widget.items.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = entry.key;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _currentIndex == entry.key ? 24.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:
                          _currentIndex == entry.key
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
