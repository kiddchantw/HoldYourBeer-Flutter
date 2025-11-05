import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/themes/beer_colors.dart';
import '../providers/beer_repository_provider.dart';

class AddBeerSheet extends ConsumerStatefulWidget {
  const AddBeerSheet({super.key});

  @override
  ConsumerState<AddBeerSheet> createState() => _AddBeerSheetState();
}

class _AddBeerSheetState extends ConsumerState<AddBeerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _nameController = TextEditingController();
  final _styleController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _nameController.dispose();
    _styleController.dispose();
    super.dispose();
  }

  Future<void> _handleAddBeer() async {
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState?.validate() ?? false) {
      final brandName = _brandController.text.trim();
      final name = _nameController.text.trim();
      final style = _styleController.text.trim();

      try {
        // 顯示載入指示器
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(
              color: BeerColors.primaryAmber500,
            ),
          ),
        );

        // 呼叫 API 創建新啤酒
        await ref.read(beerListProvider.notifier).addBeer(
          brand: brandName,
          name: name,
          style: style.isNotEmpty ? style : null,
        );

        // 關閉載入指示器
        if (mounted) Navigator.of(context).pop();

        // 關閉表單
        if (mounted) Navigator.of(context).pop();

        // 顯示成功訊息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.beerAdded),
              backgroundColor: BeerColors.success700,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // 關閉載入指示器
        if (mounted) Navigator.of(context).pop();

        // 顯示錯誤訊息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('新增失敗: ${e.toString()}'),
              backgroundColor: BeerColors.error700,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 頂部拖拽指示器
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: BeerColors.gray400,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // 標題
          Text(
            l10n.beerAddBeer,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          // 表單
          Form(
            key: _formKey,
            child: Column(
              children: [
                // 品牌名稱
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(
                    labelText: l10n.beerBrandName,
                    hintText: l10n.beerBrandNameHint,
                    prefixIcon: Icon(
                      Icons.business,
                      color: BeerColors.primaryAmber500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: BeerColors.primaryAmber500,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.beerValidationBrandRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                // 啤酒名稱
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.beerName,
                    hintText: l10n.beerNameHint,
                    prefixIcon: Icon(
                      Icons.local_bar,
                      color: BeerColors.primaryAmber500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: BeerColors.primaryAmber500,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.beerValidationNameRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                // 啤酒風格
                TextFormField(
                  controller: _styleController,
                  decoration: InputDecoration(
                    labelText: l10n.beerStyle,
                    hintText: l10n.beerStyleHint,
                    prefixIcon: Icon(
                      Icons.category,
                      color: BeerColors.primaryAmber500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: BeerColors.primaryAmber500,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.beerValidationStyleRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                // 按鈕區域
                Row(
                  children: [
                    // 取消按鈕
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          side: const BorderSide(
                            color: BeerColors.gray400,
                          ),
                        ),
                        child: Text(
                          l10n.commonCancel,
                          style: TextStyle(
                            color: BeerColors.gray600,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // 新增按鈕
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _handleAddBeer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BeerColors.success700,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          l10n.commonAdd,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}