import 'package:dio/dio.dart';
import '../models/media_model.dart';

class TMDBService {
  final String apiKey;
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.themoviedb.org/3';

  TMDBService({required this.apiKey});

  // Fetch trending movies
  Future<List<MediaItem>> getTrendingMovies() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/trending/movie/day',
        queryParameters: {'api_key': apiKey},
      );
      return (response.data['results'] as List)
          .map((movie) => MediaItem.fromMovieJson(movie))
          .toList();
    } catch (e) {
      print('Error fetching trending movies: $e');
      return [];
    }
  }

  // Fetch trending TV shows
  Future<List<MediaItem>> getTrendingTVShows() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/trending/tv/day',
        queryParameters: {'api_key': apiKey},
      );
      return (response.data['results'] as List)
          .map((tv) => MediaItem.fromTVJson(tv))
          .toList();
    } catch (e) {
      print('Error fetching trending TV shows: $e');
      return [];
    }
  }

  // Fetch popular movies
  Future<List<MediaItem>> getPopularMovies() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/popular',
        queryParameters: {'api_key': apiKey},
      );
      return (response.data['results'] as List)
          .map((movie) => MediaItem.fromMovieJson(movie))
          .toList();
    } catch (e) {
      print('Error fetching popular movies: $e');
      return [];
    }
  }

  // Fetch latest movies (now playing)
  Future<List<MediaItem>> getLatestMovies() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/now_playing',
        queryParameters: {'api_key': apiKey},
      );
      return (response.data['results'] as List)
          .map((movie) => MediaItem.fromMovieJson(movie))
          .toList();
    } catch (e) {
      print('Error fetching latest movies: $e');
      return [];
    }
  }

  // Fetch popular TV shows
  Future<List<MediaItem>> getPopularTVShows() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/tv/popular',
        queryParameters: {'api_key': apiKey},
      );
      return (response.data['results'] as List)
          .map((tv) => MediaItem.fromTVJson(tv))
          .toList();
    } catch (e) {
      print('Error fetching popular TV shows: $e');
      return [];
    }
  }

  // Search for movies and TV shows
  Future<List<MediaItem>> searchMedia(String query, {MediaType? type}) async {
    try {
      if (type == MediaType.movie) {
        final response = await _dio.get(
          '$_baseUrl/search/movie',
          queryParameters: {'api_key': apiKey, 'query': query},
        );
        return (response.data['results'] as List)
            .map((movie) => MediaItem.fromMovieJson(movie))
            .toList();
      } else if (type == MediaType.tv) {
        final response = await _dio.get(
          '$_baseUrl/search/tv',
          queryParameters: {'api_key': apiKey, 'query': query},
        );
        return (response.data['results'] as List)
            .map((tv) => MediaItem.fromTVJson(tv))
            .toList();
      } else {
        // Search both movies and TV shows
        final movieResponse = await _dio.get(
          '$_baseUrl/search/movie',
          queryParameters: {'api_key': apiKey, 'query': query},
        );
        final tvResponse = await _dio.get(
          '$_baseUrl/search/tv',
          queryParameters: {'api_key': apiKey, 'query': query},
        );

        final movies =
            (movieResponse.data['results'] as List)
                .map((movie) => MediaItem.fromMovieJson(movie))
                .toList();
        final tvShows =
            (tvResponse.data['results'] as List)
                .map((tv) => MediaItem.fromTVJson(tv))
                .toList();

        return [...movies, ...tvShows];
      }
    } catch (e) {
      print('Error searching media: $e');
      return [];
    }
  }

  // Get movie details
  Future<MediaDetails?> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/$movieId',
        queryParameters: {
          'api_key': apiKey,
          'language': 'pt-BR', // <<< Adiciona isso aqui
          'append_to_response': 'credits,videos,similar',
        },
      );

      final data = response.data;
      final cast =
          ((data['credits'] ?? {})['cast'] as List? ?? [])
              .map((c) => Cast.fromJson(c))
              .take(10)
              .toList();

      final videos =
          ((data['videos'] ?? {})['results'] as List? ?? [])
              .where((v) => v['site'] == 'YouTube')
              .map((v) => Video.fromJson(v))
              .toList();

      final similar =
          ((data['similar'] ?? {})['results'] as List? ?? [])
              .map((m) => MediaItem.fromMovieJson(m))
              .take(10)
              .toList();

      return MediaDetails.fromMovieJson(
        data,
        cast: cast,
        videos: videos,
        similar: similar,
      );
    } catch (e) {
      print('Error fetching movie details: $e');
      return null;
    }
  }

  // Get TV show details
  Future<MediaDetails?> getTVDetails(int tvId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/tv/$tvId',
        queryParameters: {
          'api_key': apiKey,
          'language': 'pt-BR', // <<< Adiciona isso aqui também
          'append_to_response': 'credits,videos,similar',
        },
      );

      final data = response.data;
      final cast =
          ((data['credits'] ?? {})['cast'] as List? ?? [])
              .map((c) => Cast.fromJson(c))
              .take(10)
              .toList();

      final videos =
          ((data['videos'] ?? {})['results'] as List? ?? [])
              .where((v) => v['site'] == 'YouTube')
              .map((v) => Video.fromJson(v))
              .toList();

      final similar =
          ((data['similar'] ?? {})['results'] as List? ?? [])
              .map((m) => MediaItem.fromTVJson(m))
              .take(10)
              .toList();

      return MediaDetails.fromTVJson(
        data,
        cast: cast,
        videos: videos,
        similar: similar,
      );
    } catch (e) {
      print('Error fetching TV details: $e');
      return null;
    }
  }
}
