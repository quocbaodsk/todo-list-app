class ApiError {
  final String message;
  final int status;

  ApiError({
    required this.status,
    required this.message,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      status: json['status'] ?? 500,
      message: json['message'] ?? 'An unexpected error occurred',
    );
  }

  @override
  String toString() => message;
}

class ApiException implements Exception {
  final ApiError error;

  ApiException(this.error);

  @override
  String toString() => error.toString();
}