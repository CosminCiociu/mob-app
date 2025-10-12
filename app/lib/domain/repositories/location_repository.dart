import '../../data/model/location/location_model.dart';

/// Abstract repository interface for location operations
abstract class LocationRepository {
  /// Get user's current location from device GPS
  Future<LocationModel?> getCurrentLocation();

  /// Update user's location in Firebase
  Future<bool> updateUserLocationInFirebase(
      String userId, LocationModel location);

  /// Get user's saved location from Firebase
  Future<LocationModel?> getUserLocationFromFirebase(String userId);

  /// Cache location data locally
  Future<void> cacheLocation(LocationModel location);

  /// Get cached location data
  Future<LocationModel?> getCachedLocation();

  /// Clear cached location data
  Future<void> clearCachedLocation();
}
