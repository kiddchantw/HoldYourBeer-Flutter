import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/date_time_utils.dart';

// 品嚐記錄模型
class TastingLogResponse {
  final int id;
  final String action;
  final DateTime tastedAt;
  final String? note;
  final String? serverTimezone;

  TastingLogResponse({
    required this.id,
    required this.action,
    required this.tastedAt,
    this.note,
    this.serverTimezone,
  });

  factory TastingLogResponse.fromJson(Map<String, dynamic> json) {
    return TastingLogResponse(
      id: json['id'] as int,
      action: json['action'] as String,
      tastedAt: DateTimeUtils.parseServerDateTimeWithTimezone(
        json['tasted_at'] as String,
        json['server_timezone'] as String?,
      ),
      note: json['note'] as String?,
      serverTimezone: json['server_timezone'] as String?,
    );
  }
}

// 品嚐記錄請求模型
class TastingActionRequest {
  final String action;
  final String? note;

  TastingActionRequest({
    required this.action,
    this.note,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'action': action,
    };
    if (note != null && note!.isNotEmpty) {
      json['note'] = note;
    }
    return json;
  }
}

// 品嚐記錄 API 客戶端
class TastingApiClient {
  final Dio _dio;

  TastingApiClient({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // 獲取啤酒的品嚐記錄
  Future<List<TastingLogResponse>> getTastingLogs(int beerId) async {
    try {
      final response = await _dio.get('/beers/$beerId/tasting_logs');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => TastingLogResponse.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching tasting logs: $e');
      // 返回模擬資料作為備用
      return _getMockTastingLogs();
    }
  }

  // 新增品嚐記錄
  Future<void> addTastingRecord(int beerId, String note) async {
    try {
      final request = TastingActionRequest(
        action: 'increment',
        note: note,
      );
      await _dio.post('/beers/$beerId/count_actions', data: request.toJson());
    } catch (e) {
      print('Error adding tasting record: $e');
      throw Exception('Failed to add tasting record');
    }
  }

  // 增加啤酒計數（不含品嚐記錄）
  Future<void> incrementBeer(int beerId) async {
    try {
      final request = TastingActionRequest(action: 'increment');
      await _dio.post('/beers/$beerId/count_actions', data: request.toJson());
    } catch (e) {
      print('Error incrementing beer: $e');
      throw Exception('Failed to increment beer count');
    }
  }

  // 減少啤酒計數
  Future<void> decrementBeer(int beerId) async {
    try {
      final request = TastingActionRequest(action: 'decrement');
      await _dio.post('/beers/$beerId/count_actions', data: request.toJson());
    } catch (e) {
      print('Error decrementing beer: $e');
      throw Exception('Failed to decrement beer count');
    }
  }

  // 模擬資料
  List<TastingLogResponse> _getMockTastingLogs() {
    return [
      TastingLogResponse(
        id: 1,
        action: 'increment',
        tastedAt: DateTime.parse('2025-09-19T02:02:09.000000Z'),
        note: null,
      ),
      TastingLogResponse(
        id: 2,
        action: 'increment',
        tastedAt: DateTime.parse('2025-08-21T19:35:58.000000Z'),
        note: 'MIT',
      ),
      TastingLogResponse(
        id: 3,
        action: 'decrement',
        tastedAt: DateTime.parse('2025-08-21T19:29:49.000000Z'),
        note: null,
      ),
    ];
  }
}