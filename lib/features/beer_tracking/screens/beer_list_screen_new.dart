import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/themes/beer_colors.dart';
import 'beer_detail_screen_api.dart';
import '../providers/tasting_provider.dart';

// 簡化的啤酒數據模型
class BeerItem {
  final int id;
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

// 搜尋查詢狀態
final searchQueryProvider = StateProvider<String>((ref) => '');

// 過濾後的啤酒清單
final filteredBeerListProvider = Provider<List<BeerItem>>((ref) {
  final beerList = ref.watch(beerListProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isEmpty) {
    return beerList;
  }

  return beerList.where((beer) {
    final query = searchQuery.toLowerCase();
    return beer.name.toLowerCase().contains(query) ||
           beer.brand.toLowerCase().contains(query);
  }).toList();
});

class BeerListNotifier extends StateNotifier<List<BeerItem>> {
  BeerListNotifier() : super([
    BeerItem(id: 1, brand: 'BrewDog', name: 'Punk IPA', count: 14),
    BeerItem(id: 2, brand: 'Taiwan Beer', name: 'Golden', count: 3),
  ]);

  void incrementBeer(int id) {
    state = [
      for (final beer in state)
        if (beer.id == id)
          BeerItem(id: beer.id, brand: beer.brand, name: beer.name, count: beer.count + 1)
        else
          beer,
    ];
  }

  void decrementBeer(int id) {
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
      id: DateTime.now().millisecondsSinceEpoch,
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
    final beerList = ref.watch(filteredBeerListProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: searchQuery.isEmpty
          ? const Text('我的啤酒')
          : Text('搜尋結果: $searchQuery'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            _showSearchDialog(context, ref);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // 刷新頁面並清除搜尋
              ref.read(searchQueryProvider.notifier).state = '';
              ref.invalidate(beerListProvider);
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