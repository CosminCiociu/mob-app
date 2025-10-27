import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/location_repository.dart';
import '../model/location/location_model.dart';
import '../model/location/address_model.dart';

import '../../core/helper/shared_preference_helper.dart';

/// Firebase implementation of LocationRepository
class FirebaseLocationRepository implements LocationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<LocationModel?> getCurrentLocation() async {
    try {
      // Check location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print(
            '📍 Location services are disabled. Please enable location in device settings.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('📍 Requesting location permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print(
              '🚫 Location access denied by user. Events require location to be shown.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print(
            '🚫 Location permissions permanently denied. Please enable location in app settings to see events.');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
        print('Failed to get address: $e');
      }

      return LocationModel.fromPosition(position, address: address);
    } catch (e) {
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('permission') ||
          errorString.contains('denied') ||
          errorString.contains('user denied')) {
        print('🚫 Location permission denied: $e');
      } else if (errorString.contains('location service') ||
          errorString.contains('disabled')) {
        print('📍 Location services disabled: $e');
      } else if (errorString.contains('timeout')) {
        print('⏱️ Location request timed out: $e');
      } else {
        print('❌ Error getting current location: $e');
      }

      return null;
    }
  }

  @override
  Future<bool> updateUserLocationInFirebase(
      String userId, LocationModel location) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'location': location.toFirebaseMap(),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating user location in Firebase: $e');
      return false;
    }
  }

  @override
  Future<LocationModel?> getUserLocationFromFirebase(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('location')) {
          return LocationModel.fromFirebaseMap(data['location']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting user location from Firebase: $e');
      return null;
    }
  }

  @override
  Future<void> cacheLocation(LocationModel location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          SharedPreferenceHelper.userLocationKey, location.toJson());
      await prefs.setInt(SharedPreferenceHelper.locationTimestampKey,
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching location: $e');
    }
  }

  @override
  Future<LocationModel?> getCachedLocation() async {
    try {
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
          return LocationModel.fromJson(locationJson);
        }
      }
      return null;
    } catch (e) {
      print('Error getting cached location: $e');
      return null;
    }
  }

  @override
  Future<void> clearCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SharedPreferenceHelper.userLocationKey);
      await prefs.remove(SharedPreferenceHelper.locationTimestampKey);
    } catch (e) {
      print('Error clearing cached location: $e');
    }
  }
}
