# Data Validation Layer

## 概述

資料驗證層提供了一個輕量級但功能完整的 API 回應驗證框架，確保從後端接收的資料符合預期格式和業務規則。

## 架構

```
lib/core/validation/
├── validation_result.dart        # 驗證結果類
├── validator.dart                # 抽象驗證器基類與通用驗證方法
├── validators/
│   ├── user_data_validator.dart  # 使用者資料驗證器
│   ├── beer_item_validator.dart  # 啤酒項目驗證器
│   └── tasting_log_validator.dart # 品嚐記錄驗證器
└── README.md                     # 本文件
```

## 核心組件

### ValidationResult

表示驗證操作的結果，包含：
- `isValid`: 驗證是否通過
- `errors`: 驗證錯誤列表
- `errorMessage`: 格式化的錯誤訊息

```dart
final result = validator.validateJson(jsonData);
if (!result.isValid) {
  print(result.errorMessage);
  // 或逐一處理錯誤
  for (final error in result.errors) {
    print('${error.field}: ${error.message}');
  }
}
```

### ValidationError

表示單一驗證錯誤：
- `field`: 失敗的欄位名稱
- `message`: 錯誤訊息
- `code`: 錯誤代碼（可選，用於程式化處理）

### ValidationException

當驗證失敗時拋出的異常，包含 `ValidationResult`。

## 使用方法

### 基本使用

#### 1. 驗證 JSON 回應

```dart
import 'package:hold_your_beer/core/validation/validators/user_data_validator.dart';
import 'package:hold_your_beer/core/validation/validation_result.dart';

final validator = UserDataValidator();

// 驗證 JSON 資料
final jsonData = {
  'id': 1,
  'name': 'John Doe',
  'email': 'john@example.com',
  'created_at': '2025-01-01T00:00:00Z',
  'updated_at': '2025-01-01T00:00:00Z',
};

final result = validator.validateJson(jsonData);

if (result.isValid) {
  // 資料有效，可以安全解析
  final userData = UserData.fromJson(jsonData);
} else {
  // 處理驗證錯誤
  print('Validation failed: ${result.errorMessage}');
}
```

#### 2. 驗證物件實例

```dart
final userData = UserData.fromJson(jsonData);
final result = validator.validate(userData);

if (!result.isValid) {
  // 物件不符合業務規則
  throw ValidationException(result);
}
```

#### 3. 驗證並拋出異常

```dart
try {
  validator.validateOrThrow(userData);
  // 驗證通過，繼續處理
} on ValidationException catch (e) {
  print('Validation failed: ${e.result.errorMessage}');
}
```

### 在 Repository 中整合

```dart
import 'package:hold_your_beer/core/validation/validators/beer_item_validator.dart';
import 'package:hold_your_beer/core/validation/validation_result.dart';

class BeerRepository {
  final BeerListValidator _listValidator = BeerListValidator();

  Future<List<BeerItem>> getBeers() async {
    final response = await _apiClient.dio.get('/beers');
    final data = response.data['data'] as List<dynamic>;

    // 驗證 API 回應
    final validationResult = _listValidator.validateJsonList(data);
    if (!validationResult.isValid) {
      logger.e('Validation failed: ${validationResult.errorMessage}');
      throw ValidationException(validationResult);
    }

    // 資料有效，安全解析
    return data
        .map((json) => BeerItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
```

### 在 Service 中整合

```dart
import 'package:hold_your_beer/core/validation/validators/user_data_validator.dart';
import 'package:hold_your_beer/core/validation/validation_result.dart';

class AuthService {
  final LoginResponseValidator _loginValidator = LoginResponseValidator();

  Future<LoginResponse> login(String email, String password) async {
    final response = await _apiClient.dio.post('/login', data: {...});

    // 驗證登入回應
    final validationResult = _loginValidator.validateJson(response.data);
    if (!validationResult.isValid) {
      logger.e('Login response validation failed: ${validationResult.errorMessage}');
      throw ValidationException(validationResult);
    }

    return LoginResponse.fromJson(response.data);
  }
}
```

## 可用的驗證器

### UserDataValidator

驗證使用者資料：
- `id`: 正整數
- `name`: 非空，最多 255 字元
- `email`: 有效的 email 格式
- `created_at`, `updated_at`: 有效的時間戳
- `email_verified_at`: 可選的時間戳

### LoginResponseValidator

驗證登入/註冊回應：
- `token`: 非空字串
- `user`: 有效的 UserData 物件

### BeerItemValidator

驗證啤酒項目：
- `id`: 正整數
- `brand`: 非空，最多 100 字元
- `name`: 非空，最多 200 字元
- `tasting_count`: 非負整數
- `style`: 可選，最多 100 字元

### BeerListValidator

驗證啤酒項目列表，會對每個項目進行 `BeerItemValidator` 驗證。

### TastingLogValidator

驗證品嚐記錄：
- `id`: 正整數
- `action`: 必須為 `increment`、`decrement` 或 `reset`
- `tasted_at`: 有效的時間戳
- `note`: 可選，最多 500 字元

### TastingLogListValidator

驗證品嚐記錄列表。

## 通用驗證方法

`JsonValidator` 基類提供了多種通用驗證方法：

### 類型驗證

