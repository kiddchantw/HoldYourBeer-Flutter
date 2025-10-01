import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/custom_bottom_nav.dart';
import '../../beer_tracking/screens/beer_list_screen.dart';
import '../../beer_tracking/widgets/add_beer_sheet.dart';
import '../../dashboard/screens/chart_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/navigation/navigation_provider.dart';

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          ChartScreen(),    // 0 - 圖表統計
          BeerListScreen(), // 1 - 啤酒列表 (預設頁面，但不會直接導航到此)
          ProfileScreen(),  // 2 - 會員資料
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: CustomBottomNav(
          currentIndex: currentIndex,
          onTap: (index) {
            // 如果點擊圖表或會員按鈕，切換頁面
            if (index == 0 || index == 2) {
              ref.read(navigationProvider.notifier).setIndex(index);
            }
            // 中間按鈕(index 1)由 onAddBeer 處理
          },
          onAddBeer: () {
            // 切換到啤酒列表頁面並顯示新增對話框
            ref.read(navigationProvider.notifier).setIndex(1);
            _showAddBeerDialog(context);
          },
        ),
      ),
    );
  }

  void _showAddBeerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => const AddBeerSheet(),
    );
  }
}

