/// Represents the result of a validation operation
class ValidationResult {
  /// Whether the validation passed
  final bool isValid;

  /// List of validation errors (empty if valid)
  final List<ValidationError> errors;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  /// Creates a successful validation result
  factory ValidationResult.success() {
    return const ValidationResult(isValid: true);
  }

  /// Creates a failed validation result with errors
  factory ValidationResult.failure(List<ValidationError> errors) {
    return ValidationResult(
      isValid: false,
      errors: errors,
    );
  }

  /// Creates a failed validation result with a single error
  factory ValidationResult.singleError(String field, String message) {
    return ValidationResult(
      isValid: false,
      errors: [ValidationError(field: field, message: message)],
    );
  }

  /// Combines multiple validation results
  static ValidationResult combine(List<ValidationResult> results) {
    final allErrors = <ValidationError>[];

    for (final result in results) {
      if (!result.isValid) {
        allErrors.addAll(result.errors);
      }
    }

    return allErrors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(allErrors);
  }

  /// Returns a formatted error message
  String get errorMessage {
    if (isValid) return '';
    return errors.map((e) => '${e.field}: ${e.message}').join(', ');
  }

  @override
  String toString() {
    return isValid
        ? 'ValidationResult(isValid: true)'
        : 'ValidationResult(isValid: false, errors: ${errors.length})';
  }
}

/// Represents a single validation error
class ValidationError {
  /// The field that failed validation
  final String field;

  /// The error message
  final String message;

  /// Error code for programmatic handling
  final String? code;

  const ValidationError({
    required this.field,
    required this.message,
    this.code,
  });

  @override
  String toString() => 'ValidationError(field: $field, message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationError &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => field.hashCode ^ message.hashCode ^ code.hashCode;
}

/// Exception thrown when validation fails
class ValidationException implements Exception {
  final ValidationResult result;

  ValidationException(this.result);

  @override
  String toString() => 'ValidationException: ${result.errorMessage}';
}
