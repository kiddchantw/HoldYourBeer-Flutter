import 'validation_result.dart';

/// Abstract base class for validators
abstract class Validator<T> {
  /// Validates the given data
  ValidationResult validate(T data);

  /// Validates and throws an exception if validation fails
  void validateOrThrow(T data) {
    final result = validate(data);
    if (!result.isValid) {
      throw ValidationException(result);
    }
  }

  /// Validates data from JSON
  ValidationResult validateJson(Map<String, dynamic> json);
}

/// Base class for JSON validators with common validation methods
abstract class JsonValidator<T> extends Validator<T> {
  /// Validates that a required field exists and is not null
  ValidationError? validateRequired(
    Map<String, dynamic> json,
    String field,
  ) {
    if (!json.containsKey(field) || json[field] == null) {
      return ValidationError(
        field: field,
        message: 'Field "$field" is required',
        code: 'REQUIRED_FIELD',
      );
    }
    return null;
  }

  /// Validates that a field is of the expected type
  ValidationError? validateType<E>(
    Map<String, dynamic> json,
    String field,
    Type expectedType,
  ) {
    if (json[field] == null) return null;

    final value = json[field];
    bool isValid = false;

    switch (expectedType) {
      case String:
        isValid = value is String;
        break;
      case int:
        isValid = value is int;
        break;
      case double:
        isValid = value is double || value is int;
        break;
      case bool:
        isValid = value is bool;
        break;
      case Map:
        isValid = value is Map;
        break;
      case List:
        isValid = value is List;
        break;
      default:
        isValid = value.runtimeType == expectedType;
    }

    if (!isValid) {
      return ValidationError(
        field: field,
        message: 'Field "$field" must be of type $expectedType, got ${value.runtimeType}',
        code: 'INVALID_TYPE',
      );
    }
    return null;
  }

  /// Validates string format (email, URL, etc.)
  ValidationError? validateStringFormat(
    Map<String, dynamic> json,
    String field,
    RegExp pattern,
    String formatName,
  ) {
    if (json[field] == null) return null;

    final value = json[field];
    if (value is! String) {
      return ValidationError(
        field: field,
        message: 'Field "$field" must be a string',
        code: 'INVALID_TYPE',
      );
    }

    if (!pattern.hasMatch(value)) {
      return ValidationError(
        field: field,
        message: 'Field "$field" must be a valid $formatName',
        code: 'INVALID_FORMAT',
      );
    }
    return null;
  }

  /// Validates string length
  ValidationError? validateStringLength(
    Map<String, dynamic> json,
    String field, {
    int? minLength,
    int? maxLength,
  }) {
    if (json[field] == null) return null;

    final value = json[field];
    if (value is! String) return null;

    if (minLength != null && value.length < minLength) {
      return ValidationError(
        field: field,
        message: 'Field "$field" must be at least $minLength characters',
        code: 'MIN_LENGTH',
      );
    }

    if (maxLength != null && value.length > maxLength) {
      return ValidationError(
        field: field,
        message: 'Field "$field" must be at most $maxLength characters',
        code: 'MAX_LENGTH',
      );
    }

    return null;
  }

  /// Validates numeric range
  ValidationError? validateNumericRange(
    Map<String, dynamic> json,
    String field, {
    num? min,
    num? max,
  }) {
    if (json[field] == null) return null;

    final value = json[field];
    if (value is! num) return null;

    if (min != null && value < min) {
      return ValidationError(
        field: field,
        message: 'Field "$field" must be at least $min',
        code: 'MIN_VALUE',
      );
    }

    if (max != null && value > max) {
      return ValidationError(
        field: field,
        message: 'Field "$field" must be at most $max',
        code: 'MAX_VALUE',
      );
    }

    return null;
  }

  /// Validates that a field's value is in a list of allowed values
  ValidationError? validateEnum(
    Map<String, dynamic> json,
    String field,
    List<dynamic> allowedValues,
  ) {
    if (json[field] == null) return null;

    final value = json[field];
    if (!allowedValues.contains(value)) {
      return ValidationError(
        field: field,
        message: 'Field "$field" must be one of: ${allowedValues.join(", ")}',
        code: 'INVALID_ENUM',
      );
    }

    return null;
  }

  /// Validates a list field
  ValidationError? validateList(
    Map<String, dynamic> json,
    String field, {
    int? minItems,
    int? maxItems,
  }) {
    if (json[field] == null) return null;

    final value = json[field];
    if (value is! List) {
      return ValidationError(
        field: field,
        message: 'Field "$field" must be a list',
        code: 'INVALID_TYPE',
      );
    }

    if (minItems != null && value.length < minItems) {
      return ValidationError(
        field: field,
        message: 'Field "$field" must contain at least $minItems items',
        code: 'MIN_ITEMS',
      );
    }

    if (maxItems != null && value.length > maxItems) {
      return ValidationError(
        field: field,
        message: 'Field "$field" must contain at most $maxItems items',
        code: 'MAX_ITEMS',
      );
    }

    return null;
  }

  /// Collects all validation errors, filtering out nulls
  List<ValidationError> collectErrors(List<ValidationError?> errors) {
    return errors.whereType<ValidationError>().toList();
  }
}
