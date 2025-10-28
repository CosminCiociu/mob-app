import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/my_strings.dart';
import '../../view/screens/location_permission/location_permission_screen.dart';

class LocationPermissionHelper {
  /// Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    try {
      // Add timeout to prevent hanging on system issues
      final result = await _checkLocationPermissionInternal()
          .timeout(const Duration(seconds: 10));
      return result;
    } catch (e) {
      print('Error checking location permission: $e');
      // In case of system failure, assume no permission to prevent crashes
      return false;
    }
  }

  /// Internal method to check location permission
  static Future<bool> _checkLocationPermissionInternal() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Check location permission and navigate to permission screen if needed
  /// Returns true if permission is granted, false otherwise
  static Future<bool> checkAndRequestLocation({
    String? customTitle,
    String? customDescription,
    bool showSkipOption = false,
  }) async {
    try {
      bool hasPermission = await isLocationPermissionGranted();

      if (hasPermission) {
        return true;
      }

      // Navigate to location permission screen using Navigator for better stability
      final result = await Navigator.of(Get.context!).push<bool>(
        MaterialPageRoute(
          builder: (context) => LocationPermissionScreen(
            customTitle: customTitle,
            customDescription: customDescription,
            showSkipOption: showSkipOption,
          ),
        ),
      );

      // Ensure we have a valid result
      return result == true;
    } catch (e) {
      print('Error in checkAndRequestLocation: $e');
      // Show user-friendly error message and return false
      if (Get.context != null && Get.context!.mounted) {
        _showLocationErrorMessage();
      }
      return false;
    }
  }

  /// Show a user-friendly error message when location services fail
  static void _showLocationErrorMessage() {
    try {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).clearSnackBars();
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(
              'Location services are currently unavailable. Please try again later.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('Error showing location error message: $e');
    }
  }

  /// Force navigation to location permission screen
  /// This should be used when location is absolutely required
  static Future<bool> requireLocationPermission({
    String? customTitle,
    String? customDescription,
  }) async {
    return await checkAndRequestLocation(
      customTitle: customTitle ?? MyStrings.locationRequiredTitle,
      customDescription: customDescription ?? MyStrings.locationRequiredMessage,
      showSkipOption: false,
    );
  }

  /// Check location permission with optional navigation
  /// Shows a dialog if permission is denied and user can choose to enable or continue
  static Future<bool> checkLocationWithChoice({
    String? title,
    String? message,
    required VoidCallback onGranted,
    VoidCallback? onDenied,
  }) async {
    bool hasPermission = await isLocationPermissionGranted();

    if (hasPermission) {
      onGranted();
      return true;
    }

    // Show choice dialog
    bool? result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title ?? MyStrings.locationRequiredTitle),
        content: Text(message ?? MyStrings.locationRequiredMessage),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
              if (onDenied != null) {
                onDenied();
              }
            },
            child: Text(MyStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(result: true);
              bool granted = await requireLocationPermission();
              if (granted) {
                onGranted();
              } else if (onDenied != null) {
                onDenied();
              }
            },
            child: Text(MyStrings.enableLocationButton),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Quick permission check for controllers/services
  /// Returns null if no permission, throws exception with user-friendly message
  static Future<void> ensureLocationPermission({
    String? errorMessage,
  }) async {
    bool hasPermission = await isLocationPermissionGranted();

    if (!hasPermission) {
      throw LocationPermissionException(
        errorMessage ?? MyStrings.locationRequiredMessage,
      );
    }
  }
}

/// Custom exception for location permission issues
class LocationPermissionException implements Exception {
  final String message;

  const LocationPermissionException(this.message);

  @override
  String toString() => message;
}
