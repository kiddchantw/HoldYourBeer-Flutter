import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../models/tasting_log.dart';

class BeerService {
  final ApiClient _apiClient = ApiClient();

  Future<List<TastingLog>> getTastingLogs(String beerId) async {
    final Dio dio = _apiClient.dio;
    final response = await dio.get('/beers/$beerId/tasting_logs');
    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data.map((e) => TastingLog.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load tasting logs');
  }
}



