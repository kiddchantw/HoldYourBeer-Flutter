# CLAUDE.md

This file provides guidance to Claude Code when working with the HoldYourBeer Flutter mobile application.

## Project Overview

HoldYourBeer Flutter App 是配合 Laravel 後端的行動應用程式，用於追蹤啤酒消費記錄。採用現代 Flutter 開發堆疊，包含狀態管理、本地儲存、與後端 API 整合等功能。

## Technology Stack

- **Framework**: Flutter 3.x with Dart SDK 3.0+
- **State Management**: Riverpod 2.0 (Provider pattern)
- **HTTP Client**: Dio + Retrofit for API communication
- **Local Storage**: Hive + Flutter Secure Storage
- **Navigation**: Go Router for declarative routing
- **UI Adaptation**: ScreenUtil for responsive design
- **Code Generation**: Freezed for immutable models, build_runner for code generation
- **Testing**: Flutter Test + Mockito

## Development Environment Setup

### Prerequisites
```bash
# Verify Flutter installation
flutter --version  # Should be 3.0.0+
flutter doctor     # Check for any issues

# Verify Dart SDK
dart --version     # Should be 3.0+
```

### Getting Started
```bash
# Install dependencies
flutter pub get

# Generate code (models, services, providers)
flutter packages pub run build_runner build

# Clean and regenerate if needed
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run with specific device
flutter devices
flutter run -d <device-id>
```

### Code Generation Commands
```bash
# Watch mode (automatically rebuilds on file changes)
flutter packages pub run build_runner watch

# Build once
flutter packages pub run build_runner build

# Force rebuild (clean build)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Project Architecture

### Directory Structure
```
lib/
├── core/                    # 核心功能層
│   ├── api/                # API 配置 (DioClient)
│   ├── auth/               # 認證管理 (AuthProvider)
│   ├── constants/          # 常數定義 (AppConstants, ApiEndpoints)
│   └── utils/              # 工具函數
├── data/                   # 資料層
│   ├── models/             # 資料模型 (Freezed models)
│   ├── repositories/       # 資料倉庫 (Data access layer)
│   └── services/           # API 服務 (Retrofit services)
├── features/               # 功能模組 (Feature-based architecture)
│   ├── auth/               # 認證功能 (Login, Register)
│   ├── beer_tracking/      # 啤酒追蹤 (List, Add, Count actions)
│   ├── brand_management/   # 品牌管理
│   └── tasting_history/    # 品嚐歷史記錄
└── shared/                 # 共用元件
    ├── widgets/            # UI 元件
    └── themes/             # 主題配置
```

### Key Architectural Patterns
- **Feature-based Architecture**: Each feature has its own screens, widgets, providers
- **Repository Pattern**: Data access abstraction layer
- **Provider Pattern**: Riverpod for state management
- **Model-Service-Controller**: Clean separation of concerns

## API Integration

### Backend Connection
- **Laravel Backend**: HoldYourBeer Laravel API (see sibling project)
- **Base URL**: Configurable in `AppConstants.baseUrl`
  - Development: `http://192.168.1.124/api` (current setting)
  - Production: To be configured per environment
- **Authentication**: Laravel Sanctum Bearer Token
- **API Documentation**: Follows OpenAPI spec from Laravel project

### API Configuration
```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const String baseUrl = 'http://192.168.1.124/api';
  // ... other constants
}
```

### Key API Endpoints
- `POST /register` - User registration
- `POST /login` - User authentication
- `GET /beers` - List user's tracked beers
- `POST /beers` - Add new beer tracking
- `POST /beers/{id}/count_actions` - Increment/decrement count
- `GET /beers/{id}/tasting_logs` - View tasting history
- `GET /brands` - List available brands ✅ **Implemented**

### Token Management
- Stored securely using `FlutterSecureStorage`
- Automatically added to requests via Dio interceptors
- Handles token expiration (401 responses)

## Development Guidelines

### Code Style & Standards
- **Dart Style**: Follow official Dart style guide
- **Linting**: Use `flutter_lints` package rules
- **Naming**: Use `snake_case` for files, `camelCase` for variables, `PascalCase` for classes
- **Import Organization**: Group imports (dart:, package:, relative)

### State Management with Riverpod
```dart
// Provider definition
@riverpod
class BeerNotifier extends _$BeerNotifier {
  @override
  Future<List<Beer>> build() async {
    // Initial state logic
  }
}

// Usage in widgets
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beers = ref.watch(beerNotifierProvider);
    return beers.when(
      data: (data) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### Model Definition with Freezed
```dart
@freezed
class Beer with _$Beer {
  const factory Beer({
    required int id,
    required String name,
    required String style,
    required int tastingCount,
    required Brand brand,
  }) = _Beer;

  factory Beer.fromJson(Map<String, dynamic> json) => _$BeerFromJson(json);
}
```

### Testing Guidelines
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/beer_model_test.dart

# Run with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Development Workflow

### Feature Development Process
1. **API Integration**: Ensure backend endpoint exists and is documented
2. **Model Definition**: Create Freezed models based on API response
3. **Service Layer**: Implement Retrofit API service
4. **Repository**: Create repository for data access abstraction
5. **Provider**: Implement Riverpod provider for state management
6. **UI Implementation**: Build screens and widgets
7. **Testing**: Write unit and widget tests
8. **Integration**: Test with actual backend

### Code Generation Workflow
1. Define models with Freezed annotations
2. Define API services with Retrofit annotations
3. Define providers with Riverpod annotations
4. Run `flutter packages pub run build_runner build`
5. Commit generated files to version control

### Git Workflow
```bash
# Feature branches
git checkout -b feature/beer-count-increment
git checkout -b bugfix/login-token-refresh
git checkout -b ui/improve-beer-card-design

