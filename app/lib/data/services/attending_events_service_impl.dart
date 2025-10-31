import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/services/attending_events_service.dart';
import '../../core/utils/my_strings.dart';
import '../../core/utils/firebase_repository_base.dart';

/// Implementation of AttendingEventsService
class AttendingEventsServiceImpl implements AttendingEventsService {
  // State callback
  void Function()? _stateChangeCallback;

  // Loading states
  bool _isLoading = false;
  bool _isRefreshing = false;
  String _errorMessage = '';
  AttendingEventTab _currentTab = AttendingEventTab.upcoming;

  // Event lists
  final List<Map<String, dynamic>> _upcomingEvents = [];
  final List<Map<String, dynamic>> _activeEvents = [];
  final List<Map<String, dynamic>> _pastEvents = [];
  final List<Map<String, dynamic>> _pendingEvents = [];

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isRefreshing => _isRefreshing;

  @override
  String get errorMessage => _errorMessage;

  @override
  AttendingEventTab get currentTab => _currentTab;

  @override
  List<Map<String, dynamic>> get upcomingEvents =>
      List.unmodifiable(_upcomingEvents);

  @override
  List<Map<String, dynamic>> get activeEvents =>
      List.unmodifiable(_activeEvents);

  @override
  List<Map<String, dynamic>> get pastEvents => List.unmodifiable(_pastEvents);

  @override
  List<Map<String, dynamic>> get pendingEvents =>
      List.unmodifiable(_pendingEvents);

  @override
  List<Map<String, dynamic>> get currentTabEvents {
    switch (_currentTab) {
      case AttendingEventTab.upcoming:
        return upcomingEvents;
      case AttendingEventTab.active:
        return activeEvents;
      case AttendingEventTab.past:
        return pastEvents;
      case AttendingEventTab.pending:
        return pendingEvents;
    }
  }

  @override
  bool get hasAnyEvents {
    return _upcomingEvents.isNotEmpty ||
        _activeEvents.isNotEmpty ||
        _pastEvents.isNotEmpty ||
        _pendingEvents.isNotEmpty;
  }

  @override
  int get totalEventsCount {
    return _upcomingEvents.length +
        _activeEvents.length +
        _pastEvents.length +
        _pendingEvents.length;
  }

  @override
  String get currentTabTitle {
    switch (_currentTab) {
      case AttendingEventTab.upcoming:
        return MyStrings.upcoming;
      case AttendingEventTab.active:
        return MyStrings.active;
      case AttendingEventTab.past:
        return MyStrings.past;
      case AttendingEventTab.pending:
        return MyStrings.pendingApproval;
    }
  }

  @override
  void setLoading(bool loading) {
    _isLoading = loading;
    _notifyStateChange();
  }

  @override
  void setRefreshing(bool refreshing) {
    _isRefreshing = refreshing;
    _notifyStateChange();
  }

  @override
  void setErrorMessage(String message) {
    _errorMessage = message;
    _notifyStateChange();
  }

  @override
  void switchTab(AttendingEventTab tab) {
    _currentTab = tab;
    _notifyStateChange();
  }

