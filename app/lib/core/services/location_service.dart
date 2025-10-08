import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';

class LocationService {
  /// Get current user's location with permission handling
  static Future<Position> getCurrentLocation() async {
    // Step 1: Check and request permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    // Step 2: Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return position;
  }

  /// Convert coordinates to address
  static Future<Map<String, String>> getAddressFromLatLng(
      double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return {
          'fullAddress':
              '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}',
          'administrativeArea': '${place.administrativeArea ?? ''}',
          'locality': '${place.locality ?? ''}',
          'country': '${place.country ?? ''}',
          'name': '${place.name ?? ''}',
        };
      }
    } catch (e) {
      print("❌ Failed to get address from coordinates: $e");
    }

    return {
      'fullAddress': MyStrings.addressNotFound,
      'administrativeArea': MyStrings.addressNotFound,
      'locality': MyStrings.addressNotFound,
      'country': MyStrings.addressNotFound,
      'name': MyStrings.addressNotFound,
    };
  }

  /// Get location data with geohash for Firebase storage
  static Future<Map<String, dynamic>> getLocationDataForFirebase() async {
    final position = await getCurrentLocation();
    final addressMap =
        await getAddressFromLatLng(position.latitude, position.longitude);

    // Generate geohash using GeoFlutterFire
    final geoPoint = GeoPoint(position.latitude, position.longitude);
    final geoFirePoint = GeoFirePoint(geoPoint);
    final geohash = geoFirePoint.geohash;

    return {
      'lat': position.latitude,
      'lng': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'address': addressMap,
      'geohash': geohash,
      'geopoint': geoPoint,
    };
  }

  /// Update user's location in Firebase
  static Future<void> updateUserLocationInFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final locationData = await getLocationDataForFirebase();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'location': locationData,
      });

      print("✅ User location updated successfully in Firebase");
    } catch (e) {
      print("❌ Failed to update location in Firebase: $e");
      rethrow;
    }
  }

  /// Get user's saved location from Firebase
  static Future<Map<String, dynamic>?> getUserLocationFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data()?['location'] != null) {
        return userDoc.data()!['location'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("❌ Failed to get user location from Firebase: $e");
      return null;
    }
  }

  /// Get formatted address string for display
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
}
