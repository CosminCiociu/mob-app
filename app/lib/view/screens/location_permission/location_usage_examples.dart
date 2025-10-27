import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/helpers/location_permission_helper.dart';

/// Example controller showing how to use LocationPermissionHelper
/// in existing controllers that need location access.
class LocationExampleController extends GetxController {
  // Observable for location status
  final RxBool isLocationEnabled = false.obs;
  final RxString locationStatus = 'Unknown'.obs;
  final Rx<Position?> currentPosition = Rx<Position?>(null);

  @override
  void onInit() {
    super.onInit();
    checkInitialLocationStatus();
  }

  /// Pattern 1: Check permission status on controller initialization
  Future<void> checkInitialLocationStatus() async {
    try {
      final hasPermission =
          await LocationPermissionHelper.isLocationPermissionGranted();
      isLocationEnabled.value = hasPermission;
      locationStatus.value = hasPermission ? 'Enabled' : 'Disabled';
    } catch (e) {
      locationStatus.value = 'Error: $e';
    }
  }

  /// Pattern 2: Feature that requires location - automatically handles permission flow
  Future<void> findNearbyEvents() async {
    try {
      // This will automatically navigate to location permission screen if needed
      final hasPermission =
          await LocationPermissionHelper.requireLocationPermission();

      if (hasPermission) {
        final position = await Geolocator.getCurrentPosition();
        currentPosition.value = position;
        // Continue with your nearby events logic here
        await _searchNearbyEvents(position);
        Get.snackbar('Success', 'Found nearby events based on your location');
      } else {
        Get.snackbar('Permission Denied',
            'Location access is required to find nearby events');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to get location: $e');
    }
  }

  /// Pattern 3: Get current location with permission check
  Future<void> getCurrentLocation() async {
    try {
      locationStatus.value = 'Getting location...';

      // Check permission first
      final hasPermission =
          await LocationPermissionHelper.isLocationPermissionGranted();
      if (!hasPermission) {
        final granted =
            await LocationPermissionHelper.requireLocationPermission();
        if (!granted) {
          locationStatus.value = 'Permission denied';
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      currentPosition.value = position;
      locationStatus.value = 'Location updated';
      Get.snackbar('Location',
          'Current location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      locationStatus.value = 'Error: $e';
    }
  }

  /// Pattern 4: Using checkLocationWithChoice for optional location features
  Future<void> optionalLocationFeature() async {
    await LocationPermissionHelper.checkLocationWithChoice(
      title: 'Enable Location for Better Experience',
      message: 'We can show you nearby events if you enable location access.',
      onGranted: () async {
        // User granted permission
        await findNearbyEvents();
      },
      onDenied: () {
        // User chose to continue without location
        Get.snackbar(
            'Info', 'You can still browse all events without location access');
      },
    );
  }

  /// Pattern 5: Exception handling with ensureLocationPermission
  Future<void> locationBasedOperation() async {
    try {
      // This will throw an exception if location is not available
      await LocationPermissionHelper.ensureLocationPermission(
        errorMessage: 'This feature requires location access to work properly.',
      );

      // Continue with location-dependent operation
      final position = await Geolocator.getCurrentPosition();
      currentPosition.value = position;
      locationStatus.value = 'Operation completed successfully';
    } catch (e) {
      locationStatus.value = 'Operation failed: $e';
      Get.snackbar('Error', e.toString());
    }
  }

  // Mock methods for example purposes
  Future<void> _searchNearbyEvents(Position position) async {
    // Simulate API call to search nearby events
    await Future.delayed(Duration(seconds: 2));
  }
}

/// USAGE EXAMPLES IN EXISTING SCREENS:
/// 
/// 1. In MyEventsScreen - when user wants to find nearby events:
/// ```dart
/// class MyEventsController extends GetxController {
///   Future<void> findNearbyEvents() async {
///     final hasPermission = await LocationPermissionHelper.requireLocationPermission();
///     if (hasPermission) {
///       final position = await Geolocator.getCurrentPosition();
///       // Use position to search nearby events
///     }
///   }
/// }
/// ```
/// 
/// 2. In CreateEventScreen - when creating location-based events:
/// ```dart
/// class CreateEventController extends GetxController {
///   Future<void> useCurrentLocation() async {
///     try {
///       await LocationPermissionHelper.ensureLocationPermission();
///       final position = await Geolocator.getCurrentPosition();
///       // Set event location to current position
///     } catch (e) {
///       Get.snackbar('Error', 'Location permission required to use current location');
///     }
///   }
/// }
/// ```
/// 
/// 3. In ProfileScreen - for optional location-based features:
/// ```dart
/// class ProfileController extends GetxController {
///   Future<void> showNearbyUsers() async {
///     await LocationPermissionHelper.checkLocationWithChoice(
///       title: 'Show Nearby Users',
///       message: 'Allow location access to see users near you.',
///       onGranted: () async {
///         // Show nearby users
///       },
///       onDenied: () {
///         // Continue without location
///       },
///     );
///   }
/// }
/// ```