# Location Permission System

This documentation explains how to use the location permission system in your Flutter app.

## Overview

The location permission system provides a user-friendly way to request location permissions and ensures consistent behavior throughout the app when location access is required.

## Components

### 1. LocationPermissionScreen

**Path:** `lib/view/screens/location_permission/location_permission_screen.dart`

The main screen that users see when location permission is required. Features:

- Animated location icon
- Clear explanation of why location is needed
- "Enable Location" button
- Optional skip button (configurable)
- Settings redirect for permanently denied permissions

### 2. LocationPermissionHelper

**Path:** `lib/core/helpers/location_permission_helper.dart`

Utility class with static methods for handling location permissions:

#### Methods:

- `isLocationPermissionGranted()` - Check if permission is granted
- `checkAndRequestLocation()` - Check permission and navigate to screen if needed
- `requireLocationPermission()` - Force permission request (no skip option)
- `checkLocationWithChoice()` - Show dialog with enable/continue options
- `ensureLocationPermission()` - Throw exception if permission not granted

### 3. Reusable Components

**Path:** `lib/view/components/location_permission/`

- `LocationPermissionIcon` - Animated location icon
- `LocationPermissionCard` - Reusable card with title/description

### 4. String Constants

**Path:** `lib/core/utils/my_strings.dart`

All location-related strings added:

- `enableLocation` - "Enable Location"
- `locationAccessRequired` - "Location Access Required"
- `needLocationForEvents` - "We need location access to show you nearby events"
- And more...

### 5. Color Constants

**Path:** `lib/core/utils/my_color.dart`

Location-specific colors:

- `locationIconColor` - Green icon color
- `locationWarningColor` - Orange warning color
- `locationBackgroundColor` - Light background
- And more...

### 6. Route Integration

**Path:** `lib/core/route/route.dart`

Added route: `RouteHelper.locationPermissionScreen`

## Usage Examples

### 1. Basic Permission Check

```dart
class MyController extends GetxController {
  Future<void> someFeature() async {
    final hasPermission = await LocationPermissionHelper.isLocationPermissionGranted();
    if (hasPermission) {
      // Continue with location feature
    } else {
      // Handle no permission
    }
  }
}
```

### 2. Required Permission (Navigate to Screen)

```dart
Future<void> findNearbyEvents() async {
  final granted = await LocationPermissionHelper.requireLocationPermission();
  if (granted) {
    final position = await Geolocator.getCurrentPosition();
    // Use position for nearby events
  }
}
```

### 3. Optional Permission with Choice

```dart
Future<void> optionalLocationFeature() async {
  await LocationPermissionHelper.checkLocationWithChoice(
    title: 'Enable Location for Better Experience',
    message: 'We can show you nearby events if you enable location access.',
    onGranted: () {
      // User granted permission
    },
    onDenied: () {
      // User chose to continue without location
    },
  );
}
```

### 4. Exception-Based Validation

```dart
Future<void> locationBasedOperation() async {
  try {
    await LocationPermissionHelper.ensureLocationPermission();
    // Continue with operation that requires location
  } catch (e) {
    Get.snackbar('Error', e.toString());
  }
}
```

## Integration in Existing Controllers

### MyEventsController Example

```dart
class MyEventsController extends GetxController {
  Future<void> findNearbyEvents() async {
    // This will automatically show permission screen if needed
    final granted = await LocationPermissionHelper.requireLocationPermission();
    if (granted) {
      final position = await Geolocator.getCurrentPosition();
      // Search for events near position
    }
  }
}
```

### CreateEventController Example

```dart
class CreateEventController extends GetxController {
  Future<void> useCurrentLocation() async {
    try {
      await LocationPermissionHelper.ensureLocationPermission();
      final position = await Geolocator.getCurrentPosition();
      // Set event location to current position
    } catch (e) {
      Get.snackbar('Error', 'Location permission required');
    }
  }
}
```

## Navigation Flow

1. User triggers location-dependent feature
2. App checks permission using `LocationPermissionHelper`
3. If permission denied, automatically navigates to `LocationPermissionScreen`
4. User enables location or chooses to skip (if allowed)
5. Returns to original screen with permission result
6. Feature continues or shows appropriate message

## Customization

### Custom Messages

```dart
await LocationPermissionHelper.requireLocationPermission(
  customTitle: 'Custom Title',
  customDescription: 'Custom explanation for this specific feature',
);
```

### Skip Option

```dart
await LocationPermissionHelper.checkAndRequestLocation(
  showSkipOption: true, // Allow user to skip
);
```

### Custom Colors

Modify colors in `my_color.dart`:

```dart
static const Color locationIconColor = Color(0xFF4CAF50);
static const Color locationWarningColor = Color(0xFFFF9800);
```

## Dependencies

- `geolocator` - For location services and permissions
- `get` - For navigation and state management
- Standard Flutter Material widgets

## Notes

- The system uses `Geolocator` package for permission handling
- All navigation is handled through GetX
- Follows existing app patterns for styling and structure
- Permissions are checked each time before location access
- Handles all permission states (denied, deniedForever, granted, etc.)
