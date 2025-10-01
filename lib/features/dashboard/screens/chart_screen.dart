import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/themes/beer_colors.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('圖表統計'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 統計卡片
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '本月統計',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: BeerColors.textDark,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      _buildStatItem('總數量', '12', BeerColors.primaryAmber500),
                      SizedBox(width: 20.w),
                      _buildStatItem('品牌數', '5', BeerColors.success700),
                      SizedBox(width: 20.w),
                      _buildStatItem('新嘗試', '3', BeerColors.info800),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // 圖表區域 (佔位符)
            Container(
              width: double.infinity,
              height: 300.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 64.sp,
                      color: BeerColors.gray400,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '圖表功能開發中...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: BeerColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // 快速統計
            Text(
              '最愛品牌',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: BeerColors.textDark,
              ),
            ),
            SizedBox(height: 12.h),
            _buildBrandItem('台灣啤酒', 5),
            _buildBrandItem('海尼根', 3),
            _buildBrandItem('青島啤酒', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: BeerColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildBrandItem(String brand, int count) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: BeerColors.gray100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            brand,
            style: TextStyle(
              fontSize: 14.sp,
              color: BeerColors.textDark,
            ),
          ),
          Text(
            '$count 次',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: BeerColors.primaryAmber500,
            ),
          ),
        ],
      ),
    );
  }
}