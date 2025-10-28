import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'fake_document_snapshot.dart';
import '../../../domain/services/matching_service.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';

/// Manages all event-related functionality
class EventManager {
  /// Set a single event as the only event in the manager (for details screen)
  void setSingleEvent(Map<String, dynamic> eventData, String eventId) {
    // Create a fake DocumentSnapshot-like object for compatibility
    _nearbyEvents = [FakeDocumentSnapshot(eventId, eventData)];
    _currentIndex = 0;
  }

  final MatchingService _matchingService;

  // Event state
  List<dynamic> _nearbyEvents =
      []; // Can be DocumentSnapshot or FakeDocumentSnapshot
  int _currentIndex = 0;
  bool _isLoading = false;

  EventManager(this._matchingService);

  // Getters
  List<dynamic> get nearbyEvents => _nearbyEvents;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get hasEvents => _nearbyEvents.isNotEmpty;
  bool get hasFinishedAllEvents => _currentIndex >= _nearbyEvents.length;

  double get progressValue {
    if (_nearbyEvents.isEmpty) return 0.0;
    return (_currentIndex + 1) / _nearbyEvents.length;
  }

  dynamic get currentEvent {
    if (_nearbyEvents.isNotEmpty && _currentIndex < _nearbyEvents.length) {
      return _nearbyEvents[_currentIndex];
    }
    return null;
  }

  Map<String, dynamic>? get currentEventData {
    final event = currentEvent;
    if (event != null) {
      try {
        if (event is DocumentSnapshot) {
          return event.data() as Map<String, dynamic>?;
        } else if (event is FakeDocumentSnapshot) {
          return event.data();
        }
      } catch (e) {
        print('Error casting event data: $e');
        return null;
      }
    }
    return null;
  }

  /// Load events from Firebase
  Future<bool> loadEvents({
    required double radiusInKm,
    bool showFeedback = false,
  }) async {
    try {
      _setLoading(true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (showFeedback) {
          CustomSnackBar.errorDeferred(errorList: [MyStrings.userNotLoggedIn]);
        }
        return false;
      }

      List<DocumentSnapshot> events;
      print('Loading nearby events within $radiusInKm km for user ${user.uid}');
      events = await _matchingService.searchNearbyEvents(
        radiusInKm: radiusInKm,
        currentUserId: user.uid,
      );

      _nearbyEvents = events;
      _currentIndex = 0;

      print('✅ Loaded ${_nearbyEvents.length} nearby events');
      return true;
    } catch (e) {
      if (showFeedback) {
        CustomSnackBar.errorDeferred(errorList: [
          'Failed to load events: ${_matchingService.getDetailedErrorMessage(e)}'
        ]);
      } else {
        print('Failed to load events during initialization: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Handle swipe completion
  void handleSwipeComplete(int index) {
    if (index < _nearbyEvents.length) {
      _currentIndex = index + 1;
    }
  }

  /// Handle like event (swipe right)
  void handleLikeEvent() {
    final event = currentEvent;
    final user = FirebaseAuth.instance.currentUser;

    if (event != null && user != null) {
      _matchingService.handleEventLike(
        eventId: event.id,
        userId: user.uid,
      );
    }
  }

  /// Handle decline event (swipe left)
  void handleDeclineEvent() {
    final event = currentEvent;
    final user = FirebaseAuth.instance.currentUser;

    if (event != null && user != null) {
      _matchingService.handleEventDecline(
        eventId: event.id,
        userId: user.uid,
      );
      print('✅ Event declined and will not appear again for this user');
    } else {
      print('⚠️ Unable to decline event: missing event or user data');
    }
  }

  /// Reset to beginning
  void reset() {
    _currentIndex = 0;
  }

  /// Clear all events
  void clearEvents() {
    _nearbyEvents = [];
    _currentIndex = 0;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  /// Get current event location display
  String getCurrentEventLocation() {
    final eventData = currentEventData;
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
        return location.toString().length > 50
            ? 'Location available'
            : location.toString();
      }
    }
    return 'Location not available';
  }

  /// Get current event category display
  String getCurrentEventCategory() {
    final eventData = currentEventData;
    if (eventData != null) {
      final category = eventData['category'];
      if (category is String) {
        return category;
      } else if (category is Map<String, dynamic>) {
        return category['name'] as String? ??
            category['id'] as String? ??
            'Category not available';
      } else if (category != null) {
        return category.toString();
      }
    }
    return 'Category not available';
  }
}
