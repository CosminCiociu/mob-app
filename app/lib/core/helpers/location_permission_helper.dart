import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/my_strings.dart';
import '../../view/screens/location_permission/location_permission_screen.dart';

class LocationPermissionHelper {
  /// Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
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

      // Navigate to location permission screen
      final result = await Get.to<bool>(
        () => LocationPermissionScreen(
          customTitle: customTitle,
          customDescription: customDescription,
          showSkipOption: showSkipOption,
        ),
      );

      return result ?? false;
    } catch (e) {
      print('Error in checkAndRequestLocation: $e');
      return false;
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
