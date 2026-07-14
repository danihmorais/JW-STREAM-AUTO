import 'package:dio/dio.dart';
import '../models/media_model.dart';

/// Thrown when the songs couldn't be fetched (network error, timeout,
/// unexpected API shape). Kept separate from "the API returned zero
/// songs", which is a legitimate, non-error result.
class ApiServiceException implements Exception {
  final String message;
  ApiServiceException(this.message);
}

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<MediaItemModel>> fetchSongs(String langCode, String pubCode) async {
    try {
      final response = await _dio.get(
        'https://b.jw-cdn.org/apis/pub-media/GETPUBMEDIALINKS',
        queryParameters: {
          'pub': pubCode,
          'langwritten': langCode,
          'alllangs': 0,
          'fileformat': 'mp3',
        },
      );

      final Map<String, dynamic> data = response.data;
      final List<MediaItemModel> songs = [];
      final files = data['files'];

      if (files != null && files[langCode] != null) {
        final formats = files[langCode];
        if (formats['MP3'] != null) {
          for (var item in formats['MP3']) {
            songs.add(MediaItemModel.fromJson(item));
          }
        }
      }
      return songs;
    } on DioException catch (e) {
      throw ApiServiceException(e.message ?? 'Network error');
    } catch (e) {
      throw ApiServiceException(e.toString());
    }
  }
}