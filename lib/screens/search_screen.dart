import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_model.dart';
import '../providers/media_provider.dart';
import '../widgets/media_card.dart';
import 'details_screen.dart';
import '../theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _showClearButton = _searchController.text.isNotEmpty;
      });

      // Debounced search
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      }
    });

    // Focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    await mediaProvider.searchMedia(query);
  }

  void _clearSearch() {
    _searchController.clear();
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    mediaProvider.clearSearch();
  }

  void _navigateToDetails(BuildContext context, MediaItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DetailsScreen(mediaId: item.id, mediaType: item.type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = Provider.of<MediaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Pesquisar filmes e programas de TV...',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            suffixIcon:
                _showClearButton
                    ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: _clearSearch,
                    )
                    : Icon(
                      Icons.search,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildContent(mediaProvider),
      ),
    );
  }

  Widget _buildContent(MediaProvider mediaProvider) {
    // Loading state
    if (mediaProvider.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty search field - show history
    if (_searchController.text.isEmpty) {
      return _buildSearchHistory(mediaProvider);
    }

    // Search results
    if (mediaProvider.searchResults.isNotEmpty) {
      return _buildSearchResults(mediaProvider);
    }

    // No results for a search
    if (_searchController.text.isNotEmpty && !mediaProvider.isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum resultado encontrado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tente outro termo de pesquisa',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    // Default state
    return const SizedBox.shrink();
  }

  Widget _buildSearchHistory(MediaProvider mediaProvider) {
    if (mediaProvider.searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Pesquisar filmes e programas de TV',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Digite na caixa de pesquisa acima',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesquisas recentes',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  mediaProvider.clearSearchHistory();
                },
                child: Text('Limpar tudo'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: mediaProvider.searchHistory.length,
            itemBuilder: (context, index) {
              final query = mediaProvider.searchHistory[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                trailing: const Icon(Icons.north_west, size: 16),
                onTap: () {
                  _searchController.text = query;
                  _performSearch(query);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(MediaProvider mediaProvider) {
    // Group results by type
    final movies =
        mediaProvider.searchResults
            .where((item) => item.type == MediaType.movie)
            .toList();
    final tvShows =
        mediaProvider.searchResults
            .where((item) => item.type == MediaType.tv)
            .toList();

    return ListView(
      children: [
        if (movies.isNotEmpty) _buildResultsSection('Filmes', movies),
        if (tvShows.isNotEmpty) _buildResultsSection('Series', tvShows),
      ],
    );
  }

  Widget _buildResultsSection(String title, List<MediaItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return MediaCard(
              item: items[index],
              onTap: () => _navigateToDetails(context, items[index]),
            );
          },
        ),
      ],
    );
  }
}
