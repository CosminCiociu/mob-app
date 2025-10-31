import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/users_repository.dart';
import '../../core/utils/firebase_repository_base.dart';
import '../../core/utils/location_operations_util.dart';

/// Concrete implementation of UsersRepository using Firebase Firestore
class FirebaseUsersRepository extends FirebaseRepositoryBase
    implements UsersRepository {
  static const String _repositoryName = 'FirebaseUsersRepository';

  @override
  Future<List<DocumentSnapshot>> getNearbyUsers({
    required String currentUserId,
    required GeoPoint userLocation,
    required double radiusInKm,
  }) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('get nearby users',
        () async {
      FirebaseRepositoryBase.logDebug(
          _repositoryName, 'Getting nearby users within ${radiusInKm}km');

      final nearbyUsers = await LocationOperationsUtil.getNearbyDocuments(
        collectionName: FirebaseRepositoryBase.usersCollection,
        center: userLocation,
        radiusInKm: radiusInKm,
        geoField: 'location.geopoint',
        excludeUserId: currentUserId,
      );

      FirebaseRepositoryBase.logInfo(
          _repositoryName, 'Found ${nearbyUsers.length} nearby users');
      return nearbyUsers;
    });
  }

  @override
  Future<List<DocumentSnapshot>> getUsersInDistanceRange({
    required String currentUserId,
    required double distance,
  }) async {
    return FirebaseRepositoryBase.executeWithErrorHandling(
        'get users in distance range', () async {
      FirebaseRepositoryBase.logDebug(_repositoryName,
          'Getting users within ${distance}km for user $currentUserId');

      // Get current user's location first
      final userDoc = await FirebaseRepositoryBase.firestore
          .collection(FirebaseRepositoryBase.usersCollection)
          .doc(currentUserId)
          .get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = FirebaseRepositoryBase.extractDocumentData(userDoc);
      final userLocation = userData['location'];

      if (userLocation == null) {
        throw Exception('User location not found');
      }

      final userGeoPoint = userLocation['geopoint'] as GeoPoint;

      return await getNearbyUsers(
        currentUserId: currentUserId,
        userLocation: userGeoPoint,
        radiusInKm: distance,
      );
    });
  }

  @override
  Future<void> updateUserLocation({
    required String userId,
    required Map<String, dynamic> locationData,
  }) async {
    return FirebaseRepositoryBase.executeWithErrorHandling(
        'update user location', () async {
      FirebaseRepositoryBase.logDebug(
          _repositoryName, 'Updating location for user $userId');

      await FirebaseRepositoryBase.firestore
          .collection(FirebaseRepositoryBase.usersCollection)
          .doc(userId)
          .update({'location': locationData});

      FirebaseRepositoryBase.logInfo(
          _repositoryName, 'Successfully updated user location');
    });
  }

  @override
  Future<DocumentSnapshot?> getUserById(String userId) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('get user by ID',
        () async {
      FirebaseRepositoryBase.logDebug(
          _repositoryName, 'Getting user by ID: $userId');

      final userDoc = await FirebaseRepositoryBase.firestore
          .collection(FirebaseRepositoryBase.usersCollection)
          .doc(userId)
          .get();

      final result = userDoc.exists ? userDoc : null;
      FirebaseRepositoryBase.logInfo(
          _repositoryName, 'User ${result != null ? 'found' : 'not found'}');

      return result;
    });
  }
}
