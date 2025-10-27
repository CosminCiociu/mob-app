import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/helpers/location_permission_helper.dart';

/// Example controller showing how to use LocationPermissionHelper
/// in existing controllers that need location access.
///
/// Usage Pattern 1: Direct permission check and navigation
/// Usage Pattern 2: Location-dependent feature with automatic permission flow
/// Usage Pattern 3: Background location requirement handling
class LocationExampleController extends GetxController {
  final LocationPermissionHelper _locationHelper = LocationPermissionHelper();

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
      final hasPermission = await _locationHelper.checkLocationPermission();
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
      final position = await _locationHelper.requireLocationPermission();

      if (position != null) {
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

  /// Pattern 3: Background location monitoring with permission enforcement
  Future<void> startLocationTracking() async {
    try {
      // Ensure we have always permission for background tracking
      await _locationHelper.ensureLocationPermission(LocationPermission.always);

      // Start location stream
      Geolocator.getPositionStream().listen(
        (Position position) {
          currentPosition.value = position;
          // Handle location updates
        },
        onError: (error) {
          locationStatus.value = 'Tracking Error: $error';
        },
      );

      locationStatus.value = 'Tracking Active';
    } catch (e) {
      locationStatus.value = 'Failed to start tracking: $e';
    }
  }

  /// Pattern 4: One-time location request with error handling
  Future<void> getCurrentLocation() async {
    try {
      locationStatus.value = 'Getting location...';

      final position = await _locationHelper.getCurrentLocation();
      if (position != null) {
        currentPosition.value = position;
        locationStatus.value = 'Location updated';
        Get.snackbar('Location',
            'Current location: ${position.latitude}, ${position.longitude}');
      } else {
        locationStatus.value = 'Location unavailable';
      }
    } catch (e) {
      locationStatus.value = 'Error: $e';
    }
  }

  /// Example of how to integrate location check in existing features
  Future<void> createLocationBasedEvent() async {
    // Check if we have location permission before proceeding
    if (!await _locationHelper.checkLocationPermission()) {
      // This will navigate to permission screen and return here after permission granted
      final position = await _locationHelper.requireLocationPermission();

      if (position == null) {
        Get.snackbar('Cannot Create Event',
            'Location permission is required to create location-based events');
        return;
      }
    }

    // Continue with event creation logic
    final position = await _locationHelper.getCurrentLocation();
    if (position != null) {
      // Use position for event creation
      _createEventWithLocation(position);
    }
  }

  /// Example of handling different permission states
  Future<void> handleLocationFeature() async {
    final permission = await Geolocator.checkPermission();

    switch (permission) {
      case LocationPermission.denied:
        // Navigate to permission screen
        await _locationHelper.requireLocationPermission();
        break;

      case LocationPermission.deniedForever:
        // Show dialog to open settings
        Get.dialog(
          AlertDialog(
            title: Text('Location Permission Required'),
            content: Text(
                'Please enable location permission in device settings to use this feature.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Get.back();
                  await Geolocator.openAppSettings();
                },
                child: Text('Open Settings'),
              ),
            ],
          ),
        );
        break;

      case LocationPermission.whileInUse:
      case LocationPermission.always:
        // Permission granted, proceed with feature
        await getCurrentLocation();
        break;

      case LocationPermission.unableToDetermine:
        locationStatus.value = 'Unable to determine location permission';
        break;
    }
  }

  // Mock methods for example purposes
  Future<void> _searchNearbyEvents(Position position) async {
    // Simulate API call to search nearby events
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> _createEventWithLocation(Position position) async {
    // Simulate event creation with location
    await Future.delayed(Duration(seconds: 1));
    Get.snackbar('Event Created',
        'Event created at ${position.latitude}, ${position.longitude}');
  }
}

/// Example of how to use in your existing screens
/// 
/// class MyEventsScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final controller = Get.put(LocationExampleController());
///     
///     return Scaffold(
///       appBar: AppBar(title: Text('My Events')),
///       body: Column(
///         children: [
///           Obx(() => Text('Location Status: ${controller.locationStatus.value}')),
///           ElevatedButton(
///             onPressed: controller.findNearbyEvents,
///             child: Text('Find Nearby Events'),
///           ),
///           ElevatedButton(
///             onPressed: controller.getCurrentLocation,
///             child: Text('Get Current Location'),
///           ),
///         ],
///       ),
///     );
///   }
/// }