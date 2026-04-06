/// API Response Wrapper
/// Standard response model matching backend format:
/// { "status": "success"/"error", "message": "...", "data": {...} }
class ApiResponse<T> {
  final String status; // "success" or "error"
  final String message;
  final T? data;
  final List<ValidationError>? validationErrors;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.validationErrors,
  });

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';
  bool get hasValidationErrors => validationErrors != null && validationErrors!.isNotEmpty;

  // Factory from JSON response
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    List<ValidationError>? validationErrors;
    if (json['data'] is List) {
      validationErrors = (json['data'] as List)
          .map((e) => ValidationError.fromJson(e))
          .toList();
    }

    T? parsedData;
    if (fromJson != null && json['data'] is Map<String, dynamic>) {
      parsedData = fromJson(json['data']);
    } else if (json['data'] is Map<String, dynamic>) {
      parsedData = json['data'] as T;
    } else if (json['data'] is List) {
      parsedData = json['data'] as T;
    }

    return ApiResponse<T>(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
      data: parsedData,
      validationErrors: validationErrors,
    );
  }

  // Extract data list from JSON response
  static List<T> listFromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json['data'] is! List) return [];
    return (json['data'] as List)
        .whereType<Map<String, dynamic>>()
        .map((e) => fromJson(e))
        .toList();
  }

  @override
  String toString() {
    return 'ApiResponse(status: $status, message: $message, data: $data)';
  }
}

/// Validation Error Model
class ValidationError {
  final String? field;
  final String message;

  ValidationError({this.field, required this.message});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'],
      message: json['message'] ?? '',
    );
  }

  @override
  String toString() {
    return 'ValidationError(field: $field, message: $message)';
  }
}
