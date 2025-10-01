class TastingLog {
  final int id;
  final String action;
  final String tastedAt;
  final String? note;

  TastingLog({
    required this.id,
    required this.action,
    required this.tastedAt,
    this.note,
  });

  factory TastingLog.fromJson(Map<String, dynamic> json) {
    return TastingLog(
      id: json['id'] as int,
      action: json['action'] as String,
      tastedAt: json['tasted_at'] as String,
      note: json['note'] as String?,
    );
  }
}



