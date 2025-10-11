import 'package:flutter/material.dart';
import 'package:ovo_meet/view/screens/homescreen/widgets/swipe_image.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/services/home_service.dart';
import '../../../domain/services/matching_service.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';

/// Refactored HomeController using clean architecture with services
///
/// This controller now focuses on UI coordination and delegates business logic
/// to dedicated service classes, promoting better separation of concerns.
class HomeController extends GetxController {
  // =========================
  // DEPENDENCIES
  // =========================

  late final HomeService _homeService;
  late final MatchingService _matchingService;

  // =========================
  // UI CONTROLLERS
  // =========================

  CardController? cardController;
  final ZoomDrawerController drawerController = ZoomDrawerController();
  final TextEditingController addressController = TextEditingController();

  // =========================
  // DATA STORAGE
  // =========================

  List<DocumentSnapshot> nearbyEvents = [];
  String selectedAddress = "";

  /// Address data for location picker
  List<Map<String, String>> addresses = [
    {'street': '123 Main Street'},
    {'street': '456 Elm Road'},
    {'street': '789 Maple Avenue'},
    {'street': '101 Oak Drive'},
    {'street': '202 Pine Street'},
    {'street': '303 Cedar Lane'},
    {'street': '404 Birch Boulevard'},
    {'street': '505 Walnut Court'},
    {'street': '606 Spruce Place'},
    {'street': '707 Cherry Way'},
  ];

  /// Static demo data for UI fallback
  List<String> names = [
    "Alexa, 22",
    "Bella, 32",
    "Catherine, 21",
    "Diana, 25",
  ];

  List<String> statuses = [
    "Online",
    "Away",
    "Busy",
    "Offline",
  ];

