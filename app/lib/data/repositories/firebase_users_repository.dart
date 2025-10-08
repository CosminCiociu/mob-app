import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../../domain/repositories/users_repository.dart';
import '../../core/utils/my_strings.dart';

/// Concrete implementation of UsersRepository using Firebase Firestore
class FirebaseUsersRepository implements UsersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<DocumentSnapshot>> getNearbyUsers({
    required String currentUserId,
    required GeoPoint userLocation,
    required double radiusInKm,
  }) async {
    try {
      // Create GeoFirePoint from user's location
      final centerPoint = GeoFirePoint(userLocation);

      // Query nearby users using geohash
      final geoQuery = GeoCollectionReference(_firestore.collection('users'))
          .subscribeWithin(
        center: centerPoint,
        radiusInKm: radiusInKm,
        field: 'location.geopoint',
        geopointFrom: (data) => data['location']['geopoint'] as GeoPoint,
      );

      final nearbyUsers = <DocumentSnapshot>[];
      await for (final docs in geoQuery) {
        for (final doc in docs) {
          // Exclude current user from results
          if (doc.id != currentUserId) {
            nearbyUsers.add(doc);
          }
        }
        break; // Take only the first batch for now
      }

      return nearbyUsers;
    } catch (e) {
      throw Exception('${MyStrings.failedToGetNearbyUsers}: $e');
    }
  }

  @override
  Future<List<DocumentSnapshot>> getUsersInDistanceRange({
    required String currentUserId,
    required double distance,
  }) async {
    try {
      // Get current user's location first
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();

      if (!userDoc.exists || userDoc.data()?['location'] == null) {
        throw Exception('User location not found');
      }

      final userLocation = userDoc.data()!['location'];
      final userGeoPoint = userLocation['geopoint'] as GeoPoint;

      return await getNearbyUsers(
        currentUserId: currentUserId,
        userLocation: userGeoPoint,
        radiusInKm: distance,
      );
    } catch (e) {
      throw Exception('Failed to get users in distance range: $e');
    }
  }

  @override
  Future<void> updateUserLocation({
    required String userId,
    required Map<String, dynamic> locationData,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'location': locationData,
      });
    } catch (e) {
      throw Exception('Failed to update user location: $e');
    }
  }
}
