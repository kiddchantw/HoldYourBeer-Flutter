import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/themes/beer_colors.dart';

class SimpleBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddBeer;

  const SimpleBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddBeer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 主要內容區域
          Row(
            children: [
              // 左側 - 圖表統計按鈕
              Expanded(
                child: _buildNavItem(
                  icon: Icons.home,
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),

              // 中間空白區域（為圓形按鈕留出空間）
              SizedBox(width: 80.w),

              // 右側 - 會員資料按鈕
              Expanded(
                child: _buildNavItem(
                  icon: Icons.person,
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ),
            ],
          ),
          // 中間的圓形凹陷區域和啤酒按鈕
          Positioned(
            left: 0,
            right: 0,
            top: 7.h,
            child: Center(
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.15), // 淺灰色背景
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: onAddBeer,
                    child: Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: const BoxDecoration(
                        color: BeerColors.primaryAmber500, // 使用啤酒主題色
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sports_bar, // 使用啤酒圖示
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Icon(
          icon,
          size: 24.sp,
          color: isActive ? BeerColors.primaryAmber500 : BeerColors.gray600,
        ),
      ),
    );
  }
}