  // =========================
  // LIFECYCLE METHODS
  // =========================

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _loadInitialData();
  }

  @override
  void onClose() {
    addressController.dispose();
    super.onClose();
  }

  // =========================
  // INITIALIZATION
  // =========================

  void _initializeServices() {
    try {
      _homeService = Get.find<HomeService>();
      _matchingService = Get.find<MatchingService>();

      // Set up callback for service state changes
      // Set up callback for service state changes if implementation supports it
      // This would require accessing the concrete implementation
    } catch (e) {
      CustomSnackBar.errorDeferred(
          errorList: ['Failed to initialize services: ${e.toString()}']);
    }
  }

  void _loadInitialData() {
    // Load initial events based on user location silently (no snackbars on init)
    _refreshEventsQuietly();
  }

  /// Initialize card controller if not already initialized
  void initializeCardController() {
    if (cardController == null) {
      cardController = CardController();
    }
  }

  /// Refresh events silently during initialization (no snackbars)
  Future<void> _refreshEventsQuietly() async {
    try {
      _homeService.setLoadingEvents(true);
      update();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Silently fail during initialization
        return;
      }

      nearbyEvents = await _matchingService.searchNearbyEventsQuietly(
        radiusInKm: distance.toDouble(),
        currentUserId: user.uid,
      );

      _homeService.resetCurrentIndex();
    } catch (e) {
      // Log error but don't show snackbar during initialization
      print('Failed to refresh events during initialization: $e');
    } finally {
      _homeService.setLoadingEvents(false);
      update();
    }
  }

  // =========================
  // SERVICE DELEGATES - STATE MANAGEMENT
  // =========================

  /// Current card index
  int get currentIndex => _homeService.currentIndex;

  /// Set current card index
  set currentIndex(int index) {
    // Reset to beginning when setting to 0
    if (index == 0) {
      resetCurrentIndex();
    }
  }

  /// Loading states
  bool get isLoadingEvents => _homeService.isLoadingEvents;
  bool get isLoadingUsers => _homeService.isLoadingUsers;
  bool get hasFinishedAllEvents => _homeService.hasFinishedAllEvents;

  /// Search parameters
  int get distance => _homeService.distance;
  int get age => _homeService.age;
  RangeValues get rangeValues => _homeService.rangeValues;
  List<Map<String, dynamic>> get interestedIn => _homeService.interestedIn;

  /// Search parameter setters
  set distance(int value) {
    updateSearchDistance(value);
  }

  set rangeValues(RangeValues values) {
    updateAgeRange(values.start, values.end);
  }

  // =========================
  // SERVICE DELEGATES - ACTIONS
  // =========================

  /// Reset card index to beginning
  void resetCurrentIndex() {
    _homeService.resetCurrentIndex();
  }

  /// Handle swipe completion
  void handleSwipeComplete(int index) {
    _homeService.handleSwipeComplete(index, nearbyEvents);
  }

  /// Update search distance
  void updateSearchDistance(int newDistance) {
    _homeService.updateSearchDistance(newDistance);
  }

  /// Update age range filter
  void updateAgeRange(double start, double end) {
    _homeService.updateAgeRange(start, end);
  }

  /// Toggle gender filter
  void changeGenderFilterStatus(int index) {
    _homeService.changeGenderFilterStatus(index);
  }

  /// Change status (alias for changeGenderFilterStatus)
  void changeStatus(int index) {
    changeGenderFilterStatus(index);
  }

  /// Reset all filters to defaults
  void resetFilters() {
    _homeService.resetFilters();
  }

  // =========================
  // EVENT MANAGEMENT METHODS
  // =========================

  /// Refresh events from the service layer
  Future<void> refreshEvents() async {
    try {
      _homeService.setLoadingEvents(true);
      update();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        CustomSnackBar.errorDeferred(errorList: [MyStrings.userNotLoggedIn]);
        return;
      }

      nearbyEvents = await _matchingService.searchNearbyEvents(
        radiusInKm: distance.toDouble(),
        currentUserId: user.uid,
      );

      _homeService.resetCurrentIndex();
    } catch (e) {
      CustomSnackBar.errorDeferred(errorList: [
        'Failed to refresh events: ${_matchingService.getDetailedErrorMessage(e)}'
      ]);
    } finally {
      _homeService.setLoadingEvents(false);
      update();
    }
  }

  /// Search for nearby users
  Future<void> searchNearbyUsers() async {
    try {
      _homeService.setLoadingUsers(true);
      update();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        CustomSnackBar.errorDeferred(errorList: [MyStrings.userNotLoggedIn]);
        return;
      }

      await _matchingService.searchNearbyUsers(
        radiusInKm: distance.toDouble(),
        currentUserId: user.uid,
      );
    } catch (e) {
      CustomSnackBar.errorDeferred(errorList: [
        'Failed to search users: ${_matchingService.getDetailedErrorMessage(e)}'
      ]);
    } finally {
      _homeService.setLoadingUsers(false);
      update();
    }
  }

  /// Update location and refresh events
  Future<void> updateLocationAndRefresh() async {
    await _matchingService.updateLocationAndRefresh();
    await refreshEvents();
  }

  /// Demonstrate geohash functionality
  Future<void> demonstrateGeohashFeatures() async {
    await _matchingService.demonstrateGeohashFeatures();
  }

  // =========================
  // UI HELPER METHODS
  // =========================

  /// Get current event if available
  DocumentSnapshot? getCurrentEvent() {
    if (nearbyEvents.isNotEmpty && currentIndex < nearbyEvents.length) {
      return nearbyEvents[currentIndex];
    }
    return null;
  }

  /// Get current demo image for fallback (placeholder removed)
  String? getCurrentDemoImage() {
    return null; // Demo images removed
  }

  /// Get current demo name
  String getCurrentDemoName() {
    return names[currentIndex % names.length];
  }

  /// Get current demo status
  String getCurrentDemoStatus() {
    return statuses[currentIndex % statuses.length];
  }

  /// Check if we have real events to display
  bool get hasRealEvents => nearbyEvents.isNotEmpty;

  /// Get progress indicator value
  double get progressValue {
    if (nearbyEvents.isEmpty) return 0.0;
    return (currentIndex + 1) / nearbyEvents.length;
  }

  // =========================
  // FILTER DIALOG METHODS
  // =========================

  /// Show filter dialog
  void showFilterDialog() {
    // Implementation would trigger filter dialog
    // This would be handled by the UI layer
    CustomSnackBar.successDeferred(successList: ['Opening filter dialog...']);
  }

  /// Apply filters and refresh
  Future<void> applyFiltersAndRefresh() async {
    CustomSnackBar.successDeferred(successList: [
      'Applying filters: ${distance}km radius, age ${rangeValues.start.toInt()}-${rangeValues.end.toInt()}'
    ]);
    await refreshEvents();
  }

  // =========================
  // MISSING METHODS NEEDED BY UI
  // =========================

  /// Method called by swipe cards
  void onSwipeComplete(orientation, int index) {
    handleSwipeComplete(index);
  }

  /// Reset card controller
  void resetCardController() {
    // Reset card controller if available with user feedback
    _homeService.resetCurrentIndexWithFeedback();
    update();
  }

  /// Get current event data
  Map<String, dynamic>? getCurrentEventData() {
    final event = getCurrentEvent();
    if (event != null) {
      try {
        return event.data() as Map<String, dynamic>?;
      } catch (e) {
        print('Error casting event data: $e');
        return null;
      }
    }
    return null;
  }

  /// Get current event location
  String getCurrentEventLocation() {
    final eventData = getCurrentEventData();
    if (eventData != null) {
      final location = eventData['location'] as Map<String, dynamic>?;
      if (location != null) {
        final address = location['address'] as Map<String, dynamic>?;
        if (address != null) {
          final administrativeArea = address['administrativeArea'] as String?;
          final locality = address['locality'] as String?;
          if (administrativeArea != null && locality != null) {
            return '$locality, $administrativeArea';
          }
          return administrativeArea ?? locality ?? 'Location not available';
        }
        // Fallback to any string representation in location
        return location.toString().length > 50
            ? 'Location available'
            : location.toString();
      }
    }
    return 'Location not available';
  }

  /// Get current event category
  String getCurrentEventCategory() {
    final eventData = getCurrentEventData();
    if (eventData != null) {
      final category = eventData['category'];
      if (category is String) {
        return category;
      } else if (category is Map<String, dynamic>) {
        // If category is a map, try to get name or id
        return category['name'] as String? ??
            category['id'] as String? ??
            'Category not available';
      } else if (category != null) {
        return category.toString();
      }
    }
    return 'Category not available';
  }

  /// Update user location (delegate to matching service)
  Future<void> updateUserLocation() async {
    await updateLocationAndRefresh();
  }

  /// Fetch nearby events manually (delegate to refresh events with feedback)
  /// This should only be called by user-initiated actions, not during initialization
  Future<void> fetchNearbyEventsManual() async {
    await refreshEvents();
  }

  /// Refresh data when user manually requests it (e.g., pull to refresh)
  Future<void> onUserRefresh() async {
    // Only call this for explicit user actions
    await updateLocationAndRefresh();
  }

  /// Change selected address
  void changeSelectedAddress(String address) {
    selectedAddress = address;
    addressController.text = address;
    CustomSnackBar.successDeferred(successList: ['Address selected: $address']);
    update();
  }

  // =========================
  // UTILITY METHODS
  // =========================

  /// Check if search radius is valid
  bool isValidSearchRadius(double radius) {
    return _matchingService.isValidSearchRadius(radius);
  }

  /// Get detailed error message
  String getDetailedErrorMessage(dynamic error) {
    return _matchingService.getDetailedErrorMessage(error);
  }
}
