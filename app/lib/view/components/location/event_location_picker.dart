import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/config/app_config.dart';
import 'package:ovo_meet/core/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A location picker widget that integrates with Google Maps and Firebase user locations.
///
/// Location initialization priority:
/// 1. Uses provided initialLocation if specified
/// 2. Retrieves authenticated user's stored location from Firebase
/// 3. Falls back to current GPS location automatically
/// 4. Uses default location as last resort
class EventLocationPicker extends StatefulWidget {
  final Function(LatLng location, String locationName) onLocationSelected;
  final LatLng? initialLocation;
  final String? initialLocationName;

  const EventLocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
    this.initialLocationName,
  });

  @override
  State<EventLocationPicker> createState() => _EventLocationPickerState();

  static Future<void> showLocationPicker({
    required BuildContext context,
    required Function(LatLng location, String locationName) onLocationSelected,
    LatLng? initialLocation,
    String? initialLocationName,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: MyColor.getCardBgColor(),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: EventLocationPicker(
          onLocationSelected: onLocationSelected,
          initialLocation: initialLocation,
          initialLocationName: initialLocationName,
        ),
      ),
    );
  }
}

class _EventLocationPickerState extends State<EventLocationPicker> {
  late GoogleMapController mapController;
  LatLng _currentPosition = const LatLng(37.7749, -122.4194); // Default to SF
  final Set<Marker> _markers = {};
  String _selectedLocationName = '';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialLocation != null) {
      _currentPosition = widget.initialLocation!;
      _selectedLocationName = widget.initialLocationName ?? '';
      _addMarker(_currentPosition, _selectedLocationName);
    } else {
      // Try to get user's authenticated location first, then fall back to current location
      _initializeUserLocation();
    }
  }

  Future<void> _initializeUserLocation() async {
    try {
      // First try to get user's stored location from Firebase
      final userLocationData =
          await LocationService.getUserLocationFromFirebase();

      if (userLocationData != null && mounted) {
        // Extract location data
        final geoPoint = userLocationData['geopoint'] as GeoPoint;
        final userLocation = LatLng(geoPoint.latitude, geoPoint.longitude);

        // Get location name from address data
        String locationName = MyStrings.currentLocation;
        if (userLocationData['address'] != null) {
          final address = userLocationData['address'] as Map<String, dynamic>;
          final fullAddress = address['fullAddress'] as String? ?? '';
          if (fullAddress.isNotEmpty &&
              fullAddress != MyStrings.addressNotFound) {
            locationName = fullAddress;
          }
        }

        // Set as initial location
        _currentPosition = userLocation;
        _selectedLocationName = locationName;
        _addMarker(_currentPosition, _selectedLocationName);

        // Move camera to user location (will be handled by onMapCreated if map isn't ready)
        // Store the location for later camera movement in onMapCreated

        return; // Successfully initialized with user's stored location
      }
    } catch (e) {
      print('Failed to get user location from Firebase: $e');
    }

    // Fallback: Try to get current location automatically
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _getCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Move camera to the current position with marker (whether from initial location or user location)
    if (_markers.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(_currentPosition, 15),
          );
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );

      if (!serviceEnabled) {
        _showSnackBar(MyStrings.locationNotAvailable);
        return;
      }

      // Check and request permissions with timeout
      LocationPermission permission =
          await Geolocator.checkPermission().timeout(
        const Duration(seconds: 5),
      );

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 10),
        );
        if (permission == LocationPermission.denied) {
          _showSnackBar(MyStrings.locationPermissionDenied);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(MyStrings.locationPermissionDenied);
        return;
      }

      // Get current position with timeout and lower accuracy for emulator compatibility
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 15),
      ).timeout(
        const Duration(seconds: 15),
      );

      _currentPosition = LatLng(position.latitude, position.longitude);

      // Get address from coordinates with timeout
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 10));

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          _selectedLocationName = [
            place.name,
            place.locality,
            place.country,
          ]
              .where((element) => element != null && element.isNotEmpty)
              .join(', ');

          if (_selectedLocationName.isEmpty) {
            _selectedLocationName = MyStrings.currentLocation;
          }
        } else {
          _selectedLocationName = MyStrings.currentLocation;
        }
      } catch (geocodingError) {
        // Fallback to coordinates if geocoding fails
        _selectedLocationName =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }

      _addMarker(_currentPosition, _selectedLocationName);
      if (mounted) {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 15),
        );
      }
    } on TimeoutException {
      _showSnackBar('Location request timed out. Please try again.');
    } catch (e) {
      print('Location error: $e');
      _showSnackBar(MyStrings.unableToGetLocation);
    } finally {
      // Location fetching completed
    }
  }

  void _addMarker(LatLng position, String title) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId("selectedLocation"),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  void _onMapTap(LatLng position) async {
    _currentPosition = position;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        _selectedLocationName = [
          place.name,
          place.locality,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        if (_selectedLocationName.isEmpty) {
          _selectedLocationName =
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        }
      } else {
        _selectedLocationName =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      // Fallback to coordinates if geocoding fails
      _selectedLocationName =
          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    }

    if (mounted) {
      _addMarker(position, _selectedLocationName);
      mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: MyColor.getPrimaryColor(),
        ),
      );
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query)}&key=${AppConfig.googleMapsApiKey}';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            _searchResults = List<Map<String, dynamic>>.from(
              data['predictions'].map((prediction) => {
                    'description': prediction['description'],
                    'place_id': prediction['place_id'],
                  }),
            );
          });
        } else {
          setState(() {
            _searchResults = [];
          });
        }
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _selectPlace(String placeId, String description) async {
    try {
      setState(() {
        _isSearching = true;
        _searchResults = [];
      });

      final String url =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${AppConfig.googleMapsApiKey}';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final lat = location['lat'];
          final lng = location['lng'];

          _currentPosition = LatLng(lat, lng);
          _selectedLocationName = description;
          _addMarker(_currentPosition, description);

          _searchController.text = description;

          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(_currentPosition, 15),
          );
        }
      }
    } catch (e) {
      print('Place details error: $e');
      _showSnackBar('Failed to get place details');
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _confirmSelection() {
    if (_markers.isNotEmpty) {
      widget.onLocationSelected(_currentPosition, _selectedLocationName);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(Dimensions.space15),
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: MyColor.getGreyColor(),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: Dimensions.space15),

                // Title and close button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        MyStrings.selectLocation,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: MyColor.getTextColor(),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: MyColor.getIconColor(),
                      ),
                    ),
                  ],
                ),

                // Search bar with suggestions
                Container(
                  margin: const EdgeInsets.only(top: Dimensions.space10),
                  decoration: BoxDecoration(
                    border: Border.all(color: MyColor.getBorderColor()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: MyStrings.searchForLocation,
                          hintStyle: TextStyle(
                            color: MyColor.getSecondaryTextColor(),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: MyColor.getIconColor(),
                          ),
                          suffixIcon: _isSearching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onChanged: (value) {
                          _searchPlaces(value);
                        },
                        onSubmitted: (value) {
                          if (value.isNotEmpty && _searchResults.isEmpty) {
                            // Fallback for direct text entry
                            _selectedLocationName = value;
                            _addMarker(_currentPosition, value);
                          }
                        },
                      ),
                      // Search results dropdown
                      if (_searchResults.isNotEmpty) ...[
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              return ListTile(
                                leading: Icon(
                                  Icons.location_on,
                                  color: MyColor.getPrimaryColor(),
                                  size: 20,
                                ),
                                title: Text(
                                  result['description'],
                                  style: TextStyle(
                                    color: MyColor.getTextColor(),
                                    fontSize: 14,
                                  ),
                                ),
                                onTap: () {
                                  _selectPlace(
                                    result['place_id'],
                                    result['description'],
                                  );
                                  setState(() {
                                    _searchResults = [];
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Map
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 11,
              ),
              markers: _markers,
              onTap: _onMapTap,
              myLocationEnabled: false, // Disable to prevent crashes
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),

          // Bottom selection area
          Container(
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: BoxDecoration(
              color: MyColor.getCardBgColor(),
              boxShadow: [
                BoxShadow(
                  color: MyColor.getShadowColor().withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedLocationName.isNotEmpty) ...[
                  Text(
                    'Selected Location:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: MyColor.getSecondaryTextColor(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedLocationName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MyColor.getTextColor(),
                    ),
                  ),
                  const SizedBox(height: Dimensions.space15),
                ] else ...[
                  Text(
                    MyStrings.tapMapToAddPin,
                    style: TextStyle(
                      fontSize: 14,
                      color: MyColor.getSecondaryTextColor(),
                    ),
                  ),
                  const SizedBox(height: Dimensions.space15),
                ],

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _markers.isEmpty ? null : _confirmSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColor.getPrimaryColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      MyStrings.useThisLocation,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
