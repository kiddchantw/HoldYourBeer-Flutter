import 'package:hive/hive.dart';

part 'beer_item.g.dart';

@HiveType(typeId: 0)
class BeerItem {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String brand;

  @HiveField(2)
  final String name;

  @HiveField(3)
  int count;

  @HiveField(4)
  final String? style;

  BeerItem({
    required this.id,
    required this.brand,
    required this.name,
    required this.count,
    this.style,
  });

  // From JSON factory for API response
  factory BeerItem.fromJson(Map<String, dynamic> json) {
    return BeerItem(
      id: json['id'] as int,
      brand: json['brand'] as String? ?? '',
      name: json['name'] as String,
      count: json['tasting_count'] as int? ?? 0,
      style: json['style'] as String?,
    );
  }

  // To JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'name': name,
      'tasting_count': count,
      if (style != null) 'style': style,
    };
  }

  BeerItem copyWith({
    int? id,
    String? brand,
    String? name,
    int? count,
    String? style,
  }) {
    return BeerItem(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      count: count ?? this.count,
      style: style ?? this.style,
    );
  }
}
