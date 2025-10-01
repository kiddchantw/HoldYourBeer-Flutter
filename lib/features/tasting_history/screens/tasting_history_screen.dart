import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/tasting_log.dart';
import '../../../data/services/beer_service.dart';
import '../../../shared/themes/beer_colors.dart';

final tastingLogsProvider = FutureProvider.family<List<TastingLog>, String>((ref, beerId) async {
  final service = BeerService();
  return service.getTastingLogs(beerId);
});

class TastingHistoryScreen extends ConsumerWidget {
  final String beerId;
  final String? title;

  const TastingHistoryScreen({super.key, required this.beerId, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(tastingLogsProvider(beerId));

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? '歷史記錄'),
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('暫無歷史記錄'));
          }
          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: logs.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final log = logs[index];
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: BeerColors.gray100),
                ),
                child: Row(
                  children: [
                    Icon(
                      log.action == 'increment' ? Icons.add : Icons.remove,
                      color: log.action == 'increment' ? BeerColors.success700 : BeerColors.error700,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.tastedAt,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: BeerColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (log.note != null && log.note!.isNotEmpty)
                            Text(
                              log.note!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: BeerColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('載入失敗：$e')),
      ),
    );
  }
}



