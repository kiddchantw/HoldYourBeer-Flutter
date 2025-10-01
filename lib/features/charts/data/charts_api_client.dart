import 'package:dio/dio.dart';
import '../../../models/chart_data.dart';

class ChartsApiClient {
  final Dio _dio;

  ChartsApiClient(this._dio);

  Future<BrandAnalyticsResponse> getBrandAnalytics() async {
    try {
      final response = await _dio.get('/charts/brand-analytics');
      return BrandAnalyticsResponse.fromJson(response.data);
    } catch (e) {
      // 如果 API 調用失敗，返回模擬數據
      return const BrandAnalyticsResponse(
        data: [
          BrandAnalyticsData(brandName: 'Heineken', totalConsumption: 25),
          BrandAnalyticsData(brandName: 'Budweiser', totalConsumption: 18),
          BrandAnalyticsData(brandName: 'Corona', totalConsumption: 15),
          BrandAnalyticsData(brandName: 'Stella Artois', totalConsumption: 12),
          BrandAnalyticsData(brandName: 'Guinness', totalConsumption: 8),
          BrandAnalyticsData(brandName: 'Carlsberg', totalConsumption: 5),
        ],
        success: true,
        message: 'Mock data for development',
      );
    }
  }
}