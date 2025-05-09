import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_model.dart';
import '../services/tmdb_service.dart';

class MediaProvider with ChangeNotifier {
  final TMDBService _tmdbService;
  bool _isLoading = true;
  String _error = '';

  // Home screen data
  List<MediaItem> _trendingMovies = [];
  List<MediaItem> _latestMovies = [];
  List<MediaItem> _popularMovies = [];
  List<MediaItem> _trendingTVShows = [];

  // Search data
  List<MediaItem> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isSearching = false;

  // Favorites
  List<MediaItem> _favorites = [];

  MediaProvider({required TMDBService tmdbService})
    : _tmdbService = tmdbService {
    _initializeData();
    _loadSearchHistory();
    _loadFavorites();
  }

  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  List<MediaItem> get trendingMovies => _trendingMovies;
  List<MediaItem> get latestMovies => _latestMovies;
  List<MediaItem> get popularMovies => _popularMovies;
  List<MediaItem> get trendingTVShows => _trendingTVShows;
  List<MediaItem> get searchResults => _searchResults;
  List<String> get searchHistory => _searchHistory;
  bool get isSearching => _isSearching;
  List<MediaItem> get favorites => _favorites;

  // Initialize all data for the home screen
  Future<void> _initializeData() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _tmdbService.getTrendingMovies(),
        _tmdbService.getLatestMovies(),
        _tmdbService.getPopularMovies(),
        _tmdbService.getTrendingTVShows(),
      ]);

      _trendingMovies = results[0];
      _latestMovies = results[1];
      _popularMovies = results[2];
      _trendingTVShows = results[3];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Falha ao carregar dados: $e'; // traduzido
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await _initializeData();
  }

  // Search media
  Future<void> searchMedia(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final results = await _tmdbService.searchMedia(query);
      _searchResults = results;

      // Add to search history if not already there
      if (!_searchHistory.contains(query) && query.isNotEmpty) {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.sublist(0, 10);
        }
        _saveSearchHistory();
      }

      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _error = 'Falha na busca: $e'; // traduzido
      _isSearching = false;
      notifyListeners();
    }
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  // Save search history to shared preferences
  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
  }

  // Load search history from shared preferences
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList('search_history') ?? [];
    notifyListeners();
  }

  // Clear search history
  Future<void> clearSearchHistory() async {
    _searchHistory = [];
    await _saveSearchHistory();
    notifyListeners();
  }

  // Fetch movie details
  Future<MediaDetails?> getMovieDetails(int movieId) async {
    try {
      return await _tmdbService.getMovieDetails(movieId);
    } catch (e) {
      _error = 'Erro ao obter detalhes do filme: $e'; // traduzido
      notifyListeners();
      return null;
    }
  }

  // Fetch TV show details
  Future<MediaDetails?> getTVDetails(int tvId) async {
    try {
      return await _tmdbService.getTVDetails(tvId);
    } catch (e) {
      _error = 'Erro ao obter detalhes da série: $e'; // traduzido
      notifyListeners();
      return null;
    }
  }

  // Toggle favorite status for a media item
  Future<void> toggleFavorite(MediaItem item) async {
    final isFavorite = _favorites.any(
      (element) => element.id == item.id && element.type == item.type,
    );

    if (isFavorite) {
      _favorites.removeWhere(
        (element) => element.id == item.id && element.type == item.type,
      );
    } else {
      _favorites.add(item);
    }

    await _saveFavorites();
    notifyListeners();
  }

  // Check if an item is favorited
  bool isFavorite(int id, MediaType type) {
    return _favorites.any(
      (element) => element.id == id && element.type == type,
    );
  }

  // Save favorites to shared preferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> serializedFavorites = [];

    // Simple serialization - in a real app, use proper JSON serialization
    for (var item in _favorites) {
      serializedFavorites.add(
        '${item.id}|${item.type.toString().split('.').last}|${item.title}|'
        '${item.posterPath ?? ''}|${item.backdropPath ?? ''}|${item.overview}|'
        '${item.voteAverage}|${item.releaseDate}',
      );
    }

    await prefs.setStringList('favorites', serializedFavorites);
  }

  // Load favorites from shared preferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> serializedFavorites =
        prefs.getStringList('favorites') ?? [];

    _favorites =
        serializedFavorites.map((item) {
          final parts = item.split('|');
          return MediaItem(
            id: int.parse(parts[0]),
            type: parts[1] == 'movie' ? MediaType.movie : MediaType.tv,
            title: parts[2],
            posterPath: parts[3].isEmpty ? null : parts[3],
            backdropPath: parts[4].isEmpty ? null : parts[4],
            overview: parts[5],
            voteAverage: double.parse(parts[6]),
            releaseDate: parts[7],
          );
        }).toList();

    notifyListeners();
  }
}