  @override
  Future<void> fetchAttendingEvents() async {
    try {
      setLoading(true);
      setErrorMessage('');

      final user = _auth.currentUser;
      if (user == null) {
        setErrorMessage('User not authenticated');
        return;
      }

      // Get user's attending events from their profile or a separate collection
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      if (userData == null) {
        setErrorMessage('User data not found');
        return;
      }

      // Get attending event IDs with proper type checking
      final List<String> attendingEventIds =
          _extractEventIds(userData['events_attending']);

      // Get pending event IDs (events where user applied but not approved yet)
      final List<String> pendingEventIds =
          _extractEventIds(userData['events_pending']);

      if (attendingEventIds.isEmpty && pendingEventIds.isEmpty) {
        clearAllEvents();
        return;
      }

      // Fetch event details
      if (attendingEventIds.isNotEmpty) {
        await _fetchEventsByIds(attendingEventIds, false);
      }

      if (pendingEventIds.isNotEmpty) {
        await _fetchEventsByIds(pendingEventIds, true);
      }
    } catch (e) {
      setErrorMessage('Failed to load attending events');
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> refreshEvents() async {
    setRefreshing(true);
    await fetchAttendingEvents();
    setRefreshing(false);
  }

  @override
  Future<void> leaveEvent(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Use transaction to ensure atomic operation
      await _firestore.runTransaction((transaction) async {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final eventDoc = _firestore.collection('users_events').doc(eventId);

        final userSnapshot = await transaction.get(userDoc);
        final eventSnapshot = await transaction.get(eventDoc);

        if (!userSnapshot.exists || !eventSnapshot.exists) {
          throw Exception('User or event not found');
        }

        final userData = userSnapshot.data() as Map<String, dynamic>;
        final eventData = eventSnapshot.data() as Map<String, dynamic>;

        // Check if user is in attending or pending
        final eventsAttending =
            userData['events_attending'] as Map<String, dynamic>? ?? {};
        final eventsPending =
            userData['events_pending'] as Map<String, dynamic>? ?? {};

        Map<String, dynamic> userUpdates = {};
        Map<String, dynamic> eventUpdates = {};

        // Remove from attending if present
        if (eventsAttending.containsKey(eventId)) {
          eventsAttending.remove(eventId);
          userUpdates['events_attending'] = eventsAttending;

          // Update event's attendees count and map
          final attendees =
              (eventData['attendees'] as Map<String, dynamic>?) ?? {};
          if (attendees.containsKey(user.uid)) {
            attendees.remove(user.uid);
            eventUpdates['attendees'] = attendees;
            eventUpdates['currentAttendees'] = attendees.length;
          }
        }

        // Remove from pending if present
        if (eventsPending.containsKey(eventId)) {
          eventsPending.remove(eventId);
          userUpdates['events_pending'] = eventsPending;
        }

        // Add to declined events
        final eventsDeclined =
            userData['events_declined'] as Map<String, dynamic>? ?? {};
        eventsDeclined[eventId] = FieldValue.serverTimestamp();
        userUpdates['events_declined'] = eventsDeclined;
        userUpdates['updatedAt'] = FieldValue.serverTimestamp();

        // Update event's declined users map
        final usersDeclined = FirebaseRepositoryBase.extractStringMap(
            eventData, 'users_declined');
        if (!usersDeclined.containsKey(user.uid)) {
          usersDeclined[user.uid] = {
            'declinedAt': FieldValue.serverTimestamp(),
          };
          eventUpdates['users_declined'] = usersDeclined;
        }
        eventUpdates['updatedAt'] = FieldValue.serverTimestamp();

        // Perform updates
        if (userUpdates.isNotEmpty) {
          transaction.update(userDoc, userUpdates);
        }
        if (eventUpdates.isNotEmpty) {
          transaction.update(eventDoc, eventUpdates);
        }
      });

      // Refresh the events
      await fetchAttendingEvents();

      Get.snackbar(
        'Success',
        'You have left the event',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to leave event',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Future<void> toggleReminder(String eventId, bool currentStatus) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final reminders = currentStatus
          ? FieldValue.arrayRemove([eventId])
          : FieldValue.arrayUnion([eventId]);

      await _firestore.collection('users').doc(user.uid).update({
        'eventReminders': reminders,
      });

      // Update local data
      _updateEventReminderStatus(eventId, !currentStatus);

      Get.snackbar(
        'Success',
        currentStatus ? 'Reminder turned off' : 'Reminder turned on',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update reminder',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void clearAllEvents() {
    _upcomingEvents.clear();
    _activeEvents.clear();
    _pastEvents.clear();
    _pendingEvents.clear();
    _notifyStateChange();
  }

  @override
  void setStateChangeCallback(void Function()? callback) {
    _stateChangeCallback = callback;
  }

  // Private helper methods

  void _notifyStateChange() {
    _stateChangeCallback?.call();
  }

  /// Fetch events by IDs and categorize them
  Future<void> _fetchEventsByIds(List<String> eventIds, bool isPending) async {
    final events = <Map<String, dynamic>>[];

    // Fetch events in batches (Firestore 'in' query limit is 10)
    const batchSize = 10;
    for (int i = 0; i < eventIds.length; i += batchSize) {
      final batch = eventIds.skip(i).take(batchSize).toList();

      final query = await _firestore
          .collection('users_events')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (final doc in query.docs) {
        final eventData = doc.data();
        eventData['id'] = doc.id;

        // Add host information
        await _enrichEventWithHostInfo(eventData);

        events.add(eventData);
      }
    }

    if (isPending) {
      _pendingEvents.clear();
      _pendingEvents.addAll(events);
    } else {
      _categorizeEvents(events);
    }

    _notifyStateChange();
  }

  /// Add host information to event data
  Future<void> _enrichEventWithHostInfo(Map<String, dynamic> eventData) async {
    try {
      final hostId = eventData['userId'];
      if (hostId != null) {
        final hostDoc = await _firestore.collection('users').doc(hostId).get();
        final hostData = hostDoc.data();

        if (hostData != null) {
          eventData['hostName'] =
              hostData['displayName'] ?? hostData['name'] ?? 'Unknown Host';
          eventData['hostAvatar'] = hostData['photoURL'] ?? hostData['avatar'];
          eventData['hostVerified'] = hostData['verified'] ?? false;
        }
      }
    } catch (e) {
      eventData['hostName'] = 'Unknown Host';
    }
  }

  /// Categorize events by time status
  void _categorizeEvents(List<Map<String, dynamic>> events) {
    final upcoming = <Map<String, dynamic>>[];
    final active = <Map<String, dynamic>>[];
    final past = <Map<String, dynamic>>[];

    final now = DateTime.now();

    for (final event in events) {
      // Try different date field names
      var eventDateTime = _parseEventDateTime(event['dateTime']);

      // Fallback to createdAt if dateTime is null
      if (eventDateTime == null) {
        eventDateTime = _parseEventDateTime(event['createdAt']);
      }

      if (eventDateTime == null) {
        continue;
      }

      // Determine if event is active, upcoming, or past
      final eventEndTime =
          eventDateTime.add(const Duration(hours: 4)); // Assume 4-hour events

      if (eventDateTime.isAfter(now)) {
        upcoming.add(event);
      } else if (eventDateTime.isBefore(now) && eventEndTime.isAfter(now)) {
        active.add(event);
      } else {
        past.add(event);
      }
    }

    // Sort by date
    upcoming.sort((a, b) => _parseEventDateTime(a['createdAt'])!
        .compareTo(_parseEventDateTime(b['createdAt'])!));
    active.sort((a, b) => _parseEventDateTime(a['createdAt'])!
        .compareTo(_parseEventDateTime(b['createdAt'])!));
    past.sort((a, b) => _parseEventDateTime(b['createdAt'])!.compareTo(
        _parseEventDateTime(a['createdAt'])!)); // Reverse for past events

    _upcomingEvents.clear();
    _activeEvents.clear();
    _pastEvents.clear();

    _upcomingEvents.addAll(upcoming);
    _activeEvents.addAll(active);
    _pastEvents.addAll(past);
  }

  /// Parse event date time
  DateTime? _parseEventDateTime(dynamic dateTime) {
    if (dateTime == null) return null;

    if (dateTime is Timestamp) {
      return dateTime.toDate();
    } else if (dateTime is String) {
      return DateTime.tryParse(dateTime);
    }

    return null;
  }

  /// Safely extract event IDs from various data formats
  List<String> _extractEventIds(dynamic eventData) {
    if (eventData == null) return [];

    try {
      // If it's already a List
      if (eventData is List) {
        return eventData.map((item) => item.toString()).toList();
      }

      // If it's a Map (like events_attending might be stored as a map)
      if (eventData is Map) {
        // If it has a 'list' or 'events' key containing the actual list
        if (eventData.containsKey('list')) {
          final list = eventData['list'];
          if (list is List) {
            return list.map((item) => item.toString()).toList();
          }
        }

        if (eventData.containsKey('events')) {
          final list = eventData['events'];
          if (list is List) {
            return list.map((item) => item.toString()).toList();
          }
        }

        // If the map keys are the event IDs (e.g. {eventId: {...}})
        return eventData.keys.map((key) => key.toString()).toList();
      }

      // If it's a single string
      if (eventData is String) {
        return [eventData];
      }

      // Unexpected format
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Update reminder status in local data
  void _updateEventReminderStatus(String eventId, bool hasReminder) {
    _updateEventInList(_upcomingEvents, eventId, 'hasReminder', hasReminder);
    _updateEventInList(_activeEvents, eventId, 'hasReminder', hasReminder);
    _updateEventInList(_pastEvents, eventId, 'hasReminder', hasReminder);
    _notifyStateChange();
  }

  /// Update event property in a list
  void _updateEventInList(List<Map<String, dynamic>> eventList, String eventId,
      String property, dynamic value) {
    final index = eventList.indexWhere((event) => event['id'] == eventId);
    if (index != -1) {
      eventList[index][property] = value;
    }
  }
}
