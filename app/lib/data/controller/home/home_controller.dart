import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/services/home_service.dart';
import '../../../domain/services/matching_service.dart';
import '../../../view/screens/homescreen/widgets/swipe_image.dart';
import '../../managers/location_manager.dart';
import '../../managers/event_manager.dart';
import '../../managers/search_filters_manager.dart';

/// Clean, simplified HomeController that orchestrates managers
///
/// This controller focuses on coordination between managers and UI updates,
/// while business logic is delegated to specialized manager classes.
class HomeController extends GetxController {
  // =========================
  // MANAGERS
  // =========================

  late final LocationManager _locationManager;
  late final EventManager _eventManager;
  late final SearchFiltersManager _filtersManager;

  // =========================
  // UI CONTROLLERS
  // =========================

  CardController? cardController;
  final ZoomDrawerController drawerController = ZoomDrawerController();
  final TextEditingController addressController = TextEditingController();

  // Swipe progress tracking (-1.0 to 1.0, negative = left, positive = right)
  double _swipeProgress = 0.0;
  double get swipeProgress => _swipeProgress;

  // =========================
  // SERVICES (Legacy support)
  // =========================

  late final HomeService _homeService;
  late final MatchingService _matchingService;

  // =========================
  // LIFECYCLE
  // =========================

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _initializeManagers();
    _loadInitialData();
  }

  @override
  void onClose() {
    _locationManager.dispose();
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
    } catch (e) {
      print('❌ Failed to initialize services: $e');
      rethrow;
    }
  }

  void _initializeManagers() {
    // Initialize location manager with callback
    _locationManager = LocationManager(
      addressController: addressController,
      onLocationUpdated: () => update(), // Trigger UI update
    );

    // Initialize event manager
    _eventManager = EventManager(_matchingService);

    // Initialize filters manager
    _filtersManager = SearchFiltersManager();
    _filtersManager.initializeGenderFilters();
  }

  void _loadInitialData() {
    // Start with location, then load events
    _ensureLocationAndLoadEvents();
  }

  /// Main initialization flow: location first, then events
  Future<void> _ensureLocationAndLoadEvents() async {
    // Initialize location display
    await _locationManager.initializeLocation();

    // Ensure we have user location
    final hasLocation = await _locationManager.ensureUserHasLocation();

    if (hasLocation) {
      // Load events if we have location
      await _eventManager.loadEvents(
        radiusInKm: _filtersManager.distance.toDouble(),
        showFeedback: false, // Silent initial load
      );
    } else {
      // Clear events if no location
      _eventManager.clearEvents();
    }

    update(); // Update UI
  }

  // =========================
  // PUBLIC API - LOCATION
  // =========================

  /// Force location update (user-triggered)
  Future<void> forceLocationUpdate() async {
    final success = await _locationManager.forceLocationUpdate();
    if (success) {
      // Reload events with new location
      await refreshEvents();
    }
  }

  /// Change selected address manually
  void changeSelectedAddress(String address) {
    _locationManager.changeSelectedAddress(address);
  }

  // =========================
  // PUBLIC API - EVENTS
  // =========================

  /// Refresh events (user-triggered)
  Future<void> refreshEvents() async {
    final hasLocation = await _locationManager.hasValidLocation();
    if (!hasLocation) {
      print('⚠️ Cannot refresh events - no valid location');
      return;
    }

    await _eventManager.loadEvents(
      radiusInKm: _filtersManager.distance.toDouble(),
      showFeedback: true, // Show user feedback
    );
    update();
  }

  /// Load events silently (internal use)
  Future<void> loadEvents({bool showFeedback = false}) async {
    await _eventManager.loadEvents(
      radiusInKm: _filtersManager.distance.toDouble(),
      showFeedback: showFeedback,
    );
    update();
  }

  /// Handle swipe completion
  void onSwipeComplete(dynamic orientation, int index) {
    _handleSwipeOrientation(orientation, index);
    _eventManager.handleSwipeComplete(index);
    _swipeProgress = 0.0; // Reset swipe progress after completion
    update();
  }

  /// Handle different swipe orientations
  void _handleSwipeOrientation(dynamic orientation, int index) {
    if (orientation is CardSwipeOrientation) {
      switch (orientation) {
        case CardSwipeOrientation.right:
          _eventManager.handleLikeEvent();
          break;
        case CardSwipeOrientation.left:
          _eventManager.handleDeclineEvent();
          break;
        default:
          break;
      }
    } else {
      // Fallback to string comparison
      final orientationString = orientation.toString();
      if (orientationString.contains('right')) {
        _eventManager.handleLikeEvent();
      } else if (orientationString.contains('left')) {
        _eventManager.handleDeclineEvent();
      }
    }
  }

  // =========================
  // PUBLIC API - FILTERS
  // =========================

  /// Update search distance
  void updateSearchDistance(int newDistance) {
    _filtersManager.updateDistance(newDistance);
    // Auto-refresh events with new distance
    refreshEvents();
  }

  /// Update age range filter
  void updateAgeRange(double start, double end) {
    _filtersManager.updateAgeRange(start, end);
    // Note: Age filtering might need to be implemented in the service layer
  }

  /// Toggle gender filter
  void changeGenderFilterStatus(int index) {
    _filtersManager.changeGenderFilterStatus(index);
  }

  /// Reset all filters
  void resetFilters() {
    _filtersManager.resetFilters();
    refreshEvents(); // Refresh with default filters
  }

  // =========================
  // PUBLIC API - UI HELPERS
  // =========================

  /// Initialize card controller
  void initializeCardController() {
    cardController ??= CardController();
  }

  /// Reset card controller
  void resetCardController() {
    _eventManager.reset();
    _homeService.resetCurrentIndexWithFeedback();
    _swipeProgress = 0.0;
    update();
  }

  /// Update swipe progress for visual feedback
  void updateSwipeProgress(double progress) {
    _swipeProgress = progress.clamp(-1.0, 1.0);
    update();
  }

  /// Reset to beginning
  void resetCurrentIndex() {
    _eventManager.reset();
    update();
  }

  /// User refresh (pull-to-refresh)
  Future<void> onUserRefresh() async {
    await refreshEvents();
  }

  // =========================
  // GETTERS - EVENTS
  // =========================

  List<DocumentSnapshot> get nearbyEvents =>
      _eventManager.nearbyEvents.whereType<DocumentSnapshot>().toList();
  bool get hasRealEvents => _eventManager.hasEvents;
  bool get isLoadingEvents => _eventManager.isLoading;
  bool get hasFinishedAllEvents => _eventManager.hasFinishedAllEvents;
  double get progressValue => _eventManager.progressValue;

  DocumentSnapshot? getCurrentEvent() => _eventManager.currentEvent;
  Map<String, dynamic>? getCurrentEventData() => _eventManager.currentEventData;
  String getCurrentEventLocation() => _eventManager.getCurrentEventLocation();
  String getCurrentEventCategory() => _eventManager.getCurrentEventCategory();

  // =========================
  // GETTERS - FILTERS
  // =========================

  int get distance => _filtersManager.distance;
  int get age => _filtersManager.age;
  RangeValues get rangeValues => _filtersManager.rangeValues;
  List<Map<String, dynamic>> get interestedIn => _filtersManager.interestedIn;

  // Setters for backward compatibility
  set distance(int value) => updateSearchDistance(value);
  set rangeValues(RangeValues values) =>
      updateAgeRange(values.start, values.end);

  // =========================
  // GETTERS - LEGACY SERVICE SUPPORT
  // =========================

  int get currentIndex => _eventManager.currentIndex;
  set currentIndex(int index) {
    if (index == 0) resetCurrentIndex();
  }

  bool get isLoadingUsers => _homeService.isLoadingUsers;

  // Legacy methods for backward compatibility
  void handleSwipeComplete(int index) =>
      _eventManager.handleSwipeComplete(index);
  void changeStatus(int index) => changeGenderFilterStatus(index);
  Future<void> updateLocationAndRefresh() async => await refreshEvents();
}
