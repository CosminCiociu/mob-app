import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'address_model.dart';

/// Model representing a location with coordinates, address, and Firebase data
class LocationModel {
  final double lat;
  final double lng;
  final AddressModel address;
  final String geohash;
  final GeoPoint geopoint;
  final Timestamp? timestamp;

  LocationModel({
    required this.lat,
    required this.lng,
    required this.address,
    required this.geohash,
    required this.geopoint,
    this.timestamp,
  });

  /// Create LocationModel from coordinates and address
  factory LocationModel.fromCoordinates({
    required double lat,
    required double lng,
    required AddressModel address,
  }) {
    final geoPoint = GeoPoint(lat, lng);
    final geoFirePoint = GeoFirePoint(geoPoint);

    return LocationModel(
      lat: lat,
      lng: lng,
      address: address,
      geohash: geoFirePoint.geohash,
      geopoint: geoPoint,
      timestamp: Timestamp.now(),
    );
  }

  /// Create LocationModel from Firebase document data
  factory LocationModel.fromFirebaseData(Map<String, dynamic> data) {
    return LocationModel(
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      address: AddressModel.fromMap(data['address'] as Map<String, dynamic>),
      geohash: data['geohash'] as String,
      geopoint: data['geopoint'] as GeoPoint,
      timestamp: data['timestamp'] as Timestamp?,
    );
  }

  /// Convert to Firebase document data
  Map<String, dynamic> toFirebaseData() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address.toMap(),
      'geohash': geohash,
      'geopoint': geopoint,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }

  /// Get display-friendly address string
  String get displayAddress => address.displayAddress;

  /// Get full address string
  String get fullAddress => address.fullAddress;

  /// Check if this location is valid (has coordinates)
  bool get isValid => lat != 0.0 || lng != 0.0;

  @override
  String toString() {
    return 'LocationModel(lat: $lat, lng: $lng, address: ${address.displayAddress})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.lat == lat &&
        other.lng == lng &&
        other.address == address;
  }

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode ^ address.hashCode;

  /// Create LocationModel from Position object
  factory LocationModel.fromPosition(Position position,
      {AddressModel? address}) {
    final geoPoint = GeoPoint(position.latitude, position.longitude);
    final geoFirePoint = GeoFirePoint(geoPoint);

    return LocationModel(
      lat: position.latitude,
      lng: position.longitude,
      address: address ?? AddressModel.empty(),
      geohash: geoFirePoint.geohash,
      geopoint: geoPoint,
      timestamp: Timestamp.now(),
    );
  }

  /// Create LocationModel from Firebase map (alias for fromFirebaseData)
  static LocationModel fromFirebaseMap(Map<String, dynamic> data) {
    return LocationModel.fromFirebaseData(data);
  }

  /// Alias for toFirebaseData to match repository interface
  Map<String, dynamic> toFirebaseMap() {
    return toFirebaseData();
  }

  /// Convert to JSON string for caching
  String toJson() {
    return jsonEncode({
      'lat': lat,
      'lng': lng,
      'address': address.toMap(),
      'geohash': geohash,
      'timestamp': timestamp?.millisecondsSinceEpoch,
    });
  }

  /// Create LocationModel from JSON string
  factory LocationModel.fromJson(String jsonStr) {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    return LocationModel(
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      address: AddressModel.fromMap(data['address'] as Map<String, dynamic>),
      geohash: data['geohash'] as String,
      geopoint: GeoPoint(
        (data['lat'] as num).toDouble(),
        (data['lng'] as num).toDouble(),
      ),
      timestamp: data['timestamp'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(data['timestamp'] as int)
          : null,
    );
  }
}
