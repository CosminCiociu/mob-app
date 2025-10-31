import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../../domain/repositories/events_repository.dart';
import '../../core/utils/firebase_repository_base.dart';
import '../../core/utils/event_operations_util.dart';

/// Concrete implementation of EventsRepository using Firebase Firestore
class FirebaseEventsRepository extends FirebaseRepositoryBase
    implements EventsRepository {
  static CollectionReference get _eventsCollection =>
      FirebaseRepositoryBase.getCollection(
          FirebaseRepositoryBase.eventsCollection);
  static CollectionReference get _usersCollection =>
      FirebaseRepositoryBase.getCollection(
          FirebaseRepositoryBase.usersCollection);

  @override
  Future<List<DocumentSnapshot>> fetchNearbyEventsManual({
    required GeoPoint userLocation,
    required double radiusInKm,
    String? currentUserId,
  }) async {
    return FirebaseRepositoryBase.executeWithErrorHandling(
        'fetch nearby events manually', () async {
      // Get all events
      final allEvents = await _eventsCollection.get();

      // Use utility method to filter events with location and radius checks
      return EventOperationsUtil.filterEvents(
        allEvents.docs,
        currentUserId: currentUserId,
        userLocation: userLocation,
        radiusInKm: radiusInKm,
        activeOnly: true,
      );
    });
  }

  @override
  Future<List<DocumentSnapshot>> fetchNearbyEvents({
    required GeoPoint userLocation,
    required String userGeohash,
    required double radiusInKm,
    String? currentUserId,
  }) async {
    try {
      // Create GeoFirePoint from user's location
      final centerPoint = GeoFirePoint(userLocation);

      // Query nearby events using geoflutterfire_plus
      final geoQuery = GeoCollectionReference(
              FirebaseRepositoryBase.firestore.collection('users_events'))
          .subscribeWithin(
        center: centerPoint,
        radiusInKm: radiusInKm,
        field: 'location.geopoint',
        geopointFrom: (data) {
          final location = data['location'];
          if (location != null && location is Map<String, dynamic>) {
            final geopoint = location['geopoint'];
            if (geopoint is GeoPoint) {
              return geopoint;
            }
          }
          // Return a default GeoPoint if the data is invalid
          return GeoPoint(0, 0);
        },
      );

      final nearbyEvents = <DocumentSnapshot>[];

      await for (final docs in geoQuery) {
        for (final doc in docs) {
          final eventData = doc.data();
          if (eventData != null &&
              eventData['location'] != null &&
              eventData['status'] == 'active' &&
              (currentUserId == null ||
                  eventData['createdBy'] != currentUserId) &&
              // Skip events that user has already declined
              (currentUserId == null ||
                  eventData['users_declined'] == null ||
                  !(eventData['users_declined'] as List)
                      .contains(currentUserId))) {
            nearbyEvents.add(doc);
          }
        }
        break; // Take only the first batch
      }

      // If geo query returns empty, fallback to manual calculation
      if (nearbyEvents.isEmpty) {
        return await fetchNearbyEventsManual(
          userLocation: userLocation,
          radiusInKm: radiusInKm,
          currentUserId: currentUserId,
        );
      }

      return nearbyEvents;
    } catch (e) {
      // Fallback to manual calculation on error
      return await fetchNearbyEventsManual(
        userLocation: userLocation,
        radiusInKm: radiusInKm,
        currentUserId: currentUserId,
      );
    }
  }

  @override
  Future<List<DocumentSnapshot>> getAllEvents() async {
    return FirebaseRepositoryBase.executeWithErrorHandling('get all events',
        () async {
      final allEventsQuery = await _eventsCollection.get();
      return allEventsQuery.docs;
    });
  }

  @override
  Map<String, dynamic>? getEventData(DocumentSnapshot eventDoc) {
    return eventDoc.data() as Map<String, dynamic>?;
  }

  @override
  String getEventLocation(Map<String, dynamic> eventData) {
    return EventOperationsUtil.getEventLocation(eventData);
  }

  @override
  String getEventCategory(Map<String, dynamic> eventData) {
    return EventOperationsUtil.getEventCategory(eventData);
  }

  @override
  Future<void> likeEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      final eventDoc = FirebaseRepositoryBase.firestore
          .collection('users_events')
          .doc(eventId);
      final userDoc =
          FirebaseRepositoryBase.firestore.collection('users').doc(userId);

      // Use Firestore transaction to ensure atomic operation
      await FirebaseRepositoryBase.firestore
          .runTransaction((transaction) async {
        final eventSnapshot = await transaction.get(eventDoc);
        final userSnapshot = await transaction.get(userDoc);

        if (!eventSnapshot.exists) {
          throw Exception('Event not found');
        }

        if (!userSnapshot.exists) {
          throw Exception('User not found');
        }

        final eventData = eventSnapshot.data() as Map<String, dynamic>;
        final userData = userSnapshot.data() as Map<String, dynamic>;

        // Handle event's users_pending map (users who liked the event with timestamps)
        Map<String, dynamic> usersPending = {};
        if (eventData.containsKey('users_pending') &&
            eventData['users_pending'] != null) {
          usersPending = Map<String, dynamic>.from(eventData['users_pending']);
        }

        // Handle user's events_attending array (events that don't require approval)
        List<String> eventsAttending = [];
        if (userData.containsKey('events_attending') &&
            userData['events_attending'] != null) {
          eventsAttending = List<String>.from(userData['events_attending']);
        }

        // Handle user's events_pending array (events that require approval)
        List<String> eventsPending = [];
        if (userData.containsKey('events_pending') &&
            userData['events_pending'] != null) {
          eventsPending = List<String>.from(userData['events_pending']);
        }

        // Check if event requires approval
        final bool requiresApproval = eventData['requiresApproval'] ?? true;

        // Handle event's attendees array
        List<String> attendees = [];
        if (eventData.containsKey('attendees') &&
            eventData['attendees'] != null) {
          attendees = List<String>.from(eventData['attendees']);
        }

        // Always update the event to ensure all operations happen atomically
        Map<String, dynamic> eventUpdates = {
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Add user ID to event's pending users with timestamp if not already present
        if (!usersPending.containsKey(userId)) {
          usersPending[userId] = FieldValue.serverTimestamp();
        }
        eventUpdates['users_pending'] = usersPending;

        // If event doesn't require approval, automatically add user to attendees
        if (!requiresApproval && !attendees.contains(userId)) {
          attendees.add(userId);
        }
        eventUpdates['attendees'] = attendees;
        eventUpdates['currentAttendees'] = attendees.length;

        // Prepare user updates
        Map<String, dynamic> userUpdates = {
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Add event to appropriate category based on approval requirement
        if (!requiresApproval) {
          // Event doesn't require approval - add to events_attending
          if (!eventsAttending.contains(eventId)) {
            userUpdates['events_attending'] = FieldValue.arrayUnion([eventId]);
          }

          // Remove from pending if it was there
          if (eventsPending.contains(eventId)) {
            userUpdates['events_pending'] = FieldValue.arrayRemove([eventId]);
          }
        } else {
          // Event requires approval - add to events_pending
          if (!eventsPending.contains(eventId)) {
            userUpdates['events_pending'] = FieldValue.arrayUnion([eventId]);
          }

          // Remove from attending if it was there
          if (eventsAttending.contains(eventId)) {
            userUpdates['events_attending'] = FieldValue.arrayRemove([eventId]);
          }
        }

        // Perform both updates atomically
        transaction.update(eventDoc, eventUpdates);
        transaction.update(userDoc, userUpdates);
      });
    } catch (e) {
      throw Exception('Failed to like event: $e');
    }
  }

  @override
  Future<void> declineEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      final eventDoc = FirebaseRepositoryBase.firestore
          .collection('users_events')
          .doc(eventId);
      final userDoc =
          FirebaseRepositoryBase.firestore.collection('users').doc(userId);

      // Use Firestore transaction to ensure atomic operation
      await FirebaseRepositoryBase.firestore
          .runTransaction((transaction) async {
        final eventSnapshot = await transaction.get(eventDoc);
        final userSnapshot = await transaction.get(userDoc);

        if (!eventSnapshot.exists) {
          throw Exception('Event not found');
        }

        if (!userSnapshot.exists) {
          throw Exception('User not found');
        }

        final eventData = eventSnapshot.data() as Map<String, dynamic>;
        final userData = userSnapshot.data() as Map<String, dynamic>;

        // Handle event's users_declined array
        List<String> usersDeclined = [];
        if (eventData.containsKey('users_declined') &&
            eventData['users_declined'] != null) {
          usersDeclined = List<String>.from(eventData['users_declined']);
        }

        // Handle user's events_declined array
        List<String> eventsDeclined = [];
        if (userData.containsKey('events_declined') &&
            userData['events_declined'] != null) {
          eventsDeclined = List<String>.from(userData['events_declined']);
        }

        // Handle user's other event arrays to remove declined event from them
        List<String> eventsAttending = [];
        if (userData.containsKey('events_attending') &&
            userData['events_attending'] != null) {
          eventsAttending = List<String>.from(userData['events_attending']);
        }

        List<String> eventsPending = [];
        if (userData.containsKey('events_pending') &&
            userData['events_pending'] != null) {
          eventsPending = List<String>.from(userData['events_pending']);
        }

        // Prepare event updates
        Map<String, dynamic> eventUpdates = {
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Add user ID to event's declined users if not already present
        if (!usersDeclined.contains(userId)) {
          usersDeclined.add(userId);
        }
        eventUpdates['users_declined'] = usersDeclined;

        // Prepare user updates
        Map<String, dynamic> userUpdates = {
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Add event to user's declined events
        if (!eventsDeclined.contains(eventId)) {
          userUpdates['events_declined'] = FieldValue.arrayUnion([eventId]);
        }

        // Remove event from user's other event categories
        if (eventsAttending.contains(eventId)) {
          userUpdates['events_attending'] = FieldValue.arrayRemove([eventId]);
        }

        if (eventsPending.contains(eventId)) {
          userUpdates['events_pending'] = FieldValue.arrayRemove([eventId]);
        }

        // Perform both updates atomically
        transaction.update(eventDoc, eventUpdates);
        transaction.update(userDoc, userUpdates);
      });
    } catch (e) {
      throw Exception('Failed to decline event: $e');
    }
  }

  @override
  Future<void> createEventLikeNotification({
    required String eventId,
    required String eventCreatorId,
    required String likerUserId,
    required String likerName,
    required String eventName,
  }) async {
    try {
      // Don't create notification if user likes their own event
      if (eventCreatorId == likerUserId) {
        return;
      }

      await FirebaseRepositoryBase.createNotification(
        type: 'event_like',
        recipientId: eventCreatorId,
        senderId: likerUserId,
        title: 'Someone liked your event!',
        message: '$likerName is interested in joining your event "$eventName"',
        additionalData: {
          'senderName': likerName,
          'eventId': eventId,
          'eventName': eventName,
        },
      );
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Accept a pending member request for an event
  @override
  Future<void> acceptMember({
    required String eventId,
    required String userId,
    required String currentUserId,
  }) async {
    try {
      final batch = FirebaseRepositoryBase.firestore.batch();

      // Remove from users_pending map and add to attendees array in event
      final eventRef = _eventsCollection.doc(eventId);
      batch.update(eventRef, {
        'users_pending.$userId': FieldValue.delete(),
        'attendees': FieldValue.arrayUnion([userId]),
        'currentAttendees': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add to user's attending events
      final userEventsRef = _usersCollection.doc(userId);
      batch.update(userEventsRef, {
        'events_attending': FieldValue.arrayUnion([eventId]),
        'events_pending': FieldValue.arrayRemove([eventId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Create notification for accepted user
      await _createMemberStatusNotification(
        eventId: eventId,
        recipientId: userId,
        senderId: currentUserId,
        status: 'accepted',
      );
    } catch (e) {
      throw Exception('Failed to accept member: $e');
    }
  }

  /// Decline a pending member request for an event
  @override
  Future<void> declineMember({
    required String eventId,
    required String userId,
    required String currentUserId,
  }) async {
    try {
      final batch = FirebaseRepositoryBase.firestore.batch();

      // Remove from users_pending map in event
      final eventRef = _eventsCollection.doc(eventId);
      batch.update(eventRef, {
        'users_pending.$userId': FieldValue.delete(),
      });

      // Add to user's declined events
      final userEventsRef = _usersCollection.doc(userId);
      batch.update(userEventsRef, {
        'events_declined': FieldValue.arrayUnion([eventId]),
        'events_pending': FieldValue.arrayRemove([eventId]),
      });

      await batch.commit();

      // Create notification for declined user
      await _createMemberStatusNotification(
        eventId: eventId,
        recipientId: userId,
        senderId: currentUserId,
        status: 'declined',
      );
    } catch (e) {
      throw Exception('Failed to decline member: $e');
    }
  }

  /// Create notification for member status change
  Future<void> _createMemberStatusNotification({
    required String eventId,
    required String recipientId,
    required String senderId,
    required String status,
  }) async {
    try {
      // Get event details
      final eventDoc = await FirebaseRepositoryBase.firestore
          .collection('users_events')
          .doc(eventId)
          .get();
      final eventData = eventDoc.data();
      final eventName = eventData?['title'] ?? 'Event';

      // Get sender details
      final senderDoc = await FirebaseRepositoryBase.firestore
          .collection('users')
          .doc(senderId)
          .get();
      final senderData = senderDoc.data();
      final senderName = senderData?['firstname'] ?? 'Event organizer';

      String title =
          status == 'accepted' ? 'Request Accepted!' : 'Request Declined';
      String message = status == 'accepted'
          ? 'Your request to join "$eventName" has been accepted by $senderName'
          : 'Your request to join "$eventName" has been declined by $senderName';

      await FirebaseRepositoryBase.firestore.collection('notifications').add({
        'type': 'member_status',
        'recipientId': recipientId,
        'senderId': senderId,
        'senderName': senderName,
        'eventId': eventId,
        'eventName': eventName,
        'status': status,
        'title': title,
        'message': message,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create member status notification: $e');
    }
  }

  /// Get event members (confirmed and pending)
  @override
  Future<Map<String, List<Map<String, dynamic>>>> getEventMembers({
    required String eventId,
  }) async {
    try {
      final eventDoc = await FirebaseRepositoryBase.firestore
          .collection('users_events')
          .doc(eventId)
          .get();
      final eventData = eventDoc.data();

      if (eventData == null) {
        throw Exception('Event not found');
      }

      Map<String, dynamic> usersPending = eventData['users_pending'] ?? {};
      List<Map<String, dynamic>> confirmedMembers = [];
      List<Map<String, dynamic>> pendingMembers = [];

      // Get pending users details
      for (String userId in usersPending.keys) {
        final userDoc = await FirebaseRepositoryBase.firestore
            .collection('users')
            .doc(userId)
            .get();
        final userData = userDoc.data();
        if (userData != null) {
          pendingMembers.add({
            'id': userId,
            'email': userData['email'] ?? '',
            'displayName': userData['firstname'] ?? '',
            'photoUrl': userData['image'] ?? '',
            'phoneNumber': userData['mobile'] ?? '',
            'pendingTimestamp': usersPending[userId],
          });
        }
      }

      // Get confirmed members (users who have this event in their events_attending)
      final usersQuery = await FirebaseRepositoryBase.firestore
          .collection('users')
          .where('events_attending', arrayContains: eventId)
          .get();

      for (var userDoc in usersQuery.docs) {
        final userData = userDoc.data();
        confirmedMembers.add({
          'id': userDoc.id,
          'email': userData['email'] ?? '',
          'displayName': userData['firstname'] ?? '',
          'photoUrl': userData['image'] ?? '',
          'phoneNumber': userData['mobile'] ?? '',
        });
      }

      return {
        'confirmed': confirmedMembers,
        'pending': pendingMembers,
      };
    } catch (e) {
      throw Exception('Failed to get event members: $e');
    }
  }
}