```dart
validateRequired(json, 'field_name')      // 必填欄位
validateType<T>(json, 'field', Type)      // 類型檢查
```

### 字串驗證

```dart
validateStringFormat(json, 'email', emailRegex, 'email')  // 格式驗證
validateStringLength(json, 'name', minLength: 1, maxLength: 100)  // 長度驗證
```

### 數值驗證

```dart
validateNumericRange(json, 'count', min: 0, max: 100)  // 範圍驗證
```

### 枚舉驗證

```dart
validateEnum(json, 'action', ['increment', 'decrement'])  // 枚舉值驗證
```

### 列表驗證

```dart
validateList(json, 'items', minItems: 1, maxItems: 100)  // 列表長度驗證
```

## 錯誤處理

### ValidationException 整合到 ErrorMessages

`ValidationException` 已整合到 `ErrorMessages` 工具類中，會自動將驗證錯誤轉換為使用者友善的中文訊息：

```dart
try {
  validator.validateOrThrow(data);
} on ValidationException catch (e) {
  final userMessage = ErrorMessages.getMessage(e);
  // 顯示給使用者：「名稱 為必填欄位」
}
```

### 錯誤代碼

驗證錯誤包含標準化的錯誤代碼：

- `REQUIRED_FIELD`: 必填欄位缺失
- `INVALID_TYPE`: 類型不正確
- `INVALID_FORMAT`: 格式無效
- `INVALID_TIMESTAMP`: 時間戳格式錯誤
- `MIN_LENGTH` / `MAX_LENGTH`: 長度超出範圍
- `MIN_VALUE` / `MAX_VALUE`: 數值超出範圍
- `INVALID_ENUM`: 枚舉值不在允許範圍
- `INVALID_ID`: ID 無效

## 自訂驗證器

### 創建新的驗證器

```dart
import 'package:hold_your_beer/core/validation/validator.dart';
import 'package:hold_your_beer/core/validation/validation_result.dart';

class MyModelValidator extends JsonValidator<MyModel> {
  @override
  ValidationResult validate(MyModel data) {
    final errors = <ValidationError>[];

    // 自訂驗證邏輯
    if (data.someField.isEmpty) {
      errors.add(const ValidationError(
        field: 'someField',
        message: 'Some field is required',
        code: 'REQUIRED_FIELD',
      ));
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  @override
  ValidationResult validateJson(Map<String, dynamic> json) {
    final errors = collectErrors([
      validateRequired(json, 'someField'),
      validateType<String>(json, 'someField', String),
      validateStringLength(json, 'someField', minLength: 1, maxLength: 100),
    ]);

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}
```

### 組合驗證器

```dart
class ComplexValidator extends JsonValidator<ComplexModel> {
  final NestedValidator _nestedValidator = NestedValidator();

  @override
  ValidationResult validateJson(Map<String, dynamic> json) {
    final errors = collectErrors([
      validateRequired(json, 'id'),
      validateRequired(json, 'nested'),
    ]);

    // 驗證巢狀物件
    if (json['nested'] != null && json['nested'] is Map<String, dynamic>) {
      final nestedResult = _nestedValidator.validateJson(json['nested']);
      if (!nestedResult.isValid) {
        errors.addAll(nestedResult.errors);
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}
```

## 最佳實踐

1. **在解析前驗證**: 總是在呼叫 `fromJson()` 之前進行驗證
2. **記錄驗證錯誤**: 使用 logger 記錄驗證失敗的詳細資訊
3. **提供友善訊息**: 使用 `ErrorMessages.getMessage()` 向使用者顯示錯誤
4. **快速失敗**: 發現無效資料時立即拋出異常
5. **驗證關鍵路徑**: 優先驗證認證、支付等關鍵功能的資料
6. **保持同步**: 當 API 結構改變時，同步更新驗證器

## 效能考量

- 驗證器設計為輕量級，對效能影響最小
- 建議為每個 Repository/Service 創建單一驗證器實例並重用
- 對於大型列表，驗證可能增加處理時間，但可防止更嚴重的執行時錯誤

## 測試

驗證器應包含單元測試：

```dart
void main() {
  group('UserDataValidator', () {
    final validator = UserDataValidator();

    test('should pass valid user data', () {
      final json = {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'created_at': '2025-01-01T00:00:00Z',
        'updated_at': '2025-01-01T00:00:00Z',
      };

      final result = validator.validateJson(json);
      expect(result.isValid, true);
    });

    test('should fail when email is invalid', () {
      final json = {
        'id': 1,
        'name': 'Test User',
        'email': 'invalid-email',
        'created_at': '2025-01-01T00:00:00Z',
        'updated_at': '2025-01-01T00:00:00Z',
      };

      final result = validator.validateJson(json);
      expect(result.isValid, false);
      expect(result.errors.any((e) => e.field == 'email'), true);
    });
  });
}
```

## 參考

- [OPTIMIZATION_SUGGESTIONS.md P2.12](../../../OPTIMIZATION_SUGGESTIONS.md)
- [ErrorMessages 工具類](../utils/error_messages.dart)
- [BeerRepository 整合範例](../../features/beer_tracking/repositories/beer_repository.dart)
- [AuthService 整合範例](../services/auth_service.dart)
