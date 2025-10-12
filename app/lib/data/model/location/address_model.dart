import 'package:geocoding/geocoding.dart';
import '../../../core/utils/my_strings.dart';

/// Model representing an address with various components
class AddressModel {
  final String name;
  final String locality;
  final String administrativeArea;
  final String country;
  final String fullAddress;

  AddressModel({
    required this.name,
    required this.locality,
    required this.administrativeArea,
    required this.country,
    required this.fullAddress,
  });

  /// Create AddressModel from geocoding placemark data
  factory AddressModel.fromPlacemark(Placemark placemark) {
    final safeName = placemark.name ?? '';
    final safeLocality = placemark.locality ?? '';
    final safeAdministrativeArea = placemark.administrativeArea ?? '';
    final safeCountry = placemark.country ?? '';

    final fullAddress = [
      safeName,
      safeLocality,
      safeAdministrativeArea,
      safeCountry
    ].where((part) => part.isNotEmpty).join(', ');

    return AddressModel(
      name: safeName,
      locality: safeLocality,
      administrativeArea: safeAdministrativeArea,
      country: safeCountry,
      fullAddress:
          fullAddress.isEmpty ? MyStrings.addressNotFound : fullAddress,
    );
  }

  /// Create AddressModel from geocoding placemark data (legacy named parameters)
  factory AddressModel.fromPlacemarkData({
    String? name,
    String? locality,
    String? administrativeArea,
    String? country,
  }) {
    final safeName = name ?? '';
    final safeLocality = locality ?? '';
    final safeAdministrativeArea = administrativeArea ?? '';
    final safeCountry = country ?? '';

    final fullAddress = [
      safeName,
      safeLocality,
      safeAdministrativeArea,
      safeCountry
    ].where((part) => part.isNotEmpty).join(', ');

    return AddressModel(
      name: safeName,
      locality: safeLocality,
      administrativeArea: safeAdministrativeArea,
      country: safeCountry,
      fullAddress:
          fullAddress.isEmpty ? MyStrings.addressNotFound : fullAddress,
    );
  }

  /// Create AddressModel from Firebase data map
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      name: map['name'] as String? ?? '',
      locality: map['locality'] as String? ?? '',
      administrativeArea: map['administrativeArea'] as String? ?? '',
      country: map['country'] as String? ?? '',
      fullAddress: map['fullAddress'] as String? ?? MyStrings.addressNotFound,
    );
  }

  /// Create a fallback AddressModel when address lookup fails
  factory AddressModel.notFound() {
    return AddressModel(
      name: MyStrings.addressNotFound,
      locality: MyStrings.addressNotFound,
      administrativeArea: MyStrings.addressNotFound,
      country: MyStrings.addressNotFound,
      fullAddress: MyStrings.addressNotFound,
    );
  }

  /// Create an empty AddressModel
  factory AddressModel.empty() {
    return AddressModel(
      name: '',
      locality: '',
      administrativeArea: '',
      country: '',
      fullAddress: '',
    );
  }

  /// Convert to Firebase-compatible map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'locality': locality,
      'administrativeArea': administrativeArea,
      'country': country,
      'fullAddress': fullAddress,
    };
  }

  /// Get display-friendly address string (prioritizes locality and administrative area)
  String get displayAddress {
    if (locality.isNotEmpty && administrativeArea.isNotEmpty) {
      return '$locality, $administrativeArea';
    } else if (locality.isNotEmpty) {
      return locality;
    } else if (administrativeArea.isNotEmpty) {
      return administrativeArea;
    } else if (name.isNotEmpty) {
      return name;
    } else {
      return fullAddress;
    }
  }

  /// Check if this address has valid data
  bool get isValid =>
      fullAddress != MyStrings.addressNotFound && fullAddress.isNotEmpty;

  /// Check if this address is not found
  bool get isNotFound => !isValid;

  @override
  String toString() {
    return 'AddressModel(displayAddress: $displayAddress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressModel &&
        other.name == name &&
        other.locality == locality &&
        other.administrativeArea == administrativeArea &&
        other.country == country &&
        other.fullAddress == fullAddress;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        locality.hashCode ^
        administrativeArea.hashCode ^
        country.hashCode ^
        fullAddress.hashCode;
  }
}
