import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';
import '../../../models/chart_data.dart';

/// Repository for managing charts and analytics data
///
/// Provides unified access to brand analytics and statistics
class ChartsRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get brand analytics data for pie chart
  ///
  /// Returns list of chart data with brand statistics
  /// Falls back to empty list on error (graceful degradation)
  Future<List<ChartData>> getBrandAnalytics() async {
    try {
      logger.i('Fetching brand analytics data');
      final response = await _apiClient.dio.get('/charts/brand-analytics');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        final chartData = data
            .map((json) => ChartData.fromJson(json as Map<String, dynamic>))
            .toList();
        logger.i('Successfully fetched ${chartData.length} brand analytics');
        return chartData;
      } else {
        logger.w('Unexpected status code: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e, stack) {
      logger.e('API error while fetching brand analytics', error: e, stackTrace: stack);
      // Graceful degradation - return empty data instead of crashing
      return [];
    } catch (e, stack) {
      logger.e('Unexpected error in getBrandAnalytics', error: e, stackTrace: stack);
      return [];
    }
  }

  /// Get overall statistics summary
  ///
  /// Returns aggregated statistics like total beers, total tastings, etc.
  Future<Map<String, int>> getStatistics() async {
    try {
      logger.i('Fetching statistics');
      final response = await _apiClient.dio.get('/statistics');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return {
          'total_beers': data['total_beers'] as int? ?? 0,
          'total_tastings': data['total_tastings'] as int? ?? 0,
          'unique_brands': data['unique_brands'] as int? ?? 0,
        };
      } else {
        logger.w('Unexpected status code: ${response.statusCode}');
        return {'total_beers': 0, 'total_tastings': 0, 'unique_brands': 0};
      }
    } on DioException catch (e, stack) {
      logger.e('API error while fetching statistics', error: e, stackTrace: stack);
      return {'total_beers': 0, 'total_tastings': 0, 'unique_brands': 0};
    } catch (e, stack) {
      logger.e('Unexpected error in getStatistics', error: e, stackTrace: stack);
      return {'total_beers': 0, 'total_tastings': 0, 'unique_brands': 0};
    }
  }
}
