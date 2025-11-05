import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tasting_api_client.dart';
import '../../../core/utils/app_logger.dart';

// 品嚐記錄 API 客戶端 Provider
final tastingApiClientProvider = Provider<TastingApiClient>((ref) {
  return TastingApiClient();
});

// 品嚐記錄 Provider - 根據啤酒 ID 獲取記錄
final tastingLogsProvider = FutureProvider.family<List<TastingLogResponse>, int>((ref, beerId) async {
  final apiClient = ref.read(tastingApiClientProvider);
  return await apiClient.getTastingLogs(beerId);
});

// 品嚐記錄操作 Provider
final tastingActionsProvider = Provider<TastingActions>((ref) {
  return TastingActions(ref);
});

class TastingActions {
  final Ref ref;

  TastingActions(this.ref);

  // 新增品嚐記錄
  Future<void> addTastingRecord(int beerId, String note) async {
    final apiClient = ref.read(tastingApiClientProvider);
    try {
      await apiClient.addTastingRecord(beerId, note);
      // 刷新品嚐記錄列表
      ref.invalidate(tastingLogsProvider(beerId));
    } catch (e, stack) {
      logger.e('Error in addTastingRecord', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // 增加啤酒計數
  Future<void> incrementBeer(int beerId) async {
    final apiClient = ref.read(tastingApiClientProvider);
    try {
      await apiClient.incrementBeer(beerId);
      // 刷新品嚐記錄列表
      ref.invalidate(tastingLogsProvider(beerId));
    } catch (e, stack) {
      logger.e('Error in incrementBeer', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // 減少啤酒計數
  Future<void> decrementBeer(int beerId) async {
    final apiClient = ref.read(tastingApiClientProvider);
    try {
      await apiClient.decrementBeer(beerId);
      // 刷新品嚐記錄列表
      ref.invalidate(tastingLogsProvider(beerId));
    } catch (e, stack) {
      logger.e('Error in decrementBeer', error: e, stackTrace: stack);
      rethrow;
    }
  }
}