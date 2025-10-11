import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Add these dependencies to pubspec.yaml: flutter_google_places: ^0.3.0 and google_maps_webservice: ^0.0.20-nullsafety.5
// import 'package:flutter_google_places/flutter_google_places.dart';
// import 'package:google_maps_webservice/places.dart';

import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';

class EventLocationPickedPlaces {
  // Google Places API Key - replace with your actual key
  static const String kGoogleApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';

  /// Show Places Autocomplete picker that returns location results
  static Future<LocationResult?> showPlacesSearch({
    required BuildContext context,
  }) async {
    return await showModalBottomSheet<LocationResult?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => const _PlacesSearchBottomSheet(),
    );
  }
}

/// Data class to hold location search results
class LocationResult {
  final LatLng location;
  final String locationName;
  final String? address;
  final String? placeId;

  LocationResult({
    required this.location,
    required this.locationName,
    this.address,
    this.placeId,
  });

  @override
  String toString() {
    return 'LocationResult(location: $location, name: $locationName, address: $address)';
  }
}

class _PlacesSearchBottomSheet extends StatefulWidget {
  const _PlacesSearchBottomSheet();

  @override
  State<_PlacesSearchBottomSheet> createState() =>
      _PlacesSearchBottomSheetState();
}

class _PlacesSearchBottomSheetState extends State<_PlacesSearchBottomSheet> {
  List<LocationResult> searchResults = [];
  bool isSearching = false;
  String lastSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                  MyStrings.searchForLocation,
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

          // Search button - main functionality
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showPlacesAutocomplete,
                    icon: isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                        isSearching ? 'Searching...' : 'Open Places Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColor.getPrimaryColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Info text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              searchResults.isEmpty
                  ? 'Tap the search button to find locations using Google Places'
                  : 'Search results from Google Places:',
              style: TextStyle(
                fontSize: 12,
                color: MyColor.getSecondaryTextColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Search results list
          Expanded(
            child: searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: MyColor.getSecondaryTextColor(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No search results yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: MyColor.getSecondaryTextColor(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use the search button above to find places',
                          style: TextStyle(
                            fontSize: 12,
                            color: MyColor.getSecondaryTextColor(),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final result = searchResults[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: MyColor.getCardBgColor(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: MyColor.getBorderColor(),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: MyColor.getPrimaryColor(),
                          ),
                          title: Text(
                            result.locationName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: MyColor.getTextColor(),
                            ),
                          ),
                          subtitle: result.address != null
                              ? Text(
                                  result.address!,
                                  style: TextStyle(
                                    color: MyColor.getSecondaryTextColor(),
                                  ),
                                )
                              : Text(
                                  '${result.location.latitude.toStringAsFixed(4)}, ${result.location.longitude.toStringAsFixed(4)}',
                                  style: TextStyle(
                                    color: MyColor.getSecondaryTextColor(),
                                  ),
                                ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: MyColor.getSecondaryTextColor(),
                          ),
                          onTap: () {
                            // Return the selected location result
                            Navigator.pop(context, result);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Show Google Places Autocomplete and process results
  Future<void> _showPlacesAutocomplete() async {
    setState(() {
      isSearching = true;
    });

    try {
      // Uncomment after adding dependencies: flutter_google_places: ^0.3.0 and google_maps_webservice: ^0.0.20-nullsafety.5
      // Prediction? p = await PlacesAutocomplete.show(
      //   context: context,
      //   apiKey: EventLocationPickedPlaces.kGoogleApiKey,
      //   mode: Mode.overlay,
      //   language: "ro",
      //   components: [Component(Component.country, "ro")],
      // );
      // if (p != null) {
      //   await _processPlacePrediction(p);
      // }

      // Temporary implementation - demonstrates the workflow
      await _showTemporaryPlacesDemo();
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
    } finally {
      if (mounted) {
        setState(() {
          isSearching = false;
        });
      }
    }
  }

  /// Temporary demo implementation showing how results would be processed
  Future<void> _showTemporaryPlacesDemo() async {
    // Show a demo dialog that simulates Places Autocomplete
    final String? searchTerm = await showDialog<String>(
      context: context,
      builder: (context) {
        String currentInput = '';
        return AlertDialog(
          title: const Text('Demo: Places Search'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => currentInput = value,
                decoration: const InputDecoration(
                  hintText: 'Enter location to search...',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Text(
                'This is a demo. In the real implementation, PlacesAutocomplete.show() will return actual Google Places results.',
                style: TextStyle(
                  fontSize: 12,
                  color: MyColor.getSecondaryTextColor(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, currentInput),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );

    if (searchTerm != null && searchTerm.isNotEmpty) {
      await _processDemoResults(searchTerm);
    }
  }

  /// Process demo results (replace with real Places API results processing)
  Future<void> _processDemoResults(String searchTerm) async {
    // Simulate processing Places API results
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Demo results based on search term
    List<LocationResult> demoResults = [
      LocationResult(
        location: const LatLng(44.4268, 26.1025),
        locationName: 'Demo: $searchTerm (Bucharest)',
        address: 'Bucharest, Romania - Demo Result',
        placeId: 'demo_place_id_1',
      ),
      LocationResult(
        location: const LatLng(46.7712, 23.6236),
        locationName: 'Demo: $searchTerm (Cluj-Napoca)',
        address: 'Cluj-Napoca, Romania - Demo Result',
        placeId: 'demo_place_id_2',
      ),
      LocationResult(
        location: const LatLng(45.7489, 21.2087),
        locationName: 'Demo: $searchTerm (Timișoara)',
        address: 'Timișoara, Romania - Demo Result',
        placeId: 'demo_place_id_3',
      ),
    ];

    setState(() {
      searchResults = demoResults;
      lastSearchQuery = searchTerm;
    });
  }

  /// Process Places prediction from flutter_google_places
  // Future<void> _processPlacePrediction(Prediction prediction) async {
  //   try {
  //     GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: EventLocationPickedPlaces.kGoogleApiKey);
  //     PlacesDetailsResponse details = await places.getDetailsByPlaceId(prediction.placeId!);
  //
  //     if (details.isOkay && details.result.geometry != null) {
  //       final location = LatLng(
  //         details.result.geometry!.location.lat,
  //         details.result.geometry!.location.lng,
  //       );
  //
  //       final result = LocationResult(
  //         location: location,
  //         locationName: details.result.name ?? prediction.description ?? 'Unknown Place',
  //         address: details.result.formattedAddress ?? prediction.description,
  //         placeId: prediction.placeId,
  //       );
  //
  //       setState(() {
  //         searchResults = [result];
  //       });
  //     }
  //   } catch (e) {
  //     print('Error processing place prediction: $e');
  //   }
  // }
}
