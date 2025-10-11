import 'package:cloud_firestore/cloud_firestore.dart';

/// Service interface for matching and discovery operations
abstract class MatchingService {
  /// Search for events based on user preferences
  Future<List<DocumentSnapshot>> searchNearbyEvents({
    required double radiusInKm,
    required String? currentUserId,
  });

  /// Search for events quietly without showing snackbars (for initialization)
  Future<List<DocumentSnapshot>> searchNearbyEventsQuietly({
    required double radiusInKm,
    required String? currentUserId,
  });

  /// Search for users based on preferences
  Future<List<DocumentSnapshot>> searchNearbyUsers({
    required double radiusInKm,
    required String? currentUserId,
  });

  /// Update user location and refresh data
  Future<void> updateLocationAndRefresh();

  /// Demonstrate geohash features with user feedback
  Future<void> demonstrateGeohashFeatures();

  /// Get detailed error messages for better user experience
  String getDetailedErrorMessage(dynamic error);

  /// Validate search radius within acceptable limits
  bool isValidSearchRadius(double radius);
}