# Conventional commits
git commit -m "feat: add beer count increment functionality"
git commit -m "fix: resolve token refresh issue on 401 response"
git commit -m "ui: improve beer card visual design and spacing"
```

## Common Commands Reference

### Development Commands
```bash
# Clean and get dependencies
flutter clean && flutter pub get

# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run with hot reload
flutter run

# Run release build
flutter run --release

# Build APK for testing
flutter build apk --debug
flutter build apk --release
```

### Testing Commands
```bash
# All tests
flutter test

# Specific test suite
flutter test test/unit/
flutter test test/widget/

# With coverage
flutter test --coverage
```

### Analysis Commands
```bash
# Static analysis
flutter analyze

# Check formatting
dart format --set-exit-if-changed .

# Apply formatting
dart format .
```

## Environment Configuration

### Local Development
- **Backend URL**: Configure in `AppConstants.baseUrl`
- **Debug Logging**: Enabled via Logger package
- **Hot Reload**: Available for rapid development

### Build Flavors (Future)
- **Development**: Debug builds with local backend
- **Staging**: Release builds with staging backend
- **Production**: Production builds with live backend

## Integration with Laravel Backend

### Data Synchronization
- **Online**: Direct API calls to Laravel backend
- **Offline**: Local Hive storage with sync capability (future enhancement)
- **Authentication**: Shared Sanctum token system

### API Consistency
- **Response Format**: Matches Laravel API specification
- **Error Handling**: Follows standardized JSON error format
- **Validation Rules**: Mirror Laravel validation constraints

## Troubleshooting

### Common Issues
1. **Build Runner Issues**: Run `flutter packages pub run build_runner clean` then rebuild
2. **Token Expiration**: Check 401 handling in DioClient interceptors
3. **Network Issues**: Verify backend URL and device network connectivity
4. **Code Generation**: Ensure all dependencies are up to date

### Debug Tips
- Use `flutter logs` for device logs
- Enable network logging in DioClient for API debugging
- Use Flutter Inspector for widget tree analysis
- Check Riverpod provider states with Riverpod Inspector

## Session Management

### Overview
For non-trivial features, create a session document to track planning, implementation, and learnings.

**Session lifecycle**: Create → Develop → Extract Knowledge → Archive (Delete)

### Create Session

```bash
# Copy template
cp docs/sessions/template.md docs/sessions/current/$(date +%d)-feature-name.md

# Example
cp docs/sessions/template.md docs/sessions/current/15-offline-sync.md
```

### During Development

**Update session file:**
- Fill Planning section with approach and design decisions
- Check off Implementation Checklist items
- Document blockers and solutions
- Reference session in commits

**Example commit:**
```bash
git commit -m "feat(sync): implement offline queue

Part of docs/sessions/current/15-offline-sync.md
Phase 2: State Management Integration"
```

### Complete Session

**When feature is done:**

1. **Fill Outcome section**:
   - What was built
   - Files changed
   - Lessons learned

2. **Extract ALL knowledge** to permanent docs:
   - Decisions → Create `docs/ADR/XXX-decision.md`
   - Architecture → Update `docs/architecture/YYY.md`
   - Patterns → Update `docs/architecture/patterns.md`
   - API changes → Update `docs/api/endpoints.md`
   - Product status → Update `docs/product/features/`

3. **Archive session** using automated tool:

```bash
./scripts/archive-session.sh
```

The script will:
- List current sessions
- Validate knowledge extraction checklist
- Guide you through delete or move to notable/
- Generate commit message

**Manual archive:**
```bash
# Most sessions: Delete after knowledge extraction
git rm docs/sessions/current/15-feature.md
git commit -m "chore: remove session after knowledge extraction

Knowledge preserved in:
- ADR-006: [Decision]
- architecture/offline-sync.md: [Implementation]"

# Rare: Major architectural changes
git mv docs/sessions/current/15-major-refactor.md \
       docs/sessions/notable/2025-11-15-major-refactor.md
git commit -m "docs: preserve session in notable/

Reason: Major architectural refactor with complex migration"
```

### Archive Guidelines

**Delete immediately (95% of sessions):**
- ✅ All knowledge extracted to permanent docs
- ✅ Standard implementation
- ✅ No unique insights beyond ADR/architecture

**Move to notable/ (<5% of sessions):**
- 🌟 Major architectural change
- 🌟 Unique insights hard to capture in ADR
- 🌟 Complex decision process worth preserving

### Tools & Templates

- **Session Template**: `docs/sessions/template.md`
- **Archive Script**: `scripts/archive-session.sh`
- **Archive Workflow**: `.claude/templates/archive-session.md`
- **Sessions Guide**: `docs/sessions/README.md`

## Definition of Done for Features

### Checklist
- [ ] **API Integration**: Backend endpoint implemented and tested
- [ ] **Models**: Freezed models created with proper serialization
- [ ] **State Management**: Riverpod providers implemented
- [ ] **UI Implementation**: Screens and widgets completed
- [ ] **Error Handling**: Proper error states and user feedback
- [ ] **Testing**: Unit and widget tests written and passing
- [ ] **Code Generation**: All generated files up to date
- [ ] **Code Review**: Peer review completed
- [ ] **Integration Testing**: Tested with actual backend
- [ ] **UI/UX**: Design matches specifications and is responsive
- [ ] **Session Document**: Created, completed, and archived (if applicable)
- [ ] **Knowledge Extracted**: ADR and architecture docs updated

---

## Notes

- This Flutter app works in tandem with the HoldYourBeer Laravel backend
- Ensure API changes are coordinated between both projects
- Follow mobile-first design principles
- Prioritize performance and smooth user experience
- Maintain consistency with Laravel backend data structures and API contracts