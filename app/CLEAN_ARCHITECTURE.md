# Clean Architecture Implementation

This document describes the new clean architecture structure implemented in the app to improve code organization, maintainability, and testability.

## Architecture Overview

The app now follows clean architecture principles with clear separation of concerns:

```
lib/
├── domain/                 # Business logic layer (abstract interfaces)
│   ├── repositories/       # Repository interfaces
│   │   ├── events_repository.dart
│   │   └── users_repository.dart
│   └── services/          # Service interfaces
│       ├── home_service.dart
│       └── matching_service.dart
│
├── data/                  # Data layer (concrete implementations)
│   ├── repositories/      # Repository implementations
│   │   ├── firebase_events_repository.dart
│   │   └── firebase_users_repository.dart
│   └── services/         # Service implementations
│       ├── home_service_impl.dart
│       └── matching_service_impl.dart
│
├── core/
│   └── config/
│       └── dependency_injection.dart  # DI configuration
│
└── view/                 # UI layer (controllers, widgets)
    └── controllers/      # Refactored controllers using services
```

## Key Components

### 1. Domain Layer (`lib/domain/`)

**Abstract interfaces defining business logic contracts:**

- **EventsRepository**: Interface for event-related data operations

  - `fetchNearbyEvents()` - Get events within radius
  - `getAllEvents()` - Get all events with pagination

- **UsersRepository**: Interface for user-related data operations

  - `getNearbyUsers()` - Get users within radius
  - `updateUserLocation()` - Update user location

- **HomeService**: Interface for home screen state management

  - UI state getters (currentIndex, loading states, filters)
  - State manipulation methods (resetCurrentIndex, updateFilters)

- **MatchingService**: Interface for matching and discovery operations
  - `searchNearbyEvents()` - Search for events with filtering
  - `searchNearbyUsers()` - Search for users with filtering
  - `updateLocationAndRefresh()` - Update location and refresh data

### 2. Data Layer (`lib/data/`)

**Concrete implementations of domain interfaces:**

- **FirebaseEventsRepository**: Firebase implementation of EventsRepository

  - Uses geoflutterfire_plus for geohash-based queries
  - Implements manual fallback for broader search
  - Handles pagination and filtering

- **FirebaseUsersRepository**: Firebase implementation of UsersRepository

  - Location-based user queries
  - User data management

- **HomeServiceImpl**: Implementation of HomeService

  - Manages UI state variables
  - Handles filter validation and updates
  - Provides state change notifications

- **MatchingServiceImpl**: Implementation of MatchingService
  - Orchestrates repository calls
  - Handles error processing and user feedback
  - Implements business logic for matching algorithms

### 3. Dependency Injection (`lib/core/config/dependency_injection.dart`)

**Centralized dependency management using GetX:**

```dart
DependencyInjection.init(); // Call in main.dart
```

This sets up:

- Repository instances (singleton)
- Service instances with proper dependencies
- Automatic dependency resolution

### 4. Refactored Controllers

**Example: HomeControllerRefactored**

Before (monolithic):

```dart
class HomeController extends GetxController {
  // 900+ lines of mixed UI state, business logic, and data access
  Future<void> getGeoFlutterfireEvents() {
    // Direct Firebase calls
    // Complex business logic
    // UI state management
  }
}
```

After (service-based):

```dart
class HomeControllerRefactored extends GetxController {
  late final HomeService _homeService;
  late final MatchingService _matchingService;

  // Clean UI coordination
  Future<void> refreshEvents() async {
    nearbyEvents = await _matchingService.searchNearbyEvents(
      radiusInKm: distance.toDouble(),
      currentUserId: user.uid,
    );
  }
}
```

## Benefits

### 1. **Separation of Concerns**

- UI controllers focus only on UI coordination
- Business logic isolated in services
- Data access abstracted through repositories

### 2. **Testability**

- Mock interfaces for unit testing
- Independent testing of each layer
- Dependency injection enables test isolation

### 3. **Maintainability**

- Single responsibility principle
- Easy to locate and modify specific functionality
- Reduced coupling between components

### 4. **Scalability**

- Easy addition of new services/repositories
- Plugin architecture for different data sources
- Clear extension points

## Usage Examples

### Using Services in Controllers

```dart
class SomeController extends GetxController {
  late final MatchingService _matchingService;

  @override
  void onInit() {
    super.onInit();
    _matchingService = Get.find<MatchingService>();
  }

  Future<void> searchEvents() async {
    final events = await _matchingService.searchNearbyEvents(
      radiusInKm: 10.0,
      currentUserId: getCurrentUserId(),
    );
    // Handle results
  }
}
```

### Creating New Services

1. **Define interface in `domain/services/`:**

```dart
abstract class NewService {
  Future<void> performAction();
}
```

2. **Implement in `data/services/`:**

```dart
class NewServiceImpl implements NewService {
  @override
  Future<void> performAction() async {
    // Implementation
  }
}
```

3. **Register in dependency injection:**

```dart
Get.put<NewService>(NewServiceImpl(), permanent: true);
```

## Migration Guide

### From Old Controller Pattern

1. **Extract business logic** from controllers to service implementations
2. **Move data access** from controllers to repository implementations
3. **Update controllers** to use injected services
4. **Add dependency registration** to DependencyInjection

### Testing Strategy

1. **Unit test services** with mocked repositories
2. **Unit test repositories** with mocked data sources
3. **Integration test** controller + service interactions
4. **Widget test** UI with mocked services

## Future Enhancements

1. **Add more repository interfaces** (messages, notifications, etc.)
2. **Implement caching layer** in repositories
3. **Add offline support** through repository implementations
4. **Create service decorators** for logging, analytics, etc.
5. **Add validation services** for form handling
6. **Implement background services** for data synchronization

## Error Handling

Services provide standardized error handling:

```dart
String getDetailedErrorMessage(dynamic error) {
  // Centralized error processing
  // User-friendly error messages
  // Logging and analytics
}
```

This ensures consistent error handling across the application and better user experience.
