import 'package:dio/dio.dart';
import '../models/media_model.dart';

class ApiService {
  final Dio _dio = Dio();

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
    } catch (e) {
      return [];
    }
  }
}