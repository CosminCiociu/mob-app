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
class HomeControllerRefactored extends GetxController {
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
    // Load initial events based on user location
    refreshEvents();
  }

  // =========================
  // SERVICE DELEGATES - STATE MANAGEMENT
  // =========================

  /// Current card index
  int get currentIndex => _homeService.currentIndex;

  /// Loading states
  bool get isLoadingEvents => _homeService.isLoadingEvents;
  bool get isLoadingUsers => _homeService.isLoadingUsers;
  bool get hasFinishedAllEvents => _homeService.hasFinishedAllEvents;

  /// Search parameters
  int get distance => _homeService.distance;
  int get age => _homeService.age;
  RangeValues get rangeValues => _homeService.rangeValues;
  List<Map<String, dynamic>> get interestedIn => _homeService.interestedIn;

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
