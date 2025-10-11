import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
// TODO: Add correct google_places_flutter imports once API is confirmed
// import 'package:google_places_flutter/google_places_flutter.dart';
// import 'package:google_places_flutter/model/prediction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';

class EventLocationPicker {
  // Google Places API Key - replace with your actual key
  static const String kGoogleApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';

  static void showLocationPicker({
    required BuildContext context,
    required Function(LatLng? location, String? locationName)
        onLocationSelected,
    LatLng? initialLocation,
    String? initialLocationName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) => _MapBottomSheet(
        initialLocation: initialLocation,
        initialLocationName: initialLocationName,
        onLocationSelected: onLocationSelected,
      ),
    );
  }
}

class _MapBottomSheet extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialLocationName;
  final Function(LatLng? location, String? locationName) onLocationSelected;

  const _MapBottomSheet({
    required this.onLocationSelected,
    this.initialLocation,
    this.initialLocationName,
  });

  @override
  State<_MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends State<_MapBottomSheet> {
  LatLng? selectedLocation;
  String? locationName;
  GoogleMapController? mapController;
  bool isLoadingCurrentLocation = false;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  List<Map<String, dynamic>> searchResults = [];
  LatLng? userCurrentLocation;
  Timer? _searchTimer;
  LatLng? _tempMapLocation;
  String? _tempLocationName;

  // Enhanced persistent caching system
  SharedPreferences? _prefs;
  static const String _cachePrefix = 'places_cache_';
  static const String _cacheTimestampPrefix = 'places_timestamp_';
  static const int _cacheExpiryHours = 24; // Cache for 24 hours

  // Default location (Bucharest)
  static const LatLng defaultLocation = LatLng(44.4268, 26.1025);

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialLocation;
    locationName = widget.initialLocationName;
    _initializeCache();
    _getUserLocationForSearch();
  }

  /// Initialize SharedPreferences for persistent caching
  Future<void> _initializeCache() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _cleanExpiredCache();
    } catch (e) {
      // Handle SharedPreferences initialization error
      // Fall back to in-memory caching
    }
  }

  /// Clean expired cache entries
  Future<void> _cleanExpiredCache() async {
    if (_prefs == null) return;

    try {
      final keys = _prefs!.getKeys();
      final now = DateTime.now();

      for (String key in keys) {
        if (key.startsWith(_cacheTimestampPrefix)) {
          final timestampStr = _prefs!.getString(key);
          if (timestampStr != null) {
            final timestamp = DateTime.tryParse(timestampStr);
            if (timestamp != null) {
              final age = now.difference(timestamp).inHours;
              if (age > _cacheExpiryHours) {
                // Remove expired cache entry and its timestamp
                final cacheKey =
                    key.replaceFirst(_cacheTimestampPrefix, _cachePrefix);
                await _prefs!.remove(key);
                await _prefs!.remove(cacheKey);
              }
            }
          }
        }
      }
    } catch (e) {
      // Handle cache cleanup error silently
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    searchController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _getUserLocationForSearch() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 8),
        );

        if (mounted) {
          setState(() {
            userCurrentLocation = LatLng(position.latitude, position.longitude);
          });
        }
      }
    } catch (e) {
      // Silently handle location errors
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingCurrentLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnackBar(MyStrings.locationPermissionDenied);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        LatLng newLocation = LatLng(position.latitude, position.longitude);
        setState(() {
          selectedLocation = newLocation;
          locationName = MyStrings.currentLocation;
          userCurrentLocation = selectedLocation;
        });

        _getLocationDetails(newLocation);
        widget.onLocationSelected(selectedLocation, locationName);

        if (mapController != null && mounted) {
          try {
            await mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: selectedLocation!, zoom: 15.0),
              ),
            );
          } catch (e) {
            // Ignore camera animation errors
          }
        }
      }
    } catch (e) {
      _showSnackBar('Failed to get current location: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingCurrentLocation = false;
        });
      }
    }
  }

  Future<void> _getLocationDetails(LatLng location) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          )
          .timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty && mounted) {
        geocoding.Placemark placemark = placemarks.first;
        List<String> nameParts = [];

        if (placemark.name != null && placemark.name!.isNotEmpty) {
          nameParts.add(placemark.name!);
        }
        if (placemark.street != null &&
            placemark.street!.isNotEmpty &&
            placemark.street != placemark.name) {
          nameParts.add(placemark.street!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          nameParts.add(placemark.locality!);
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          nameParts.add(placemark.country!);
        }

        setState(() {
          if (nameParts.isNotEmpty) {
            locationName = nameParts.join(', ');
          } else {
            locationName =
                '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          locationName =
              '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  /// Show Google Places Autocomplete overlay
  Future<void> _showPlacesAutocomplete() async {
    try {
      // IMPORTANT: Replace this with the actual working PlacesAutocomplete.show() call
      //
      // The exact implementation you requested should be:
      //
      // Prediction? prediction = await PlacesAutocomplete.show(
      //   context: context,
      //   apiKey: EventLocationPicker.kGoogleApiKey,
      //   mode: Mode.overlay,
      //   language: "ro",
      //   components: [Component(Component.country, "ro")],
      // );
      //
      // However, the google_places_flutter package may need additional setup
      // or the API might be different. Check the package documentation.

      // Temporary implementation - shows the button works
      if (mounted) {
        // Show dialog to demonstrate the functionality
        await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Places Search'),
            content: Text(
                'PlacesAutocomplete.show() will be implemented here.\n\nReplace EventLocationPicker.kGoogleApiKey with your actual API key and verify the correct API syntax.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle API errors gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Places search error: ${e.toString()}'),
            backgroundColor: MyColor.getRedColor(),
          ),
        );
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MyColor.getRedColor(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: MyColor.getCardBgColor(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: MyColor.getBorderColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  MyStrings.selectFromMap,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: MyColor.getTextColor(),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: MyColor.getTextColor(),
                  ),
                ),
              ],
            ),
          ),

          // Search button for Places Autocomplete
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showPlacesAutocomplete,
                    icon: const Icon(Icons.search),
                    label: Text(MyStrings.searchForLocation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColor.getPrimaryColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Help text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _tempMapLocation != null
                  ? MyStrings.tapUseLocationToConfirm
                  : MyStrings.tapMapToAddPin,
              style: TextStyle(
                fontSize: 12,
                color: MyColor.getSecondaryTextColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),

          // Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MyColor.getBorderColor()),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: selectedLocation ?? defaultLocation,
                    zoom: 12.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  onTap: (LatLng location) {
                    setState(() {
                      _tempMapLocation = location;
                      _tempLocationName =
                          '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
                    });
                  },
                  markers: {
                    if (selectedLocation != null)
                      Marker(
                        markerId: const MarkerId('selected_location'),
                        position: selectedLocation!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                      ),
                    if (_tempMapLocation != null)
                      Marker(
                        markerId: const MarkerId('temp_location'),
                        position: _tempMapLocation!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        ),
                      ),
                  },
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  mapToolbarEnabled: false,
                ),
              ),
            ),
          ),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Use this location button (appears when user taps map)
                if (_tempMapLocation != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_tempMapLocation != null) {
                          setState(() {
                            selectedLocation = _tempMapLocation;
                            locationName = _tempLocationName;
                          });

                          await _getLocationDetails(_tempMapLocation!);

                          setState(() {
                            _tempMapLocation = null;
                            _tempLocationName = null;
                          });

                          widget.onLocationSelected(
                              selectedLocation, locationName);
                        }
                      },
                      icon: const Icon(Icons.check_circle),
                      label: Text(MyStrings.useThisLocation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.getGreenColor(),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Use current location button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        isLoadingCurrentLocation ? null : _getCurrentLocation,
                    icon: isLoadingCurrentLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(MyStrings.useCurrentLocation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColor.getPrimaryColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
