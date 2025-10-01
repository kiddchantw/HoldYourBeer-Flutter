import 'package:flutter/material.dart';

class ChartData {
  final String label;
  final double value;
  final Color color;

  const ChartData({
    required this.label,
    required this.value,
    required this.color,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      color: Color(json['color'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'color': color.value,
    };
  }
}

class BrandAnalyticsData {
  final String brandName;
  final int totalConsumption;

  const BrandAnalyticsData({
    required this.brandName,
    required this.totalConsumption,
  });

  factory BrandAnalyticsData.fromJson(Map<String, dynamic> json) {
    return BrandAnalyticsData(
      brandName: json['brandName'] as String,
      totalConsumption: json['totalConsumption'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brandName': brandName,
      'totalConsumption': totalConsumption,
    };
  }
}

class BrandAnalyticsResponse {
  final List<BrandAnalyticsData> data;
  final bool success;
  final String? message;

  const BrandAnalyticsResponse({
    required this.data,
    this.success = true,
    this.message,
  });

  factory BrandAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return BrandAnalyticsResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => BrandAnalyticsData.fromJson(item as Map<String, dynamic>))
          .toList(),
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'success': success,
      'message': message,
    };
  }
}