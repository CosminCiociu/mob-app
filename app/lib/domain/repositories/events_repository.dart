import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository interface for events data operations
abstract class EventsRepository {
  /// Fetch events near a specific location using manual distance calculation
  Future<List<DocumentSnapshot>> fetchNearbyEventsManual({
    required GeoPoint userLocation,
    required double radiusInKm,
    String? currentUserId,
  });

  /// Fetch events near a specific location using geohash queries
  Future<List<DocumentSnapshot>> fetchNearbyEvents({
    required GeoPoint userLocation,
    required String userGeohash,
    required double radiusInKm,
    String? currentUserId,
  });

  /// Get all events from the collection (for debugging/testing)
  Future<List<DocumentSnapshot>> getAllEvents();

  /// Get event data helpers
  Map<String, dynamic>? getEventData(DocumentSnapshot eventDoc);

  /// Get formatted event location
  String getEventLocation(Map<String, dynamic> eventData);

  /// Get formatted event category/subcategory
  String getEventCategory(Map<String, dynamic> eventData);

  /// Add user to event's liked users list
  Future<void> likeEvent({
    required String eventId,
    required String userId,
  });

  /// Add user to event's declined users list
  Future<void> declineEvent({
    required String eventId,
    required String userId,
  });

  /// Create notification for event organizer about like
  Future<void> createEventLikeNotification({
    required String eventId,
    required String eventCreatorId,
    required String likerUserId,
    required String likerName,
    required String eventName,
  });
}
