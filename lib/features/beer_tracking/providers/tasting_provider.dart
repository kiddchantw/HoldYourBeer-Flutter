import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_logger.dart';
import '../repositories/beer_repository.dart';
import 'beer_repository_provider.dart';

// 品嚐記錄 Provider - 根據啤酒 ID 獲取記錄
final tastingLogsProvider = FutureProvider.family<List<TastingLog>, int>((ref, beerId) async {
  final repository = ref.read(beerRepositoryProvider);
  return await repository.getTastingLogs(beerId);
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
    final repository = ref.read(beerRepositoryProvider);
    try {
      await repository.addTastingRecord(beerId, note);
      // 刷新品嚐記錄列表
      ref.invalidate(tastingLogsProvider(beerId));
    } catch (e, stack) {
      logger.e('Error in addTastingRecord', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // 增加啤酒計數
  Future<void> incrementBeer(int beerId) async {
    final repository = ref.read(beerRepositoryProvider);
    try {
      await repository.incrementBeerCount(beerId);
      // 刷新品嚐記錄列表和啤酒清單
      ref.invalidate(tastingLogsProvider(beerId));
      ref.invalidate(beerListProvider);
    } catch (e, stack) {
      logger.e('Error in incrementBeer', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // 減少啤酒計數
  Future<void> decrementBeer(int beerId) async {
    final repository = ref.read(beerRepositoryProvider);
    try {
      await repository.decrementBeerCount(beerId);
      // 刷新品嚐記錄列表和啤酒清單
      ref.invalidate(tastingLogsProvider(beerId));
      ref.invalidate(beerListProvider);
    } catch (e, stack) {
      logger.e('Error in decrementBeer', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
