import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ovo_meet/view/screens/homescreen/widgets/swipe_image.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/services/home_service.dart';
import '../../../domain/services/matching_service.dart';
import '../../../core/services/location_service.dart';
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
    // Set initial address to show current location
    _setInitialAddress();

    // Load events first, then optionally update location in background
    _loadEventsAndUpdateLocationSafely();
  }

  /// Set initial address display
  void _setInitialAddress() {
    if (addressController.text.isEmpty) {
      // Set a default message immediately
      if (!isClosed) {
        try {
          addressController.text = 'Finding your location...';
          update();
        } catch (e) {
          print('⚠️ Controller already disposed, skipping address update');
        }
      }
      // Try to get current user location from Firebase or fallback
      _getUserLocationFromFirebase();
    }
  }

  /// Get user's current location from Firebase using LocationService
  Future<void> _getUserLocationFromFirebase() async {
    try {
      print('📍 Fetching user location using LocationService...');
      final location = await LocationService.getUserLocationFromFirebase();

      if (location != null && location.isValid) {
        final locationText = location.displayAddress;
        print('📍 Setting location display to: $locationText');
        if (!isClosed) {
          try {
            addressController.text = locationText;
            update();
          } catch (e) {
            print('⚠️ Controller already disposed, skipping address update');
          }
        }
        return;
      } else {
        print('📍 No valid location data found in Firebase');
      }
    } catch (e) {
      print('❌ Error getting user location from Firebase: $e');
    }

    // Fallback if no location found
    print('📍 Falling back to "Finding your location..."');
    if (!isClosed) {
      try {
        addressController.text = 'Finding your location...';
        update();
      } catch (e) {
        print('⚠️ Controller already disposed, skipping address update');
      }
    }
  }

  /// Load events first, then safely attempt location update in background
  Future<void> _loadEventsAndUpdateLocationSafely() async {
    // First, immediately try to load events with existing location data
    await _refreshEventsQuietly();

    // Then, safely attempt to update location in the background with delay
    Future.delayed(const Duration(seconds: 2), () {
      _safeLocationUpdate();
    });
  }

  /// Safely attempt to update user location with comprehensive error handling
  Future<void> _safeLocationUpdate() async {
    try {
      print('🔄 Starting safe location update...');

      // Use the location update method with timeout
      final success = await LocationService.updateUserLocationInFirebase()
          .timeout(const Duration(seconds: 15));

      if (success) {
        print('✅ User location updated successfully in background');
        // Update address display after successful location update
        _updateAddressDisplay();
      } else {
        print(
            '⚠️ Location update failed gracefully, keeping existing location');
        if (!isClosed) {
          try {
            if (addressController.text == 'Finding your location...' ||
                addressController.text == 'Updating location...') {
              addressController.text = 'Unable to get location';
              update();
            }
          } catch (e) {
            print('⚠️ Controller already disposed, skipping address update');
          }
        }
      }
    } catch (e) {
      // Comprehensive error handling for different failure types
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('google play') ||
          errorString.contains('securityexception') ||
          errorString.contains('deadsystemexception')) {
        print(
            '🔧 Google Play Services issue detected, skipping location update: $e');
      } else if (errorString.contains('permission') ||
          errorString.contains('denied')) {
        print('🔐 Location permission issue, showing helpful message: $e');
        if (!isClosed) {
          try {
            if (addressController.text == 'Finding your location...' ||
                addressController.text == 'Updating location...') {
              addressController.text = MyStrings.enableLocationToFindEvents;
              update();
            }
          } catch (e) {
            print('⚠️ Controller already disposed, skipping address update');
          }
        }
      } else if (errorString.contains('timeoutexception') ||
          errorString.contains('timeout')) {
        print('⏱️ Location update timed out, will retry later: $e');
        Future.delayed(const Duration(seconds: 30), () {
          print('🔄 Retrying location update...');
          _safeLocationUpdate();
        });
      } else if (errorString.contains('location service') ||
          errorString.contains('disabled')) {
        print('📍 Location services disabled: $e');
        if (!isClosed) {
          try {
            if (addressController.text == 'Finding your location...' ||
                addressController.text == 'Updating location...') {
              addressController.text = MyStrings.locationServicesDisabled;
              update();
            }
          } catch (e) {
            print('⚠️ Controller already disposed, skipping address update');
          }
        }
      } else {
        print('⚠️ Location update failed (non-critical): $e');
        if (!isClosed) {
          try {
            if (addressController.text == 'Finding your location...' ||
                addressController.text == 'Updating location...') {
              addressController.text = 'Unable to get location';
              update();
            }
          } catch (e) {
            print('⚠️ Controller already disposed, skipping address update');
          }
        }
      }
      // Don't throw - this is a background operation that shouldn't crash the app
    }
  }

  /// Update address display after successful location update
  void _updateAddressDisplay() {
    if (addressController.text == 'Finding your location...' ||
        addressController.text.isEmpty) {
      // Get fresh location data from Firebase after update
      _getUserLocationFromFirebase();
    }
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

  /// Set current card index (used by bottom navigation)
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

  /// Search parameter setters (used by filter UI)
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

  /// Update location and refresh events
  Future<void> updateLocationAndRefresh() async {
    await _matchingService.updateLocationAndRefresh();
    await refreshEvents();
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

  /// Check if we have real events to display
  bool get hasRealEvents => nearbyEvents.isNotEmpty;

  /// Get progress indicator value
  double get progressValue {
    if (nearbyEvents.isEmpty) return 0.0;
    return (currentIndex + 1) / nearbyEvents.length;
  }

  // =========================
  // MISSING METHODS NEEDED BY UI
  // =========================

  /// Method called by swipe cards
  void onSwipeComplete(orientation, int index) {
    // Handle specific swipe orientations
    _handleSwipeOrientation(orientation, index);
    handleSwipeComplete(index);
  }

  /// Handle different swipe orientations
  void _handleSwipeOrientation(dynamic orientation, int index) {
    // Check if it's the right orientation type
    if (orientation is CardSwipeOrientation) {
      switch (orientation) {
        case CardSwipeOrientation.right:
          // User swiped right (like)
          _handleLikeEvent(index);
          break;
        case CardSwipeOrientation.left:
          // User swiped left (pass/reject)
          _handlePassEvent(index);
          break;

        default:
          break;
      }
    } else {
      // Fallback to string comparison for backward compatibility
      final orientationString = orientation.toString();
      if (orientationString.contains('right')) {
        _handleLikeEvent(index);
      } else if (orientationString.contains('left')) {
        _handlePassEvent(index);
      }
    }
  }

  /// Handle like event action (swipe right)
  void _handleLikeEvent(int index) {
    final currentEvent = getCurrentEvent();
    final user = FirebaseAuth.instance.currentUser;

    if (currentEvent != null && user != null) {
      _matchingService.handleEventLike(
        eventId: currentEvent.id,
        userId: user.uid,
      );
    }
  }

  /// Handle pass event action (swipe left)
  void _handlePassEvent(int index) {
    final currentEvent = getCurrentEvent();
    final user = FirebaseAuth.instance.currentUser;

    if (currentEvent != null && user != null) {
      // Add user to event's declined list so it won't appear again
      _matchingService.handleEventDecline(
        eventId: currentEvent.id,
        userId: user.uid,
      );
      print('✅ Event declined and will not appear again for this user');
    } else {
      print('⚠️ Unable to decline event: missing event or user data');
    }
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

  /// Force update location when user taps location header
  Future<void> forceLocationUpdate() async {
    print('🔄 Force location update requested');

    if (!isClosed) {
      try {
        addressController.text = 'Updating location...';
        update();
      } catch (e) {
        print('⚠️ Controller already disposed, skipping address update');
        return;
      }
    } else {
      print('⚠️ Controller is closed, cannot update location');
      return;
    }

    try {
      print('🔄 Starting location service update...');

      // Use the location update method
      final success = await LocationService.updateUserLocationInFirebase();

      if (success) {
        print('✅ Location force updated successfully');
        // Get the updated location from Firebase
        await _getUserLocationFromFirebase();
      } else {
        print('⚠️ Force location update failed gracefully');
        _showLocationUpdateHelpMessage();
      }
    } catch (e) {
      print('❌ Force location update failed with error: $e');
      _showLocationUpdateHelpMessage();
    }
  }

  /// Show helpful message when location update fails
  void _showLocationUpdateHelpMessage() {
    if (!isClosed) {
      try {
        final errorString = addressController.text.toLowerCase();

        if (errorString.contains('permission') ||
            errorString.contains('denied')) {
          addressController.text = MyStrings.tapToEnableLocation;
        } else if (errorString.contains('service') ||
            errorString.contains('disabled')) {
          addressController.text = MyStrings.pleaseEnableLocationServices;
        } else {
          addressController.text = MyStrings.tapToRetryLocation;
        }

        update();
      } catch (e) {
        print('⚠️ Controller already disposed, skipping address update');
        return;
      }
    } else {
      return;
    }

    // Revert to fallback location after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _getUserLocationFromFirebase();
    });
  }

  /// Refresh data when user manually requests it (e.g., pull to refresh)
  Future<void> onUserRefresh() async {
    // Only call this for explicit user actions
    await updateLocationAndRefresh();
  }

  /// Change selected address (used by location selector)
  void changeSelectedAddress(String address) {
    addressController.text = address;
    CustomSnackBar.successDeferred(successList: ['Address selected: $address']);
    update();
  }

  // =========================
  // UTILITY METHODS
  // =========================
}
