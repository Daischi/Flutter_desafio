class MediaItem {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;
  final MediaType type;

  MediaItem({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
    required this.type,
  });

  String get posterUrl =>
      posterPath != null
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : 'https://via.placeholder.com/500x750?text=No+Image';

  String get backdropUrl =>
      backdropPath != null
          ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
          : 'https://via.placeholder.com/1280x720?text=No+Image';

  String get formattedRating => '${(voteAverage * 10).toInt()}%';

  factory MediaItem.fromMovieJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      type: MediaType.movie,
    );
  }

  factory MediaItem.fromTVJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      title: json['name'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['first_air_date'] ?? '',
      type: MediaType.tv,
    );
  }
}

class MediaDetails extends MediaItem {
  final List<Genre> genres;
  final String status;
  final List<Cast> cast;
  final List<Video> videos;
  final List<MediaItem> similar;

  MediaDetails({
    required int id,
    required String title,
    String? posterPath,
    String? backdropPath,
    required String overview,
    required double voteAverage,
    required String releaseDate,
    required MediaType type,
    required this.genres,
    required this.status,
    required this.cast,
    required this.videos,
    required this.similar,
  }) : super(
         id: id,
         title: title,
         posterPath: posterPath,
         backdropPath: backdropPath,
         overview: overview,
         voteAverage: voteAverage,
         releaseDate: releaseDate,
         type: type,
       );

  String get genresText => genres.map((g) => g.name).join(', ');

  factory MediaDetails.fromMovieJson(
    Map<String, dynamic> json, {
    List<Cast> cast = const [],
    List<Video> videos = const [],
    List<MediaItem> similar = const [],
  }) {
    return MediaDetails(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      type: MediaType.movie,
      genres:
          (json['genres'] as List?)?.map((g) => Genre.fromJson(g)).toList() ??
          [],
      status: json['status'] ?? '',
      cast: cast,
      videos: videos,
      similar: similar,
    );
  }

  factory MediaDetails.fromTVJson(
    Map<String, dynamic> json, {
    List<Cast> cast = const [],
    List<Video> videos = const [],
    List<MediaItem> similar = const [],
  }) {
    return MediaDetails(
      id: json['id'],
      title: json['name'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['first_air_date'] ?? '',
      type: MediaType.tv,
      genres:
          (json['genres'] as List?)?.map((g) => Genre.fromJson(g)).toList() ??
          [],
      status: json['status'] ?? '',
      cast: cast,
      videos: videos,
      similar: similar,
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'], name: json['name']);
  }
}

class Cast {
  final int id;
  final String name;
  final String? profilePath;
  final String character;

  Cast({
    required this.id,
    required this.name,
    this.profilePath,
    required this.character,
  });

  String get profileUrl =>
      profilePath != null
          ? 'https://image.tmdb.org/t/p/w185$profilePath'
          : 'https://via.placeholder.com/185x278?text=No+Image';

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
      character: json['character'] ?? '',
    );
  }
}

class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;

  Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
  String get thumbnailUrl => 'https://img.youtube.com/vi/$key/hqdefault.jpg';

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      key: json['key'],
      name: json['name'],
      site: json['site'],
      type: json['type'],
    );
  }
}

enum MediaType { movie, tv }
