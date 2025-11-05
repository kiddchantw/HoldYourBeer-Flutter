import '../validator.dart';
import '../validation_result.dart';
import '../../models/auth_models.dart';

/// Validator for UserData model
class UserDataValidator extends JsonValidator<UserData> {
  static final _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  @override
  ValidationResult validate(UserData data) {
    final errors = <ValidationError>[];

    // Validate ID
    if (data.id <= 0) {
      errors.add(const ValidationError(
        field: 'id',
        message: 'User ID must be positive',
        code: 'INVALID_ID',
      ));
    }

    // Validate name
    if (data.name.isEmpty) {
      errors.add(const ValidationError(
        field: 'name',
        message: 'Name cannot be empty',
        code: 'REQUIRED_FIELD',
      ));
    } else if (data.name.length > 255) {
      errors.add(const ValidationError(
        field: 'name',
        message: 'Name must be at most 255 characters',
        code: 'MAX_LENGTH',
      ));
    }

    // Validate email
    if (data.email.isEmpty) {
      errors.add(const ValidationError(
        field: 'email',
        message: 'Email cannot be empty',
        code: 'REQUIRED_FIELD',
      ));
    } else if (!_emailRegex.hasMatch(data.email)) {
      errors.add(const ValidationError(
        field: 'email',
        message: 'Invalid email format',
        code: 'INVALID_FORMAT',
      ));
    }

    // Validate timestamps
    final createdAtError = _validateTimestamp(data.createdAt, 'created_at');
    if (createdAtError != null) errors.add(createdAtError);

    final updatedAtError = _validateTimestamp(data.updatedAt, 'updated_at');
    if (updatedAtError != null) errors.add(updatedAtError);

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
      validateStringLength(json, 'name', minLength: 1, maxLength: 255),
      validateRequired(json, 'email'),
      validateType<String>(json, 'email', String),
      validateStringFormat(json, 'email', _emailRegex, 'email'),
      validateRequired(json, 'created_at'),
      validateType<String>(json, 'created_at', String),
      validateRequired(json, 'updated_at'),
      validateType<String>(json, 'updated_at', String),
      // email_verified_at is optional
      validateType<String>(json, 'email_verified_at', String),
    ]);

    // Validate ID range
    if (json['id'] != null && json['id'] is int) {
      final id = json['id'] as int;
      if (id <= 0) {
        errors.add(const ValidationError(
          field: 'id',
          message: 'User ID must be positive',
          code: 'INVALID_ID',
        ));
      }
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

/// Validator for LoginResponse model
class LoginResponseValidator extends JsonValidator<LoginResponse> {
  final UserDataValidator _userValidator = UserDataValidator();

  @override
  ValidationResult validate(LoginResponse data) {
    final errors = <ValidationError>[];

    // Validate token
    if (data.token.isEmpty) {
      errors.add(const ValidationError(
        field: 'token',
        message: 'Token cannot be empty',
        code: 'REQUIRED_FIELD',
      ));
    }

    // Validate user data
    final userValidation = _userValidator.validate(data.user);
    if (!userValidation.isValid) {
      errors.addAll(userValidation.errors);
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  @override
  ValidationResult validateJson(Map<String, dynamic> json) {
    final errors = collectErrors([
      validateRequired(json, 'token'),
      validateType<String>(json, 'token', String),
      validateStringLength(json, 'token', minLength: 1),
      validateRequired(json, 'user'),
      validateType<Map>(json, 'user', Map),
    ]);

    // Validate nested user object
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      final userJson = json['user'] as Map<String, dynamic>;
      final userValidation = _userValidator.validateJson(userJson);
      if (!userValidation.isValid) {
        errors.addAll(userValidation.errors);
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}
