// home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_model.dart';
import '../providers/media_provider.dart';
import '../widgets/media_card.dart';
import '../widgets/rotating_banner.dart';
import 'details_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _scrollController.addListener(() {
      setState(() {
        _showTitle = _scrollController.offset > 100;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navegarParaDetalhes(BuildContext context, MediaItem item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                DetailsScreen(mediaId: item.id, mediaType: item.type),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _navegarParaBusca() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _construirListaHorizontal(String titulo, List<MediaItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text('Ver tudo'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child:
              items.isEmpty
                  ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return const MediaCardPlaceholder();
                    },
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return MediaCard(
                        item: items[index],
                        onTap:
                            () => _navegarParaDetalhes(context, items[index]),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = Provider.of<MediaProvider>(context);

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: _showTitle ? 0 : 100,
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child:
                    _showTitle
                        ? const Text('Poppi Cine')
                        : Row(
                          key: const ValueKey('logo'),
                          children: [
                            Icon(
                              Icons.movie_filter,
                              size: 28,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Poppi Cine',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
              ),

              backgroundColor: Theme.of(
                context,
              ).colorScheme.surface.withOpacity(0.9),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _navegarParaBusca,
                  tooltip: 'Buscar',
                ),
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {},
                  tooltip: 'Favoritos',
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.7),
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Filmes'),
                  Tab(text: 'Séries'),
                  Tab(text: 'Favoritos'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Filmes
            RefreshIndicator(
              onRefresh: () => mediaProvider.refreshData(),
              child:
                  mediaProvider.isLoading &&
                          mediaProvider.trendingMovies.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : mediaProvider.error.isNotEmpty
                      ? Center(child: Text(mediaProvider.error))
                      : ListView(
                        children: [
                          const SizedBox(height: 16),
                          if (mediaProvider.trendingMovies.isNotEmpty)
                            RotatingBanner(
                              items:
                                  mediaProvider.trendingMovies.take(5).toList(),
                              onItemTap:
                                  (item) => _navegarParaDetalhes(context, item),
                            ),
                          const SizedBox(height: 24),
                          _construirListaHorizontal(
                            '🔥 Lançamentos',
                            mediaProvider.latestMovies,
                          ),
                          const SizedBox(height: 16),
                          _construirListaHorizontal(
                            '⭐ Populares',
                            mediaProvider.popularMovies,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
            ),
            // Séries
            RefreshIndicator(
              onRefresh: () => mediaProvider.refreshData(),
              child:
                  mediaProvider.isLoading &&
                          mediaProvider.trendingTVShows.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : mediaProvider.error.isNotEmpty
                      ? Center(child: Text(mediaProvider.error))
                      : ListView(
                        children: [
                          const SizedBox(height: 16),
                          if (mediaProvider.trendingTVShows.isNotEmpty)
                            RotatingBanner(
                              items:
                                  mediaProvider.trendingTVShows
                                      .take(5)
                                      .toList(),
                              onItemTap:
                                  (item) => _navegarParaDetalhes(context, item),
                            ),
                          const SizedBox(height: 24),
                          _construirListaHorizontal(
                            '📺 Séries em alta',
                            mediaProvider.trendingTVShows,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
            ),
            // Favoritos
            mediaProvider.favorites.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum favorito',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seus filmes e séries favoritos aparecerão aqui',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: mediaProvider.favorites.length,
                  itemBuilder: (context, index) {
                    final item = mediaProvider.favorites[index];
                    return MediaCard(
                      item: item,
                      onTap: () => _navegarParaDetalhes(context, item),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
