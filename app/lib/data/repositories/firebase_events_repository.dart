import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/repositories/events_repository.dart';
import '../../core/utils/my_strings.dart';

/// Concrete implementation of EventsRepository using Firebase Firestore
class FirebaseEventsRepository implements EventsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<DocumentSnapshot>> fetchNearbyEventsManual({
    required GeoPoint userLocation,
    required double radiusInKm,
    String? currentUserId,
  }) async {
    try {
      // Get all events
      final allEvents = await _firestore.collection('users_events').get();
      final foundEvents = <DocumentSnapshot>[];

      for (var doc in allEvents.docs) {
        final eventData = doc.data();

        // Skip own events
        if (currentUserId != null && eventData['createdBy'] == currentUserId) {
          continue;
        }

        // Skip events that user has already declined
        if (currentUserId != null &&
            eventData['users_declined'] != null &&
            (eventData['users_declined'] as List).contains(currentUserId)) {
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
            userLocation.latitude,
            userLocation.longitude,
            eventGeoPoint.latitude,
            eventGeoPoint.longitude,
          );
          final distanceInKm = distanceInMeters / 1000;

          if (distanceInKm <= radiusInKm) {
            foundEvents.add(doc);
          }
        }
      }

      return foundEvents;
    } catch (e) {
      throw Exception('Failed to fetch nearby events manually: $e');
    }
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
      final geoQuery =
          GeoCollectionReference(_firestore.collection('users_events'))
              .subscribeWithin(
        center: centerPoint,
        radiusInKm: radiusInKm,
        field: 'location.geopoint',
        geopointFrom: (data) => data['location']['geopoint'] as GeoPoint,
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
    try {
      final allEventsQuery = await _firestore.collection('users_events').get();
      return allEventsQuery.docs;
    } catch (e) {
      throw Exception('Failed to get all events: $e');
    }
  }

  @override
  Map<String, dynamic>? getEventData(DocumentSnapshot eventDoc) {
    return eventDoc.data() as Map<String, dynamic>?;
  }

  @override
  String getEventLocation(Map<String, dynamic> eventData) {
    if (eventData['location'] == null) {
      return MyStrings.locationNotAvailable;
    }

    final location = eventData['location'] as Map<String, dynamic>;
    final address = location['address'] as Map<String, dynamic>?;

    if (address != null && address['administrativeArea'] != null) {
      return address['administrativeArea'] as String;
    }

    return MyStrings.locationNotAvailable;
  }

  @override
  String getEventCategory(Map<String, dynamic> eventData) {
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

  @override
  Future<void> likeEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      final eventDoc = _firestore.collection('users_events').doc(eventId);

      // Use Firestore transaction to ensure atomic operation
      await _firestore.runTransaction((transaction) async {
        final eventSnapshot = await transaction.get(eventDoc);

        if (!eventSnapshot.exists) {
          throw Exception('Event not found');
        }

        final eventData = eventSnapshot.data() as Map<String, dynamic>;
        List<String> userLiked = [];

        // Get existing liked users or create empty list
        if (eventData.containsKey('user_liked') &&
            eventData['user_liked'] != null) {
          userLiked = List<String>.from(eventData['user_liked']);
        }

        // Add user ID if not already present
        if (!userLiked.contains(userId)) {
          userLiked.add(userId);
          transaction.update(eventDoc, {
            'user_liked': userLiked,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
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
      final eventDoc = _firestore.collection('users_events').doc(eventId);

      // Use Firestore transaction to ensure atomic operation
      await _firestore.runTransaction((transaction) async {
        final eventSnapshot = await transaction.get(eventDoc);

        if (!eventSnapshot.exists) {
          throw Exception('Event not found');
        }

        final eventData = eventSnapshot.data() as Map<String, dynamic>;
        List<String> usersDeclined = [];

        // Get existing declined users or create empty list
        if (eventData.containsKey('users_declined') &&
            eventData['users_declined'] != null) {
          usersDeclined = List<String>.from(eventData['users_declined']);
        }

        // Add user ID if not already present
        if (!usersDeclined.contains(userId)) {
          usersDeclined.add(userId);
          transaction.update(eventDoc, {
            'users_declined': usersDeclined,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
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

      await _firestore.collection('notifications').add({
        'type': 'event_like',
        'recipientId': eventCreatorId,
        'senderId': likerUserId,
        'senderName': likerName,
        'eventId': eventId,
        'eventName': eventName,
        'title': 'Someone liked your event!',
        'message':
            '$likerName is interested in joining your event "$eventName"',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }
}
