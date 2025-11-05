import '../validator.dart';
import '../validation_result.dart';
import '../../../data/models/tasting_log.dart';

/// Validator for TastingLog model
class TastingLogValidator extends JsonValidator<TastingLog> {
  static const List<String> _validActions = ['increment', 'decrement', 'reset'];

  @override
  ValidationResult validate(TastingLog data) {
    final errors = <ValidationError>[];

    // Validate ID
    if (data.id <= 0) {
      errors.add(const ValidationError(
        field: 'id',
        message: 'Tasting log ID must be positive',
        code: 'INVALID_ID',
      ));
    }

    // Validate action
    if (data.action.isEmpty) {
      errors.add(const ValidationError(
        field: 'action',
        message: 'Action cannot be empty',
        code: 'REQUIRED_FIELD',
      ));
    } else if (!_validActions.contains(data.action)) {
      errors.add(ValidationError(
        field: 'action',
        message: 'Action must be one of: ${_validActions.join(", ")}',
        code: 'INVALID_ENUM',
      ));
    }

    // Validate tasted_at timestamp
    final tastedAtError = _validateTimestamp(data.tastedAt, 'tasted_at');
    if (tastedAtError != null) errors.add(tastedAtError);

    // Note is optional, but validate length if present
    if (data.note != null && data.note!.length > 500) {
      errors.add(const ValidationError(
        field: 'note',
        message: 'Note must be at most 500 characters',
        code: 'MAX_LENGTH',
      ));
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  @override
  ValidationResult validateJson(Map<String, dynamic> json) {
    final errors = collectErrors([
      validateRequired(json, 'id'),
      validateType<int>(json, 'id', int),
      validateRequired(json, 'action'),
      validateType<String>(json, 'action', String),
      validateEnum(json, 'action', _validActions),
      validateRequired(json, 'tasted_at'),
      validateType<String>(json, 'tasted_at', String),
      // note is optional
      validateType<String>(json, 'note', String),
      validateStringLength(json, 'note', maxLength: 500),
    ]);

    // Validate ID range
    if (json['id'] != null && json['id'] is int) {
      final id = json['id'] as int;
      if (id <= 0) {
        errors.add(const ValidationError(
          field: 'id',
          message: 'Tasting log ID must be positive',
          code: 'INVALID_ID',
        ));
      }
    }

    // Validate timestamp format
    if (json['tasted_at'] != null && json['tasted_at'] is String) {
      final timestampError = _validateTimestamp(
        json['tasted_at'] as String,
        'tasted_at',
      );
      if (timestampError != null) errors.add(timestampError);
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  ValidationError? _validateTimestamp(String timestamp, String field) {
    try {
      DateTime.parse(timestamp);
      return null;
    } catch (e) {
      return ValidationError(
        field: field,
        message: 'Invalid timestamp format',
        code: 'INVALID_TIMESTAMP',
      );
    }
  }
}

/// Validator for a list of TastingLogs
class TastingLogListValidator extends JsonValidator<List<TastingLog>> {
  final TastingLogValidator _logValidator = TastingLogValidator();

  @override
  ValidationResult validate(List<TastingLog> data) {
    final errors = <ValidationError>[];

    for (var i = 0; i < data.length; i++) {
      final logValidation = _logValidator.validate(data[i]);
      if (!logValidation.isValid) {
        // Prefix errors with array index
        for (final error in logValidation.errors) {
          errors.add(ValidationError(
            field: '[$i].${error.field}',
            message: error.message,
            code: error.code,
          ));
        }
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  @override
  ValidationResult validateJson(Map<String, dynamic> json) {
    throw UnimplementedError(
      'Use validateJsonList for list validation',
    );
  }

  /// Validates a JSON array of tasting logs
  ValidationResult validateJsonList(List<dynamic> jsonList) {
    final errors = <ValidationError>[];

    for (var i = 0; i < jsonList.length; i++) {
      final item = jsonList[i];
      if (item is! Map<String, dynamic>) {
        errors.add(ValidationError(
          field: '[$i]',
          message: 'List item must be a JSON object',
          code: 'INVALID_TYPE',
        ));
        continue;
      }

      final logValidation = _logValidator.validateJson(item);
      if (!logValidation.isValid) {
        for (final error in logValidation.errors) {
          errors.add(ValidationError(
            field: '[$i].${error.field}',
            message: error.message,
            code: error.code,
          ));
        }
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}
