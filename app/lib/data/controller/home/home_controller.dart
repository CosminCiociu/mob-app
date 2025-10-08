import 'package:flutter/material.dart';
import 'package:ovo_meet/view/screens/homescreen/widgets/swipe_image.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ovo_meet/core/services/location_service.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/view/components/snack_bar/show_custom_snackbar.dart';

class HomeController extends GetxController {
  // =========================
  // STATE VARIABLES
  // =========================

  /// UI Controllers
  CardController? cardController;
  final ZoomDrawerController drawerController = ZoomDrawerController();
  final TextEditingController addressController = TextEditingController();

  /// Loading states
  bool isLoadingEvents = false;
  bool isLoadingUsers = false;
  bool hasFinishedAllEvents = false;
  final bool resetSwiper = false;

  /// Search & Filter parameters
  int distance = Dimensions.defaultSearchRadius.toInt();
  int age = Dimensions.defaultAgeFilter.toInt();
  String selectedAddress = "";
  RangeValues rangeValues =
      const RangeValues(Dimensions.minAgeRange, Dimensions.maxAgeRange);
  int currentIndex = 0;

  /// Data storage
  List<DocumentSnapshot> nearbyEvents = [];
  List<String> girlsImages = [
    "assets/images/girl1.jpg",
    "assets/images/girl2.jpg",
    "assets/images/girl3.jpg",
    "assets/images/girl4.jpg",
  ];

  /// Static data for UI
  List<String> names = [
    "Alexa, 22",
    "Bella, 32",
    "Catherine, 21",
    "Diana, 18",
    "Emily, 14",
    "Fiona, 18"
  ];

  List<Map<String, String>> addresses = [
    {
      'street': '123 Main Street',
    },
    {
      'street': '456 Elm Road',
    },
    {
      'street': '789 Maple Avenue',
    },
    {
      'street': '101 Oak Drive',
    },
    {
      'street': '202 Pine Street',
    },
    {
      'street': '303 Cedar Lane',
    },
    {
      'street': '404 Birch Boulevard',
    },
    {
      'street': '505 Walnut Court',
    },
    {
      'street': '606 Spruce Place',
    },
    {
      'street': '707 Willow Terrace',
    }
  ];

  List<Map<String, dynamic>> interestedIn = [
    {'genders': 'Men', 'status': false},
    {'genders': 'Women', 'status': false},
    {'genders': 'Other', 'status': false},
  ];

  // =========================
  // LIFECYCLE METHODS
  // =========================

  @override
  void onInit() {
    super.onInit();
    resetCurrentIndex();
  }

  // =========================
  // UI STATE MANAGEMENT
  // =========================

  /// Reset current index to beginning
  void resetCurrentIndex() {
    currentIndex = 0;
    // User-friendly feedback for reset - defer to avoid build context issues
    CustomSnackBar.successDeferred(successList: [MyStrings.indexReset]);
    update();
  }

  /// Change selected address with validation and user feedback
  void changeSelectedAddress(String address) {
    if (address.trim().isEmpty) {
      // Defer snackbar to avoid build context issues
      CustomSnackBar.errorDeferred(errorList: ['Address cannot be empty']);
      return;
    }

    addressController.clear();
    addressController.text = address;
    selectedAddress = address;

    // Show success feedback after build is complete
    CustomSnackBar.successDeferred(
        successList: ['Address updated successfully']);

    update();
  }

  /// Change status of interested gender filter with validation
  void changeStatus(int index) {
    if (index < 0 || index >= interestedIn.length) {
      CustomSnackBar.errorDeferred(
          errorList: ['Invalid gender filter selection']);
      return;
    }

    interestedIn[index]['status'] = !interestedIn[index]['status'];

    // Show feedback about filter change
    String genderName = interestedIn[index]['genders'] as String;
    bool isEnabled = interestedIn[index]['status'] as bool;

    CustomSnackBar.successDeferred(successList: [
      'Filter ${isEnabled ? "enabled" : "disabled"} for $genderName'
    ]);

    update();
  }

