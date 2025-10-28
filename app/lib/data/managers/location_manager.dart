import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/location_service.dart';
import '../../../core/helpers/location_permission_helper.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';

/// Manages all location-related functionality
class LocationManager {
  final TextEditingController addressController;
  final VoidCallback? onLocationUpdated;
  bool _isDisposed = false;

  LocationManager({
    required this.addressController,
    this.onLocationUpdated,
  });

  /// Initialize location - gets saved location or sets default message
  Future<void> initializeLocation() async {
    _setInitialAddress();
    await _getUserLocationFromFirebase();
  }

  /// Set initial address display
  void _setInitialAddress() {
    if (_isDisposed) return;
    if (addressController.text.isEmpty) {
      addressController.text = 'Finding your location...';
    }
  }

  /// Get user's current location from Firebase using LocationService
  Future<void> _getUserLocationFromFirebase() async {
    if (_isDisposed) return;
    try {
      print('📍 Fetching user location using LocationService...');
      final location = await LocationService.getUserLocationFromFirebase();

      if (_isDisposed) return;
      if (location != null && location.isValid) {
        final locationText = location.displayAddress;
        print('📍 Setting location display to: $locationText');
        addressController.text = locationText;
        onLocationUpdated?.call();
        return;
      } else {
        print('📍 No valid location data found in Firebase');
      }
    } catch (e) {
      print('❌ Error getting user location from Firebase: $e');
    }

    // Fallback if no location found
    if (_isDisposed) return;
    print('📍 Falling back to "Finding your location..."');
    addressController.text = 'Finding your location...';
    onLocationUpdated?.call();
  }

  /// Ensure user has location, get it if needed
  Future<bool> ensureUserHasLocation() async {
    if (_isDisposed) return false;
    try {
      print('🔄 Ensuring user location...');

      // Check existing location first
      final existingLocation =
          await LocationService.getUserLocationFromFirebase();
      if (_isDisposed) return false;
      if (existingLocation != null && existingLocation.isValid) {
        print('✅ Found existing location');
        return true;
      }

      print('📍 No location found, attempting to get current location...');

      // Try to get current location with timeout
      final success = await LocationService.updateUserLocationInFirebase()
          .timeout(const Duration(seconds: 10));

      if (_isDisposed) return false;
      if (success) {
        print('✅ Location updated successfully');
        await _getUserLocationFromFirebase();
        return true;
      } else {
        print('⚠️ Could not get location');
        _setLocationErrorState('Location required to find events');
        return false;
      }
    } on TimeoutException catch (e) {
      print('⏱️ Location request timed out: $e');
      _setLocationErrorState('Location timeout - tap to retry');
      _showTimeoutMessage();
      return false;
    } catch (locationError) {
      return _handleLocationError(locationError);
    }
  }

  /// Handle specific location errors
  bool _handleLocationError(dynamic locationError) {
    final errorString = locationError.toString().toLowerCase();

    if (errorString.contains('permission') || errorString.contains('denied')) {
      print('🚫 Location permission denied: $locationError');
      _setLocationErrorState('Tap to enable location & find events');
      _showPermissionMessage();
      return false;
    }

    print('❌ General location error: $locationError');
    _setLocationErrorState('Unable to get location');
    return false;
  }

  /// Force update location when user requests it
  Future<bool> forceLocationUpdate() async {
    if (_isDisposed) return false;
    print('🔄 Force location update requested');

    // Check permission first
    final hasPermission =
        await LocationPermissionHelper.isLocationPermissionGranted();
    if (_isDisposed) return false;
    if (!hasPermission) {
      return await _requestLocationPermission();
    }

    addressController.text = 'Updating location...';
    onLocationUpdated?.call();

    try {
      final success = await LocationService.updateUserLocationInFirebase()
          .timeout(const Duration(seconds: 15));

      if (_isDisposed) return false;
      if (success) {
        print('✅ Location force updated successfully');
        await _getUserLocationFromFirebase();
        return true;
      } else {
        print('⚠️ Force location update failed');
        _showLocationUpdateHelpMessage();
        return false;
      }
    } catch (e) {
      print('❌ Force location update failed: $e');
      _showLocationUpdateHelpMessage();
      return false;
    }
  }

  /// Request location permission and handle result
  Future<bool> _requestLocationPermission() async {
    if (_isDisposed) return false;
    print('🚫 Requesting location permission');
    final result = await LocationPermissionHelper.requireLocationPermission(
      customTitle: MyStrings.enableLocationToFindEvents,
      customDescription: MyStrings.locationPermissionRequired,
    );

    if (_isDisposed) return false;
    if (result) {
      print('✅ Location permission granted');
      return await ensureUserHasLocation();
    } else {
      print('❌ Location permission denied');
      addressController.text = MyStrings.tapToEnableLocation;
      onLocationUpdated?.call();
      return false;
    }
  }

  /// Set location error state
  void _setLocationErrorState(String message) {
    if (_isDisposed) return;
    addressController.text = message;
    onLocationUpdated?.call();
  }

  /// Show timeout message to user
  void _showTimeoutMessage() {
    if (_isDisposed) return;
    CustomSnackBar.infoDeferred(
      infoList: [
        'Location request timed out. Please check your GPS signal and try again.'
      ],
    );
  }

  /// Show permission message to user
  void _showPermissionMessage() {
    if (_isDisposed) return;
    CustomSnackBar.infoDeferred(
      infoList: [
        'Location access is needed to show nearby events. Please enable location permission in your device settings.'
      ],
    );
  }

  /// Show location update help message
  void _showLocationUpdateHelpMessage() {
    if (_isDisposed) return;
    final errorString = addressController.text.toLowerCase();

    if (errorString.contains('permission') || errorString.contains('denied')) {
      addressController.text = MyStrings.tapToEnableLocation;
    } else if (errorString.contains('service') ||
        errorString.contains('disabled')) {
      addressController.text = MyStrings.pleaseEnableLocationServices;
    } else {
      addressController.text = MyStrings.tapToRetryLocation;
    }

    onLocationUpdated?.call();

    // Revert to fallback location after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isDisposed) {
        _getUserLocationFromFirebase();
      }
    });
  }

  /// Change selected address manually
  void changeSelectedAddress(String address) {
    if (_isDisposed) return;
    addressController.text = address;
    CustomSnackBar.successDeferred(successList: ['Address selected: $address']);
    onLocationUpdated?.call();
  }

  /// Check if location is available
  Future<bool> hasValidLocation() async {
    if (_isDisposed) return false;
    final location = await LocationService.getUserLocationFromFirebase();
    return location != null && location.isValid;
  }

  /// Dispose resources
  void dispose() {
    _isDisposed = true;
  }
}
