import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/location_repository.dart';
import '../model/location/location_model.dart';
import '../model/location/address_model.dart';
import '../../core/helper/shared_preference_helper.dart';
import '../../core/utils/firebase_repository_base.dart';
import '../../core/utils/location_operations_util.dart';

/// Firebase implementation of LocationRepository
class FirebaseLocationRepository extends FirebaseRepositoryBase
    implements LocationRepository {
  static const String _repositoryName = 'FirebaseLocationRepository';

  @override
  Future<LocationModel?> getCurrentLocation() async {
    FirebaseRepositoryBase.logDebug(
        _repositoryName, 'Getting current location');

    try {
      // Use LocationOperationsUtil for permission checks and location retrieval
      final position = await LocationOperationsUtil.getCurrentPosition();
      if (position == null) {
        FirebaseRepositoryBase.logWarning(
            _repositoryName, 'Failed to get current position');
        return null;
      }

      // Get address from coordinates
      AddressModel? address;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          address = AddressModel.fromPlacemark(placemarks.first);
        }
      } catch (e) {
        FirebaseRepositoryBase.logWarning(
            _repositoryName, 'Failed to get address: $e');
      }

      final location = LocationModel.fromPosition(position, address: address);
      FirebaseRepositoryBase.logInfo(
          _repositoryName, 'Successfully got current location');
      return location;
    } catch (e) {
      FirebaseRepositoryBase.logError(
          _repositoryName, 'Error getting current location', e);
      return null;
    }
  }

  @override
  Future<bool> updateUserLocationInFirebase(
      String userId, LocationModel location) async {
    try {
      await FirebaseRepositoryBase.executeWithErrorHandling(
          'update user location in Firebase', () async {
        FirebaseRepositoryBase.logDebug(
            _repositoryName, 'Updating location for user $userId');

        await FirebaseRepositoryBase.firestore
            .collection(FirebaseRepositoryBase.usersCollection)
            .doc(userId)
            .update({
          'location': location.toFirebaseMap(),
          'lastLocationUpdate': FieldValue.serverTimestamp(),
        });

        FirebaseRepositoryBase.logInfo(
            _repositoryName, 'Successfully updated user location in Firebase');
      });
      return true;
    } catch (e) {
      FirebaseRepositoryBase.logError(
          _repositoryName, 'Error updating user location in Firebase', e);
      return false;
    }
  }

  @override
  Future<LocationModel?> getUserLocationFromFirebase(String userId) async {
    return FirebaseRepositoryBase.executeWithErrorHandling(
        'get user location from Firebase', () async {
      FirebaseRepositoryBase.logDebug(
          _repositoryName, 'Getting location for user $userId');

      final doc = await FirebaseRepositoryBase.firestore
          .collection(FirebaseRepositoryBase.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = FirebaseRepositoryBase.extractDocumentData(doc);
        if (data.containsKey('location')) {
          final location = LocationModel.fromFirebaseMap(data['location']);
          FirebaseRepositoryBase.logInfo(
              _repositoryName, 'Successfully retrieved user location');
          return location;
        }
      }

      FirebaseRepositoryBase.logWarning(
          _repositoryName, 'No location found for user $userId');
      return null;
    });
  }

  @override
  Future<void> cacheLocation(LocationModel location) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('cache location',
        () async {
      FirebaseRepositoryBase.logDebug(_repositoryName, 'Caching location');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          SharedPreferenceHelper.userLocationKey, location.toJson());
      await prefs.setInt(SharedPreferenceHelper.locationTimestampKey,
          DateTime.now().millisecondsSinceEpoch);

      FirebaseRepositoryBase.logInfo(
          _repositoryName, 'Successfully cached location');
    });
  }

  @override
  Future<LocationModel?> getCachedLocation() async {
    return FirebaseRepositoryBase.executeWithErrorHandling(
        'get cached location', () async {
      FirebaseRepositoryBase.logDebug(
          _repositoryName, 'Getting cached location');

      final prefs = await SharedPreferences.getInstance();
      final locationJson =
          prefs.getString(SharedPreferenceHelper.userLocationKey);
      final timestamp =
          prefs.getInt(SharedPreferenceHelper.locationTimestampKey);

      if (locationJson != null && timestamp != null) {
        // Check if cached location is still valid (within 1 hour)
        final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        const maxCacheAge = Duration(hours: 1);

        if (now.difference(cachedTime) < maxCacheAge) {
          final location = LocationModel.fromJson(locationJson);
          FirebaseRepositoryBase.logInfo(
              _repositoryName, 'Retrieved valid cached location');
          return location;
        } else {
          FirebaseRepositoryBase.logWarning(
              _repositoryName, 'Cached location is expired');
        }
      } else {
        FirebaseRepositoryBase.logWarning(
            _repositoryName, 'No cached location found');
      }

      return null;
    });
  }

  @override
  Future<void> clearCachedLocation() async {
    return FirebaseRepositoryBase.executeWithErrorHandling(
        'clear cached location', () async {
      FirebaseRepositoryBase.logDebug(
          _repositoryName, 'Clearing cached location');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SharedPreferenceHelper.userLocationKey);
      await prefs.remove(SharedPreferenceHelper.locationTimestampKey);

      FirebaseRepositoryBase.logInfo(
          _repositoryName, 'Successfully cleared cached location');
    });
  }
}
