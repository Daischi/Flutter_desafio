import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/media_model.dart';
import '../providers/media_provider.dart';
import '../widgets/media_card.dart';
import '../theme.dart';

class DetailsScreen extends StatefulWidget {
  final int mediaId;
  final MediaType mediaType;

  const DetailsScreen({
    Key? key,
    required this.mediaId,
    required this.mediaType,
  }) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  MediaDetails? _details;
  bool _isLoading = true;
  String _error = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

      if (widget.mediaType == MediaType.movie) {
        _details = await mediaProvider.getMovieDetails(widget.mediaId);
      } else {
        _details = await mediaProvider.getTVDetails(widget.mediaId);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erro ao carregar detalhes: $e';
      });
    }
  }

  Future<void> _launchTrailer(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o trailer: $url')),
      );
    }
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background:
            _details?.backdropPath != null
                ? CachedNetworkImage(
                  imageUrl: _details!.backdropUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.black,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.black,
                        child: const Icon(Icons.error, color: Colors.red),
                      ),
                )
                : Container(color: Colors.black),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_details != null)
          Consumer<MediaProvider>(
            builder: (context, provider, _) {
              final isFavorite = provider.isFavorite(
                _details!.id,
                _details!.type,
              );
              return IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                  ),
                ),
                onPressed: () {
                  provider.toggleFavorite(_details!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite
                            ? '${_details!.title} removido dos favoritos'
                            : '${_details!.title} adicionado aos favoritos',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _details!.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      _details!.type == MediaType.movie
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _details!.type == MediaType.movie ? 'FILME' : 'SÉRIE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _details!.formattedRating,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (_details!.releaseDate.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _details!.releaseDate.substring(0, 4),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _details!.status,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          if (_details!.genres.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _details!.genres.map((genre) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Text(
                        genre.name,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    );
                  }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Sinopse',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _details!.overview,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      height: 500,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.7),
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Elenco'),
              Tab(text: 'Trailers'),
              Tab(text: 'Similares'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _details!.cast.isEmpty
                    ? const Center(
                      child: Text('Nenhuma informação de elenco disponível'),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _details!.cast.length,
                      itemBuilder: (context, index) {
                        final cast = _details!.cast[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: CachedNetworkImageProvider(
                              cast.profileUrl,
                            ),
                          ),
                          title: Text(cast.name),
                          subtitle: Text(cast.character),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        );
                      },
                    ),
                _details!.videos.isEmpty
                    ? const Center(child: Text('Nenhum trailer disponível'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _details!.videos.length,
                      itemBuilder: (context, index) {
                        final video = _details!.videos[index];
                        return InkWell(
                          onTap: () => _launchTrailer(video.youtubeUrl),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: video.thumbnailUrl,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    video.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                _details!.similar.isEmpty
                    ? const Center(
                      child: Text('Nenhum título similar disponível'),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _details!.similar.length,
                      itemBuilder: (context, index) {
                        final item = _details!.similar[index];
                        return MediaCard(
                          item: item,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DetailsScreen(
                                      mediaId: item.id,
                                      mediaType: item.type,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _details == null
              ? const Center(child: Text('Nenhum detalhe disponível'))
              : CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_buildHeader(), _buildTabSection()],
                    ),
                  ),
                ],
              ),
    );
  }
}
