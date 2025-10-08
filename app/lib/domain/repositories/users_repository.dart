import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository interface for users data operations
abstract class UsersRepository {
  /// Query nearby users within a specified radius
  Future<List<DocumentSnapshot>> getNearbyUsers({
    required String currentUserId,
    required GeoPoint userLocation,
    required double radiusInKm,
  });

  /// Get users within a specific distance range
  Future<List<DocumentSnapshot>> getUsersInDistanceRange({
    required String currentUserId,
    required double distance,
  });

  /// Update user location data
  Future<void> updateUserLocation({
    required String userId,
    required Map<String, dynamic> locationData,
  });
}
