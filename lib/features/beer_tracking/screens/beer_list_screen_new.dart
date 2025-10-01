import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/themes/beer_colors.dart';

// 簡化的啤酒數據模型
class BeerItem {
  final String id;
  final String brand;
  final String name;
  int count;

  BeerItem({
    required this.id,
    required this.brand,
    required this.name,
    required this.count,
  });
}

// 啤酒列表狀態管理
final beerListProvider = StateNotifierProvider<BeerListNotifier, List<BeerItem>>((ref) {
  return BeerListNotifier();
});

class BeerListNotifier extends StateNotifier<List<BeerItem>> {
  BeerListNotifier() : super([
    BeerItem(id: '1', brand: 'BrewDog', name: 'Punk IPA', count: 14),
    BeerItem(id: '2', brand: 'Taiwan Beer', name: 'Golden', count: 3),
  ]);

  void incrementBeer(String id) {
    state = [
      for (final beer in state)
        if (beer.id == id)
          BeerItem(id: beer.id, brand: beer.brand, name: beer.name, count: beer.count + 1)
        else
          beer,
    ];
  }

  void decrementBeer(String id) {
    state = [
      for (final beer in state)
        if (beer.id == id && beer.count > 0)
          BeerItem(id: beer.id, brand: beer.brand, name: beer.name, count: beer.count - 1)
        else
          beer,
    ];
  }

  void addBeer(String brand, String name) {
    final newBeer = BeerItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      brand: brand,
      name: name,
      count: 1,
    );
    state = [...state, newBeer];
  }
}

class BeerListScreen extends ConsumerWidget {
  const BeerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beerList = ref.watch(beerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的啤酒'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // 分享功能
            },
          ),
        ],
      ),
      body: beerList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_bar,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '還沒有啤酒記錄',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '點擊右下角的 + 來新增你的第一杯啤酒',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: beerList.length,
              itemBuilder: (context, index) {
                final beer = beerList[index];
                return _buildBeerCard(context, ref, beer);
              },
            ),
    );
  }

  Widget _buildBeerCard(BuildContext context, WidgetRef ref, BeerItem beer) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // 啤酒圖標
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: BeerColors.primaryAmber500.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.local_bar,
              color: BeerColors.primaryAmber500,
              size: 24.sp,
            ),
          ),

          SizedBox(width: 12.w),

          // 啤酒信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beer.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: BeerColors.textDark,
                  ),
                ),
                Text(
                  beer.brand,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: BeerColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // 數量顯示
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: BeerColors.info800.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '${beer.count}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: BeerColors.info800,
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // 控制按鈕
          Column(
            children: [
              // 增加按鈕
              GestureDetector(
                onTap: () {
                  ref.read(beerListProvider.notifier).incrementBeer(beer.id);
                },
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: BeerColors.success700,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // 減少按鈕
              GestureDetector(
                onTap: () {
                  if (beer.count > 0) {
                    ref.read(beerListProvider.notifier).decrementBeer(beer.id);
                  }
                },
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: beer.count > 0
                        ? BeerColors.error700
                        : BeerColors.gray400,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: 8.w),

          // 歷史按鈕
          GestureDetector(
            onTap: () {
              // 顯示歷史記錄
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${beer.brand} ${beer.name} 的歷史記錄'),
                ),
              );
            },
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: BeerColors.primaryAmber500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.history,
                color: BeerColors.primaryAmber500,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}