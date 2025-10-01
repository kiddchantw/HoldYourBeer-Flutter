class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  ApiResponse({
    this.data,
    this.message,
    this.success = true,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {
      'data': data != null ? toJsonT(data as T) : null,
      'message': message,
      'success': success,
    };
  }

  factory ApiResponse.success(T data, {String? message}) => ApiResponse(
        data: data,
        message: message,
        success: true,
      );

  factory ApiResponse.error(String message) => ApiResponse(
        message: message,
        success: false,
      );
}