import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/chart_data.dart';
import '../repositories/charts_repository.dart';

// Charts Repository Provider
final chartsRepositoryProvider = Provider<ChartsRepository>((ref) {
  return ChartsRepository();
});

// Chart Data Provider with color configuration
final chartDataProvider = FutureProvider<List<ChartData>>((ref) async {
  final repository = ref.read(chartsRepositoryProvider);
  final data = await repository.getBrandAnalytics();

  if (data.isEmpty) {
    // Return mock data for development if API fails
    return _getMockChartData();
  }

  // HoldYourBeer website matching color configuration
  final colors = [
    Color(0xFFFF6384), // rgba(255, 99, 132, 0.6)
    Color(0xFF36A2EB), // rgba(54, 162, 235, 0.6)
    Color(0xFFFFCE56), // rgba(255, 206, 86, 0.6)
    Color(0xFF4BC0C0), // rgba(75, 192, 192, 0.6)
    Color(0xFF9966FF), // rgba(153, 102, 255, 0.6)
    Color(0xFFFF9F40), // rgba(255, 159, 64, 0.6)
  ];

  // Apply colors to chart data
  return data.asMap().entries.map((entry) {
    final index = entry.key;
    final item = entry.value;
    return ChartData(
      label: item.label,
      value: item.value,
      color: colors[index % colors.length],
    );
  }).toList();
});

// Statistics Provider
final statisticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.read(chartsRepositoryProvider);
  return await repository.getStatistics();
});

// Mock data for development/fallback
List<ChartData> _getMockChartData() {
  final colors = [
    Color(0xFFFF6384),
    Color(0xFF36A2EB),
    Color(0xFFFFCE56),
    Color(0xFF4BC0C0),
    Color(0xFF9966FF),
    Color(0xFFFF9F40),
  ];

  final mockData = [
    {'brandName': 'Heineken', 'totalConsumption': 25},
    {'brandName': 'Budweiser', 'totalConsumption': 18},
    {'brandName': 'Corona', 'totalConsumption': 15},
    {'brandName': 'Stella Artois', 'totalConsumption': 12},
    {'brandName': 'Guinness', 'totalConsumption': 8},
    {'brandName': 'Carlsberg', 'totalConsumption': 5},
  ];

  return mockData.asMap().entries.map((entry) {
    final index = entry.key;
    final item = entry.value;
    return ChartData(
      label: item['brandName'] as String,
      value: (item['totalConsumption'] as int).toDouble(),
      color: colors[index % colors.length],
    );
  }).toList();
}
