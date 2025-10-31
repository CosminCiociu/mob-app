import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/firebase_repository_base.dart';

/// Utility class for location-related operations
class LocationOperationsUtil {
  /// Check if location services are enabled and permissions are granted
  static Future<bool> checkLocationPermissions() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      FirebaseRepositoryBase.logWarning(
          'LocationUtil', 'Location services are disabled');
      return false;
    }

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      FirebaseRepositoryBase.logDebug(
          'LocationUtil', 'Requesting location permission');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        FirebaseRepositoryBase.logWarning(
            'LocationUtil', 'Location permission denied by user');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      FirebaseRepositoryBase.logError(
          'LocationUtil', 'Location permissions permanently denied');
      return false;
    }

    return true;
  }

  /// Get current device position
  static Future<Position?> getCurrentPosition() async {
    try {
      if (!await checkLocationPermissions()) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      FirebaseRepositoryBase.logInfo(
          'LocationUtil', 'Successfully obtained current position');
      return position;
    } catch (e) {
      FirebaseRepositoryBase.logError(
          'LocationUtil', 'Failed to get current position', e);
      return null;
    }
  }

  /// Get address from coordinates
  static Future<Placemark?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        FirebaseRepositoryBase.logInfo(
            'LocationUtil', 'Successfully obtained address');
        return placemarks.first;
      }
      return null;
    } catch (e) {
      FirebaseRepositoryBase.logError(
          'LocationUtil', 'Failed to get address from coordinates', e);
      return null;
    }
  }

  /// Calculate distance between two points in kilometers
  static double calculateDistance(GeoPoint point1, GeoPoint point2) {
    final distanceInMeters = Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
    return distanceInMeters / 1000; // Convert to kilometers
  }

  /// Get nearby documents using GeoFlutterFire
  static Future<List<DocumentSnapshot>> getNearbyDocuments({
    required String collectionName,
    required GeoPoint center,
    required double radiusInKm,
    required String geoField,
    String? excludeUserId,
  }) async {
    try {
      final centerPoint = GeoFirePoint(center);
      final geoQuery = GeoCollectionReference(
              FirebaseRepositoryBase.getCollection(collectionName))
          .subscribeWithin(
        center: centerPoint,
        radiusInKm: radiusInKm,
        field: geoField,
        geopointFrom: (data) {
          try {
            final parts = geoField.split('.');
            dynamic value = data;
            for (final part in parts) {
              value = value[part];
            }
            return value as GeoPoint;
          } catch (e) {
            // Return default GeoPoint if parsing fails
            return GeoPoint(0, 0);
          }
        },
      );

      final nearbyDocs = <DocumentSnapshot>[];
      await for (final docs in geoQuery) {
        for (final doc in docs) {
          // Exclude specific user if provided
          if (excludeUserId != null && doc.id == excludeUserId) {
            continue;
          }
          nearbyDocs.add(doc);
        }
        break; // Take only the first batch
      }

      FirebaseRepositoryBase.logInfo(
          'LocationUtil', 'Found ${nearbyDocs.length} nearby documents');
      return nearbyDocs;
    } catch (e) {
      FirebaseRepositoryBase.logError(
          'LocationUtil', 'Failed to get nearby documents', e);
      return [];
    }
  }

  /// Cache location data locally
  static Future<void> cacheLocationData(
      String key, Map<String, dynamic> locationData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, locationData.toString());
      await prefs.setInt(
          '${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      FirebaseRepositoryBase.logError(
          'LocationUtil', 'Failed to cache location data', e);
    }
  }

  /// Get cached location data
  static Future<Map<String, dynamic>?> getCachedLocationData(
    String key, {
    Duration maxAge = const Duration(hours: 1),
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationData = prefs.getString(key);
      final timestamp = prefs.getInt('${key}_timestamp');

      if (locationData != null && timestamp != null) {
        final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();

        if (now.difference(cachedTime) < maxAge) {
          // Parse the cached data - this is a simplified version
          // In practice, you'd want proper JSON serialization
          return {'data': locationData, 'timestamp': timestamp};
        }
      }
      return null;
    } catch (e) {
      FirebaseRepositoryBase.logError(
          'LocationUtil', 'Failed to get cached location data', e);
      return null;
    }
  }

  /// Clear cached location data
  static Future<void> clearCachedLocationData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      await prefs.remove('${key}_timestamp');
    } catch (e) {
      FirebaseRepositoryBase.logError(
          'LocationUtil', 'Failed to clear cached location data', e);
    }
  }

  /// Validate GeoPoint
  static bool isValidGeoPoint(dynamic geopoint) {
    return geopoint != null &&
        geopoint is GeoPoint &&
        geopoint.latitude >= -90 &&
        geopoint.latitude <= 90 &&
        geopoint.longitude >= -180 &&
        geopoint.longitude <= 180;
  }

  /// Create GeoPoint from coordinates
  static GeoPoint createGeoPoint(double latitude, double longitude) {
    // Clamp values to valid ranges
    final clampedLat = latitude.clamp(-90.0, 90.0);
    final clampedLng = longitude.clamp(-180.0, 180.0);
    return GeoPoint(clampedLat, clampedLng);
  }

  /// Extract location data from Firestore document
  static Map<String, dynamic>? extractLocationFromDocument(
      Map<String, dynamic> data) {
    return FirebaseRepositoryBase.safeGet<Map<String, dynamic>>(
        data, 'location');
  }

  /// Extract GeoPoint from location data
  static GeoPoint? extractGeoPointFromLocation(
      Map<String, dynamic>? locationData) {
    if (locationData == null) return null;

    final geopoint = locationData['geopoint'];
    return isValidGeoPoint(geopoint) ? geopoint as GeoPoint : null;
  }
}
