import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/themes/beer_colors.dart';
import '../../../shared/widgets/background/background.dart';
import '../../../widgets/brand_pie_chart.dart';
import '../../../models/chart_data.dart';
import '../../charts/providers/chart_provider.dart';

class ChartScreen extends ConsumerWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataAsync = ref.watch(chartDataProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '圖表統計',
          style: TextStyle(
            color: BeerColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BeerGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 統計卡片
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15.r,
                    offset: Offset(0, 8.h),
                  ),
                  BoxShadow(
                    color: BeerColors.primaryAmber300.withOpacity(0.1),
                    blurRadius: 20.r,
                    offset: Offset(0, 4.h),
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

            // 品牌圓餅圖區域
            chartDataAsync.when(
              data: (data) => _buildChartSection(data),
              loading: () => _buildLoadingChart(),
              error: (error, stack) => _buildErrorChart(),
            ),

            SizedBox(height: 24.h),

            // 圖例區域
            chartDataAsync.when(
              data: (data) => data.isNotEmpty ? _buildLegendSection(data) : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildChartSection(List<ChartData> data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: BeerColors.primaryAmber300.withOpacity(0.1),
            blurRadius: 20.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '品牌消費分布',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: BeerColors.textDark,
            ),
          ),
          SizedBox(height: 20.h),
          if (data.isNotEmpty)
            BrandPieChart(
              data: data,
              height: 280.h,
            )
          else
            _buildEmptyChart(),
        ],
      ),
    );
  }

  Widget _buildLoadingChart() {
    return Container(
      width: double.infinity,
      height: 300.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: BeerColors.primaryAmber300.withOpacity(0.1),
            blurRadius: 20.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(BeerColors.primaryAmber500),
            ),
            SizedBox(height: 16.h),
            Text(
              '載入圖表數據中...',
              style: TextStyle(
                fontSize: 16.sp,
                color: BeerColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorChart() {
    return Container(
      width: double.infinity,
      height: 300.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: BeerColors.primaryAmber300.withOpacity(0.1),
            blurRadius: 20.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: BeerColors.gray400,
            ),
            SizedBox(height: 16.h),
            Text(
              '載入圖表失敗',
              style: TextStyle(
                fontSize: 16.sp,
                color: BeerColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 280.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64.sp,
              color: BeerColors.gray400,
            ),
            SizedBox(height: 16.h),
            Text(
              '暫無數據',
              style: TextStyle(
                fontSize: 16.sp,
                color: BeerColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendSection(List<ChartData> data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: BeerColors.primaryAmber300.withOpacity(0.1),
            blurRadius: 20.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '品牌詳情',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: BeerColors.textDark,
            ),
          ),
          SizedBox(height: 16.h),
          ChartLegend(data: data),
        ],
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

}