import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/location_repository.dart';
import '../../data/repositories/firebase_location_repository.dart';
import '../../data/model/location/location_model.dart';
import '../utils/my_strings.dart';

/// Service for location operations using repository pattern
class LocationService {
  static final LocationRepository _repository = FirebaseLocationRepository();

  /// Get current user's location with caching
  static Future<LocationModel?> getCurrentLocation() async {
    try {
      // Try to get cached location first
      final cachedLocation = await _repository.getCachedLocation();
      if (cachedLocation != null) {
        print('✅ Using cached location: ${cachedLocation.displayAddress}');
        return cachedLocation;
      }

      // Get fresh location from device
      final location = await _repository.getCurrentLocation();
      if (location != null) {
        // Cache the fresh location
        await _repository.cacheLocation(location);
        print('✅ Got fresh location: ${location.displayAddress}');
        return location;
      }

      print('❌ Unable to get current location');
      return null;
    } catch (e) {
      print('❌ Error getting current location: $e');
      return null;
    }
  }

  /// Update user's location in Firebase
  static Future<bool> updateUserLocationInFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Cannot update location: User not logged in');
        return false;
      }

      final location = await getCurrentLocation();
      if (location == null) {
        print('❌ Cannot update location: Unable to get current location');
        return false;
      }

      final success =
          await _repository.updateUserLocationInFirebase(user.uid, location);
      if (success) {
        print('✅ User location updated successfully in Firebase');
      } else {
        print('❌ Failed to update user location in Firebase');
      }
      return success;
    } catch (e) {
      print('❌ Error updating user location in Firebase: $e');
      return false;
    }
  }

  /// Get user's saved location from Firebase
  static Future<LocationModel?> getUserLocationFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Cannot get location: User not logged in');
        return null;
      }

      final location = await _repository.getUserLocationFromFirebase(user.uid);
      if (location != null) {
        print('✅ Got user location from Firebase: ${location.displayAddress}');
      } else {
        print('❌ No saved location found in Firebase');
      }
      return location;
    } catch (e) {
      print('❌ Error getting user location from Firebase: $e');
      return null;
    }
  }

  /// Get location data for Firebase storage (legacy support)
  @Deprecated('Use getCurrentLocation() instead')
  static Future<Map<String, dynamic>?> getLocationDataForFirebase() async {
    final location = await getCurrentLocation();
    return location?.toFirebaseData();
  }

  /// Get location data for Firebase storage safely (legacy support)
  @Deprecated('Use getCurrentLocation() instead')
  static Future<Map<String, dynamic>?>
      getLocationDataForFirebaseSafely() async {
    final location = await getCurrentLocation();
    return location?.toFirebaseData();
  }

  /// Get formatted address string for display (legacy support)
  @Deprecated('Use LocationModel.displayAddress instead')
  static String getDisplayAddress(Map<String, String> addressMap) {
    final locality = addressMap['locality'] ?? '';
    final name = addressMap['name'] ?? '';

    if (locality.isNotEmpty && name.isNotEmpty) {
      return '$locality, $name';
    } else if (locality.isNotEmpty) {
      return locality;
    } else if (name.isNotEmpty) {
      return name;
    } else {
      return addressMap['fullAddress'] ?? MyStrings.addressNotFound;
    }
  }

  /// Convert coordinates to address (legacy support)
  @Deprecated('Use LocationModel and AddressModel instead')
  static Future<Map<String, String>> getAddressFromLatLng(
      double lat, double lng) async {
    // This is kept for backward compatibility, but new code should use LocationModel
    try {
      final location = await _repository.getCurrentLocation();
      if (location != null && location.lat == lat && location.lng == lng) {
        return {
          'fullAddress': location.address.fullAddress,
          'administrativeArea': location.address.administrativeArea,
          'locality': location.address.locality,
          'country': location.address.country,
          'name': location.address.name,
        };
      }
    } catch (e) {
      print('❌ Error getting address from coordinates: $e');
    }

    return {
      'fullAddress': MyStrings.addressNotFound,
      'administrativeArea': MyStrings.addressNotFound,
      'locality': MyStrings.addressNotFound,
      'country': MyStrings.addressNotFound,
      'name': MyStrings.addressNotFound,
    };
  }

  /// Clear cached location data
  static Future<void> clearCachedLocation() async {
    await _repository.clearCachedLocation();
    print('✅ Cached location data cleared');
  }
}
