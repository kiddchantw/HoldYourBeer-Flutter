import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/themes/beer_colors.dart';
import '../../../shared/widgets/background/background.dart';
import '../models/beer_item.dart';
import '../providers/beer_repository_provider.dart';
import 'beer_detail_screen_api.dart';
import '../providers/tasting_provider.dart';

class BeerListScreen extends ConsumerWidget {
  const BeerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beerListAsync = ref.watch(filteredBeerListProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          searchQuery.isEmpty ? '我的啤酒' : '搜尋結果: $searchQuery',
          style: TextStyle(
            color: BeerColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.search,
            color: BeerColors.primaryAmber600,
          ),
          onPressed: () {
            _showSearchDialog(context, ref);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: BeerColors.primaryAmber600,
            ),
            onPressed: () {
              // 刷新頁面並清除搜尋
              ref.read(searchQueryProvider.notifier).state = '';
              ref.read(beerListProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: BeerGradientBackground(
        child: SafeArea(
          child: beerListAsync.when(
            data: (beerList) => beerList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: beerList.length,
                    itemBuilder: (context, index) {
                      final beer = beerList[index];
                      return _buildBeerCard(context, ref, beer);
                    },
                  ),
            loading: () => Center(
              child: CircularProgressIndicator(
                color: BeerColors.primaryAmber500,
              ),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: BeerColors.error700,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '載入失敗',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: BeerColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: BeerColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(beerListProvider.notifier).refresh();
                    },
                    child: Text('重試'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32.w),
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_bar,
              size: 64.sp,
              color: BeerColors.primaryAmber400,
            ),
            SizedBox(height: 16.h),
            Text(
              '還沒有啤酒記錄',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: BeerColors.textDark,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '點擊右下角的 + 來新增你的第一杯啤酒',
              style: TextStyle(
                fontSize: 14.sp,
                color: BeerColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeerCard(BuildContext context, WidgetRef ref, BeerItem beer) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BeerDetailScreen(
              beerId: beer.id.toString(),
              brand: beer.brand,
              name: beer.name,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15.r,
              offset: Offset(0, 4.h),
            ),
            BoxShadow(
              color: BeerColors.primaryAmber300.withOpacity(0.1),
              blurRadius: 20.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
        children: [
          // 數量顯示圓圈
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: BeerColors.info800,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Center(
              child: Text(
                '${beer.count}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // 啤酒信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beer.brand,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: BeerColors.textMuted,
                  ),
                ),
                Text(
                  beer.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: BeerColors.textDark,
                  ),
                ),
              ],
            ),
          ),


          // 控制按鈕
          Row(
            children: [
              // 增加按鈕
              GestureDetector(
                onTap: () async {
                  try {
                    // 先更新本地狀態（樂觀更新）
                    ref.read(beerListProvider.notifier).incrementBeer(beer.id);
                    // 呼叫 API
                    await ref.read(tastingActionsProvider).incrementBeer(beer.id);
                  } catch (e) {
                    // 如果 API 失敗，回復本地狀態
                    ref.read(beerListProvider.notifier).decrementBeer(beer.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('增加失敗: $e')),
                    );
                  }
                },
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: BeerColors.success700,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 27.sp,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // 減少按鈕
              GestureDetector(
                onTap: () async {
                  if (beer.count > 0) {
                    try {
                      // 先更新本地狀態（樂觀更新）
                      ref.read(beerListProvider.notifier).decrementBeer(beer.id);
                      // 呼叫 API
                      await ref.read(tastingActionsProvider).decrementBeer(beer.id);
                    } catch (e) {
                      // 如果 API 失敗，回復本地狀態
                      ref.read(beerListProvider.notifier).incrementBeer(beer.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('減少失敗: $e')),
                      );
                    }
                  }
                },
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: beer.count > 0
                        ? BeerColors.error700
                        : BeerColors.gray400,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 27.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: 8.w),

          // 歷史按鈕
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BeerDetailScreen(
                    beerId: beer.id.toString(),
                    brand: beer.brand,
                    name: beer.name,
                  ),
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
    ));
  }
}

// 搜尋對話框功能
void _showSearchDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => SearchDialog(ref: ref),
  );
}

class SearchDialog extends StatefulWidget {
  final WidgetRef ref;

  const SearchDialog({Key? key, required this.ref}) : super(key: key);

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('搜尋啤酒'),
      content: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: '輸入啤酒名稱或品牌...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            final searchText = searchController.text.trim();
            widget.ref.read(searchQueryProvider.notifier).state = searchText;
            Navigator.of(context).pop();
            if (searchText.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('搜尋: $searchText'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text('確定'),
        ),
      ],
    );
  }
}