  /// Update search distance with validation
  void updateSearchDistance(int newDistance) {
    if (newDistance < Dimensions.minSearchRadius.toInt()) {
      distance = Dimensions.minSearchRadius.toInt();
      CustomSnackBar.errorDeferred(errorList: [
        'Distance set to minimum: ${Dimensions.minSearchRadius.toInt()}km'
      ]);
    } else if (newDistance > Dimensions.maxSearchRadius.toInt()) {
      distance = Dimensions.maxSearchRadius.toInt();
      CustomSnackBar.errorDeferred(errorList: [
        'Distance set to maximum: ${Dimensions.maxSearchRadius.toInt()}km'
      ]);
    } else {
      distance = newDistance;
      CustomSnackBar.successDeferred(
          successList: ['Search radius updated to ${distance}km']);
    }
    update();
  }

  /// Update age range with validation
  void updateAgeRange(RangeValues newRange) {
    if (newRange.start < Dimensions.minAgeRange ||
        newRange.end > Dimensions.maxAgeRange) {
      rangeValues =
          const RangeValues(Dimensions.minAgeRange, Dimensions.maxAgeRange);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomSnackBar.error(errorList: [
          'Age range set to valid limits: ${Dimensions.minAgeRange.toInt()}-${Dimensions.maxAgeRange.toInt()}'
        ]);
      });
    } else if (newRange.start >= newRange.end) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomSnackBar.error(errorList: [
          'Invalid age range: minimum must be less than maximum'
        ]);
      });
    } else {
      rangeValues = newRange;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomSnackBar.success(successList: [
          'Age range updated: ${rangeValues.start.toInt()}-${rangeValues.end.toInt()}'
        ]);
      });
    }
    update();
  }

  // =========================
  // SWIPE & CARD METHODS
  // =========================

  /// Reset card controller (commented out implementation)
  void resetCardController() {
    // cardController = CardController();
    // update();
  }

  /// Handle swipe completion
  void onSwipeComplete(CardSwipeOrientation orientation, int index) {
    // Use events if available, otherwise fall back to default images
    if (nearbyEvents.isNotEmpty) {
      currentIndex = index + 1; // Don't use modulo, let it go beyond the length
      // Check if we've finished all events
      if (currentIndex >= nearbyEvents.length) {
        hasFinishedAllEvents = true;
      }
    } else {
      currentIndex = (index + 1) % girlsImages.length;
    }

    update(); // Update the UI
  }

  // =========================
  // LOCATION METHODS
  // =========================

  /// Update user location using LocationService
  Future<void> updateUserLocation() async {
    try {
      // Use the location service to get location data
      final locationData = await LocationService.getLocationDataForFirebase();

      // Update the address controller with the formatted address
      final addressMap = locationData['address'] as Map<String, String>;
      addressController.text = LocationService.getDisplayAddress(addressMap);

      // Update Firebase with the location data
      await LocationService.updateUserLocationInFirebase();

      // Update local state
      selectedAddress = addressController.text;
      update();

      // Show success feedback to user
      CustomSnackBar.success(
          successList: [MyStrings.locationUpdatedSuccessfully]);
    } catch (e) {
      // Show error feedback to user with detailed message
      String errorMessage = e.toString().contains('Permission')
          ? 'Location permission denied. Please enable location access.'
          : e.toString().contains('Service')
              ? 'Location service disabled. Please enable GPS.'
              : '${MyStrings.failedToUpdateLocation}: ${e.toString()}';

      CustomSnackBar.error(errorList: [errorMessage]);
    }
  }

  // =========================
  // EVENT MANAGEMENT METHODS
  // =========================

  /// Manual distance calculation for nearby events (fallback method)
  Future<List<DocumentSnapshot>> fetchNearbyEventsManual() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception(MyStrings.userNotLoggedIn);

      // Get user location
      final userLocation = await LocationService.getUserLocationFromFirebase();
      if (userLocation == null) throw Exception(MyStrings.userLocationNotFound);

      final userGeoPoint = userLocation['geopoint'] as GeoPoint;
      final radiusInKm = distance.toDouble();

      // Validate search radius
      if (!_isValidSearchRadius(radiusInKm)) {
        throw Exception(
            'Invalid search radius: ${radiusInKm}km. Must be between ${Dimensions.minSearchRadius}km and ${Dimensions.maxSearchRadius}km.');
      }

      // Get all events
      final allEvents =
          await FirebaseFirestore.instance.collection('users_events').get();

      isLoadingEvents = true;
      update();

      final foundEvents = <DocumentSnapshot>[];

      for (var doc in allEvents.docs) {
        final eventData = doc.data();

        // Skip own events
        if (eventData['createdBy'] == user.uid) {
          continue;
        }

        // Only active events
        if (eventData['status'] != 'active') {
          continue;
        }

        if (eventData['location'] != null) {
          final eventLocation = eventData['location'] as Map<String, dynamic>;
          final eventGeoPoint = eventLocation['geopoint'] as GeoPoint;

          final distanceInMeters = Geolocator.distanceBetween(
            userGeoPoint.latitude,
            userGeoPoint.longitude,
            eventGeoPoint.latitude,
            eventGeoPoint.longitude,
          );
          final distanceInKm = distanceInMeters / 1000;

          if (distanceInKm <= radiusInKm) {
            foundEvents.add(doc);
          }
        }
      }

      // Store in controller variable
      nearbyEvents = foundEvents;
      currentIndex = 0; // Reset to first event
      hasFinishedAllEvents = false; // Reset finish state
      isLoadingEvents = false;

      // Show appropriate feedback based on results
      if (nearbyEvents.isEmpty) {
        CustomSnackBar.error(errorList: [MyStrings.noEventsFoundInArea]);
      } else {
        CustomSnackBar.success(successList: [
          '${nearbyEvents.length} ${MyStrings.eventsFoundNearby} within ${radiusInKm}km'
        ]);
      }

      update(); // Notify UI to rebuild
      return nearbyEvents;
    } catch (e) {
      String errorMessage = _getDetailedErrorMessage(e);
      CustomSnackBar.error(errorList: [errorMessage]);
      isLoadingEvents = false;
      update();
      return [];
    }
  }

  // =========================
  // EVENT DATA HELPERS
  // =========================

  /// Get current event data for display
  Map<String, dynamic>? getCurrentEventData() {
    if (nearbyEvents.isEmpty || currentIndex >= nearbyEvents.length) {
      return null;
    }
    return nearbyEvents[currentIndex].data() as Map<String, dynamic>?;
  }

  /// Get formatted event location
  String getCurrentEventLocation() {
    final eventData = getCurrentEventData();
    if (eventData == null || eventData['location'] == null) {
      return MyStrings.locationNotAvailable;
    }

    final location = eventData['location'] as Map<String, dynamic>;
    final address = location['address'] as Map<String, dynamic>?;

    if (address != null && address['administrativeArea'] != null) {
      return address['administrativeArea'] as String;
    }

    return MyStrings.locationNotAvailable;
  }

  /// Get formatted category/subcategory
  String getCurrentEventCategory() {
    final eventData = getCurrentEventData();
    if (eventData == null) return MyStrings.categoryNotAvailable;

    final category = eventData['categoryId'] as String? ?? '';
    final subcategory = eventData['subcategoryId'] as String? ?? '';

    if (category.isNotEmpty && subcategory.isNotEmpty) {
      return '$category / $subcategory';
    } else if (category.isNotEmpty) {
      return category;
    } else if (subcategory.isNotEmpty) {
      return subcategory;
    }

    return MyStrings.categoryNotAvailable;
  }

  /// Get all events from the collection with detailed logging
  Future<List<DocumentSnapshot>> getAllEvents() async {
    try {
      // Show loading feedback to user
      CustomSnackBar.success(successList: [MyStrings.debugFetchingEvents]);
      final user = FirebaseAuth.instance.currentUser;

      final allEventsQuery =
          await FirebaseFirestore.instance.collection('users_events').get();

      // Debug information for development (can be removed in production)
      if (allEventsQuery.docs.isNotEmpty) {
        CustomSnackBar.success(
            successList: ['Total events found: ${allEventsQuery.docs.length}']);
      }

      // Get user location for distance calculations
      final userLocation = await LocationService.getUserLocationFromFirebase();
      GeoPoint? userGeoPoint;
      String? userGeohash;

      if (userLocation != null) {
        userGeoPoint = userLocation['geopoint'] as GeoPoint;
        userGeohash = userLocation['geohash'] as String;
        // Debug info (keep for development)
        print(
            "🔍 User location: ${userGeoPoint.latitude}, ${userGeoPoint.longitude}");
        print("🔍 User geohash: $userGeohash");
      }

      for (int i = 0; i < allEventsQuery.docs.length; i++) {
        final doc = allEventsQuery.docs[i];
        final data = doc.data();

        print("📄 Event ${i + 1}:");
        print("  - ID: ${doc.id}");
        print("  - Name: ${data['eventName'] ?? 'N/A'}");
        print("  - Created By: ${data['createdBy'] ?? 'N/A'}");
        print("  - Status: ${data['status'] ?? 'N/A'}");
        print("  - Category: ${data['categoryId'] ?? 'N/A'}");
        print("  - DateTime: ${data['dateTime'] ?? 'N/A'}");
        print("  - Current User: ${user?.uid}");
        print("  - Is Own Event: ${data['createdBy'] == user?.uid}");

        if (data['location'] != null) {
          final location = data['location'] as Map<String, dynamic>;
          final eventGeoPoint = location['geopoint'];
          final eventGeohash = location['geohash'];

          print("  - Location Data:");
          print(
              "    - GeoPoint: $eventGeoPoint (${eventGeoPoint.runtimeType})");
          print("    - Geohash: $eventGeohash");
          print("    - Lat: ${location['lat']}");
          print("    - Lng: ${location['lng']}");

          // Calculate distance if we have user location
          if (userGeoPoint != null && eventGeoPoint is GeoPoint) {
            final distanceInMeters = Geolocator.distanceBetween(
              userGeoPoint.latitude,
              userGeoPoint.longitude,
              eventGeoPoint.latitude,
              eventGeoPoint.longitude,
            );
            final distanceInKm = distanceInMeters / 1000;

            print(
                "    - Distance from user: ${distanceInKm.toStringAsFixed(2)}km");
            print("    - Within 10km radius: ${distanceInKm <= 10}");
            print("    - Within 50km radius: ${distanceInKm <= 50}");
          }
        } else {
          print("  - ❌ NO LOCATION DATA");
        }
        print(""); // Empty line for readability
      }

      return allEventsQuery.docs;
    } catch (e) {
      print("❌ Failed to get all events: $e");
      return [];
    }
  }

  Future<List<DocumentSnapshot>> fetchNearbyEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Get current user's location using LocationService
      final userLocation = await LocationService.getUserLocationFromFirebase();
      if (userLocation == null) {
        throw Exception('User location not found');
      }

      final userGeoPoint = userLocation['geopoint'] as GeoPoint;
      final userGeohash = userLocation['geohash'] as String;
      final radiusInKm = distance.toDouble();

      // Validate search radius
      if (!_isValidSearchRadius(radiusInKm)) {
        throw Exception(
            'Invalid search radius: ${radiusInKm}km. Must be between ${Dimensions.minSearchRadius}km and ${Dimensions.maxSearchRadius}km.');
      }

      // Show search feedback to user
      CustomSnackBar.success(successList: [
        '${MyStrings.searchingForEvents} within ${radiusInKm}km...'
      ]);

      // Debug info (keep for development)
      print("🌍 User search parameters:");
      print("  - Radius: ${radiusInKm}km");
      print("  - Center: ${userGeoPoint.latitude}, ${userGeoPoint.longitude}");
      print("  - Geohash: $userGeohash");

      // Create GeoFirePoint from user's location using geohash
      final centerPoint = GeoFirePoint(userGeoPoint);

      // Query nearby events using geoflutterfire_plus with geohash
      final geoQuery = GeoCollectionReference(
        FirebaseFirestore.instance.collection('users_events'),
      ).subscribeWithin(
        center: centerPoint,
        radiusInKm: radiusInKm,
        field: 'location.geopoint',
        geopointFrom: (data) => data['location']['geopoint'] as GeoPoint,
      );

      final nearbyEvents = <DocumentSnapshot>[];

      try {
        print("🔍 Starting geo query...");
        await for (final docs in geoQuery) {
          print("📍 Geo query returned ${docs.length} nearby events");
          for (final doc in docs) {
            final eventData = doc.data();
            if (eventData != null && eventData['location'] != null) {
              nearbyEvents.add(doc);
            }
          }
          break; // Take only the first batch for now
        }

        // If geo query returned 0 results but we know there should be events, use fallback
        if (nearbyEvents.isEmpty) {
          print(
              "🔄 Geo query returned 0 results, falling back to manual calculation...");
          CustomSnackBar.success(successList: [MyStrings.geoQueryFallback]);
          throw Exception("Geo query empty, using fallback");
        } else {
          print("✅ Geo query found ${nearbyEvents.length} events successfully");
          CustomSnackBar.success(successList: [
            '${nearbyEvents.length} ${MyStrings.eventsFoundNearby}'
          ]);
        }
      } catch (geoError) {
        print("🚨 ENTERED CATCH BLOCK");
        print("❌ Geo query failed or returned empty: $geoError");
        print("🔄 Using manual distance calculation fallback...");

        // Show fallback notification to user
        CustomSnackBar.success(
            successList: [MyStrings.debugCalculatingDistance]);

        // Fallback: Manual distance calculation
        print("🔍 Fetching all events for manual calculation...");
        final allEvents =
            await FirebaseFirestore.instance.collection('users_events').get();

        print(
            "🔍 Manual calculation checking ${allEvents.docs.length} events...");

        for (var doc in allEvents.docs) {
          final eventData = doc.data();

          // Skip events created by current user
          if (eventData['createdBy'] == user.uid) {
            print("⏭️ Skipping own event: ${eventData['eventName']}");
            continue;
          }

          // Only include active events
          if (eventData['status'] != 'active') {
            print("⏭️ Skipping inactive event: ${eventData['eventName']}");
            continue;
          }

          if (eventData['location'] != null) {
            final eventLocation = eventData['location'] as Map<String, dynamic>;
            final eventGeoPoint = eventLocation['geopoint'] as GeoPoint;

            // Calculate distance manually
            final distanceInMeters = Geolocator.distanceBetween(
              userGeoPoint.latitude,
              userGeoPoint.longitude,
              eventGeoPoint.latitude,
              eventGeoPoint.longitude,
            );

            final distanceInKm = distanceInMeters / 1000;

            print(
                "🔍 Checking event: ${eventData['eventName']}, Distance: ${distanceInKm.toStringAsFixed(2)}km, Within radius: ${distanceInKm <= radiusInKm}");

            if (distanceInKm <= radiusInKm) {
              nearbyEvents.add(doc);
              print(
                  "✅ Manual calculation found event: ${eventData['eventName']} at ${distanceInKm.toStringAsFixed(2)}km");
            }
          }
        }
      }

      // Show results to user
      if (nearbyEvents.isEmpty) {
        CustomSnackBar.error(errorList: [MyStrings.noEventsFoundInArea]);
      } else {
        CustomSnackBar.success(successList: [
          '${nearbyEvents.length} ${MyStrings.eventsFoundNearby} within ${radiusInKm}km'
        ]);
      }

      print(
          "✅ Found ${nearbyEvents.length} nearby events within ${radiusInKm}km");

      // Debug: Log event details (keep for development)
      for (var eventDoc in nearbyEvents.take(3)) {
        final eventData = eventDoc.data() as Map<String, dynamic>?;
        if (eventData != null) {
          final location = eventData['location'] as Map<String, dynamic>;
          final eventGeoPoint = location['geopoint'] as GeoPoint;
          final distanceInMeters = Geolocator.distanceBetween(
            userGeoPoint.latitude,
            userGeoPoint.longitude,
            eventGeoPoint.latitude,
            eventGeoPoint.longitude,
          );
          final distanceInKm = distanceInMeters / 1000;

          print(
              "📍 Event: ${eventData['eventName']}, Distance: ${distanceInKm.toStringAsFixed(2)}km, Geohash: ${location['geohash']}");
        }
      }

      return nearbyEvents;
    } catch (e) {
      String errorMessage = _getDetailedErrorMessage(e);
      CustomSnackBar.error(errorList: [errorMessage]);
      return [];
    }
  }

  // =========================
  // USER QUERY METHODS
  // =========================

  /// Query nearby users within a specified radius
  Future<List<DocumentSnapshot>> getNearbyUsers(double radiusInKm) async {
    try {
      isLoadingUsers = true;
      update();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception(MyStrings.userNotLoggedIn);

      // Show loading feedback
      CustomSnackBar.success(successList: [
        '${MyStrings.searchingForUsers} within ${radiusInKm}km...'
      ]);

      // Get current user's location
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists || userDoc.data()?['location'] == null) {
        throw Exception('User location not found');
      }

      final userLocation = userDoc.data()!['location'];
      final userGeoPoint = userLocation['geopoint'] as GeoPoint;

      // Create GeoFirePoint from user's location
      final centerPoint = GeoFirePoint(userGeoPoint);

      // Query nearby users using geohash
      final geoQuery = GeoCollectionReference(
        FirebaseFirestore.instance.collection('users'),
      ).subscribeWithin(
        center: centerPoint,
        radiusInKm: radiusInKm,
        field: 'location.geopoint',
        geopointFrom: (data) => data['location']['geopoint'] as GeoPoint,
      );

      final nearbyUsers = <DocumentSnapshot>[];
      await for (final docs in geoQuery) {
        for (final doc in docs) {
          // Exclude current user from results
          if (doc.id != user.uid) {
            nearbyUsers.add(doc);
          }
        }
        break; // Take only the first batch for now
      }

      // Show results to user
      if (nearbyUsers.isEmpty) {
        CustomSnackBar.error(errorList: [MyStrings.noUsersFoundInArea]);
      } else {
        CustomSnackBar.success(successList: [
          '${nearbyUsers.length} ${MyStrings.usersFoundNearby} within ${radiusInKm}km'
        ]);
      }

      print(
          "✅ Found ${nearbyUsers.length} nearby users within ${radiusInKm}km");
      return nearbyUsers;
    } catch (e) {
      String errorMessage = _getDetailedErrorMessage(e);
      CustomSnackBar.error(errorList: [errorMessage]);
      return [];
    } finally {
      isLoadingUsers = false;
      update();
    }
  }

  // =========================
  // CONVENIENCE & STATE METHODS
  // =========================

  /// Check if any loading operation is in progress
  bool get isLoading => isLoadingEvents || isLoadingUsers;

  /// Get current loading status message
  String get loadingMessage {
    if (isLoadingEvents && isLoadingUsers) {
      return 'Loading events and users...';
    } else if (isLoadingEvents) {
      return MyStrings.searchingForEvents;
    } else if (isLoadingUsers) {
      return MyStrings.searchingForUsers;
    } else {
      return 'Ready';
    }
  }

  /// Check if there are active filters applied
  bool get hasActiveFilters {
    return interestedIn.any((filter) => filter['status'] == true) ||
        distance != Dimensions.defaultSearchRadius.toInt() ||
        rangeValues.start != Dimensions.minAgeRange ||
        rangeValues.end != Dimensions.maxAgeRange;
  }

  /// Get count of active filters
  int get activeFiltersCount {
    int count = 0;

    // Count gender filters
    count += interestedIn.where((filter) => filter['status'] == true).length;

    // Count distance filter if not default
    if (distance != Dimensions.defaultSearchRadius.toInt()) count++;

    // Count age range filter if not default
    if (rangeValues.start != Dimensions.minAgeRange ||
        rangeValues.end != Dimensions.maxAgeRange) count++;

    return count;
  }

  /// Reset all filters to default values
  void resetFilters() {
    distance = Dimensions.defaultSearchRadius.toInt();
    age = Dimensions.defaultAgeFilter.toInt();
    rangeValues =
        const RangeValues(Dimensions.minAgeRange, Dimensions.maxAgeRange);

    // Reset all gender filters
    for (var filter in interestedIn) {
      filter['status'] = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomSnackBar.success(
          successList: ['All filters reset to default values']);
    });
    update();
  }

  /// Get summary of current search parameters
  String get searchSummary {
    List<String> summary = [];

    summary.add('Radius: ${distance}km');
    summary.add('Age: ${rangeValues.start.toInt()}-${rangeValues.end.toInt()}');

    var activeGenders = interestedIn
        .where((filter) => filter['status'] == true)
        .map((filter) => filter['genders'] as String)
        .toList();

    if (activeGenders.isNotEmpty) {
      summary.add('Interested in: ${activeGenders.join(', ')}');
    }

    return summary.join(' • ');
  }

  /// Get users within a specific distance range
  Future<List<DocumentSnapshot>> getUsersInDistanceRange() async {
    return await getNearbyUsers(distance.toDouble());
  }

  // =========================
  // UTILITY & DEMO METHODS
  // =========================

  /// Get detailed error messages for better user experience
  String _getDetailedErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('internet') ||
        errorString.contains('connection')) {
      return MyStrings.connectionError;
    } else if (errorString.contains('permission')) {
      return 'Location permission required. Please enable location access in settings.';
    } else if (errorString.contains('location') &&
        errorString.contains('service')) {
      return 'Location service is disabled. Please enable GPS.';
    } else if (errorString.contains('firebase') ||
        errorString.contains('firestore')) {
      return 'Database connection error. Please try again.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else {
      return '${MyStrings.unexpectedError}: ${error.toString()}';
    }
  }

  /// Validate search radius within acceptable limits
  bool _isValidSearchRadius(double radius) {
    return radius >= Dimensions.minSearchRadius &&
        radius <= Dimensions.maxSearchRadius;
  }

  /// Validate and adjust search parameters
  void validateSearchParameters() {
    // Ensure distance is within valid range
    if (distance < Dimensions.minSearchRadius.toInt()) {
      distance = Dimensions.minSearchRadius.toInt();
      CustomSnackBar.error(errorList: [
        'Search radius adjusted to minimum: ${Dimensions.minSearchRadius.toInt()}km'
      ]);
    } else if (distance > Dimensions.maxSearchRadius.toInt()) {
      distance = Dimensions.maxSearchRadius.toInt();
      CustomSnackBar.error(errorList: [
        'Search radius adjusted to maximum: ${Dimensions.maxSearchRadius.toInt()}km'
      ]);
    }

    // Ensure age range is valid
    if (rangeValues.start < Dimensions.minAgeRange ||
        rangeValues.end > Dimensions.maxAgeRange) {
      rangeValues =
          const RangeValues(Dimensions.minAgeRange, Dimensions.maxAgeRange);
      CustomSnackBar.error(errorList: [
        'Age range adjusted to valid limits: ${Dimensions.minAgeRange.toInt()}-${Dimensions.maxAgeRange.toInt()}'
      ]);
    }

    update();
  }

  /// Example method to demonstrate geohash usage
  void demonstrateGeohashFeatures() async {
    try {
      // Update current user's location with geohash
      await updateUserLocation();

      // Get nearby users within the selected distance
      final nearbyUsers = await getUsersInDistanceRange();

      // Show meaningful feedback about the results
      if (nearbyUsers.isNotEmpty) {
        CustomSnackBar.success(successList: [
          'Geohash demo: Found ${nearbyUsers.length} users nearby'
        ]);

        // Debug info for development
        print("✅ Found ${nearbyUsers.length} users nearby");
        for (var userDoc in nearbyUsers) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final location = userData['location'];
          if (location != null) {
            print("User: ${userDoc.id}, Geohash: ${location['geohash']}");
          }
        }
      } else {
        CustomSnackBar.error(
            errorList: ['Geohash demo: No users found nearby']);
      }
    } catch (e) {
      String errorMessage = _getDetailedErrorMessage(e);
      CustomSnackBar.error(errorList: ['Geohash demo failed: $errorMessage']);
    }
  }
}
