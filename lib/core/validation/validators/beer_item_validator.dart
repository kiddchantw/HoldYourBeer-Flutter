import '../validator.dart';
import '../validation_result.dart';
import '../../../features/beer_tracking/models/beer_item.dart';

/// Validator for BeerItem model
class BeerItemValidator extends JsonValidator<BeerItem> {
  @override
  ValidationResult validate(BeerItem data) {
    final errors = <ValidationError>[];

    // Validate ID
    if (data.id <= 0) {
      errors.add(const ValidationError(
        field: 'id',
        message: 'Beer ID must be positive',
        code: 'INVALID_ID',
      ));
    }

    // Validate brand
    if (data.brand.isEmpty) {
      errors.add(const ValidationError(
        field: 'brand',
        message: 'Brand cannot be empty',
        code: 'REQUIRED_FIELD',
      ));
    } else if (data.brand.length > 100) {
      errors.add(const ValidationError(
        field: 'brand',
        message: 'Brand must be at most 100 characters',
        code: 'MAX_LENGTH',
      ));
    }

    // Validate name
    if (data.name.isEmpty) {
      errors.add(const ValidationError(
        field: 'name',
        message: 'Name cannot be empty',
        code: 'REQUIRED_FIELD',
      ));
    } else if (data.name.length > 200) {
      errors.add(const ValidationError(
        field: 'name',
        message: 'Name must be at most 200 characters',
        code: 'MAX_LENGTH',
      ));
    }

    // Validate count
    if (data.count < 0) {
      errors.add(const ValidationError(
        field: 'tasting_count',
        message: 'Tasting count cannot be negative',
        code: 'INVALID_VALUE',
      ));
    }

    // Validate style (optional but if present, check length)
    if (data.style != null && data.style!.length > 100) {
      errors.add(const ValidationError(
        field: 'style',
        message: 'Style must be at most 100 characters',
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
      validateRequired(json, 'name'),
      validateType<String>(json, 'name', String),
      validateStringLength(json, 'name', minLength: 1, maxLength: 200),
      // Brand might be optional in some API responses, using fallback '' in fromJson
      validateType<String>(json, 'brand', String),
      validateStringLength(json, 'brand', maxLength: 100),
      // tasting_count is optional with default 0
      validateType<int>(json, 'tasting_count', int),
      // style is optional
      validateType<String>(json, 'style', String),
      validateStringLength(json, 'style', maxLength: 100),
    ]);

    // Validate ID range
    if (json['id'] != null && json['id'] is int) {
      final id = json['id'] as int;
      if (id <= 0) {
        errors.add(const ValidationError(
          field: 'id',
          message: 'Beer ID must be positive',
          code: 'INVALID_ID',
        ));
      }
    }

    // Validate tasting_count range
    if (json['tasting_count'] != null && json['tasting_count'] is int) {
      final count = json['tasting_count'] as int;
      if (count < 0) {
        errors.add(const ValidationError(
          field: 'tasting_count',
          message: 'Tasting count cannot be negative',
          code: 'INVALID_VALUE',
        ));
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}

/// Validator for a list of BeerItems
class BeerListValidator extends JsonValidator<List<BeerItem>> {
  final BeerItemValidator _itemValidator = BeerItemValidator();

  @override
  ValidationResult validate(List<BeerItem> data) {
    final errors = <ValidationError>[];

    for (var i = 0; i < data.length; i++) {
      final itemValidation = _itemValidator.validate(data[i]);
      if (!itemValidation.isValid) {
        // Prefix errors with array index
        for (final error in itemValidation.errors) {
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
    // This method is for validating a JSON object
    // For list validation, we expect the top-level to be a list
    throw UnimplementedError(
      'Use validateJsonList for list validation',
    );
  }

  /// Validates a JSON array of beer items
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

      final itemValidation = _itemValidator.validateJson(item);
      if (!itemValidation.isValid) {
        for (final error in itemValidation.errors) {
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
