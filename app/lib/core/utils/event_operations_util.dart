import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/my_strings.dart';
import 'firebase_repository_base.dart';

/// Utility class for common event operations and calculations
class EventOperationsUtil {
  /// Calculate distance between two GeoPoints in kilometers
  static double calculateDistanceInKm(GeoPoint point1, GeoPoint point2) {
    final distanceInMeters = Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
    return distanceInMeters / 1000;
  }

  /// Extract GeoPoint from event location data
  static GeoPoint? extractGeoPoint(Map<String, dynamic> eventData) {
    if (eventData['location'] == null) return null;

    final location = eventData['location'] as Map<String, dynamic>;
    final geopoint = location['geopoint'];

    return geopoint is GeoPoint ? geopoint : null;
  }

  /// Check if event is within radius
  static bool isEventWithinRadius(
    Map<String, dynamic> eventData,
    GeoPoint userLocation,
    double radiusInKm,
  ) {
    final eventGeoPoint = extractGeoPoint(eventData);
    if (eventGeoPoint == null) return false;

    final distance = calculateDistanceInKm(userLocation, eventGeoPoint);
    return distance <= radiusInKm;
  }

  /// Filter events based on common criteria
  static List<DocumentSnapshot> filterEvents(
    List<DocumentSnapshot> events, {
    String? currentUserId,
    GeoPoint? userLocation,
    double? radiusInKm,
    bool activeOnly = true,
  }) {
    return events.where((doc) {
      final eventData = doc.data() as Map<String, dynamic>;

      // Filter active events only
      if (activeOnly && !FirebaseRepositoryBase.isEventActive(eventData)) {
        return false;
      }

      // Filter by user exclusions
      if (FirebaseRepositoryBase.shouldExcludeEventForUser(
          eventData, currentUserId)) {
        return false;
      }

      // Filter by location radius
      if (userLocation != null && radiusInKm != null) {
        if (!isEventWithinRadius(eventData, userLocation, radiusInKm)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Get formatted event location
  static String getEventLocation(Map<String, dynamic> eventData) {
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

  /// Get formatted event category
  static String getEventCategory(Map<String, dynamic> eventData) {
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

  /// Update event attendees count
  static Map<String, dynamic> updateAttendeesCount(
    Map<String, dynamic> eventData,
    int increment,
  ) {
    final currentCount = eventData['currentAttendees'] as int? ?? 0;
    return {
      'currentAttendees': currentCount + increment,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create event notification data
  static Map<String, dynamic> createEventNotificationData({
    required String type,
    required String eventId,
    required String eventName,
    required String recipientId,
    required String senderId,
    required String senderName,
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
  }) {
    return {
      'type': type,
      'recipientId': recipientId,
      'senderId': senderId,
      'senderName': senderName,
      'eventId': eventId,
      'eventName': eventName,
      'title': title,
      'message': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      ...?additionalData,
    };
  }

  /// Check if user can interact with event
  static bool canUserInteractWithEvent(
    Map<String, dynamic> eventData,
    String userId,
  ) {
    // User cannot interact with their own events
    if (eventData['createdBy'] == userId) {
      return false;
    }

    // User cannot interact with declined events
    final declinedUsers =
        FirebaseRepositoryBase.extractStringArray(eventData, 'users_declined');
    if (declinedUsers.contains(userId)) {
      return false;
    }

    // User cannot interact with inactive events
    if (!FirebaseRepositoryBase.isEventActive(eventData)) {
      return false;
    }

    return true;
  }

  /// Extract event requires approval flag
  static bool requiresApproval(Map<String, dynamic> eventData) {
    return eventData['requiresApproval'] as bool? ?? true;
  }

  /// Build user event relationship updates
  static Map<String, dynamic> buildUserEventUpdates({
    String? addToAttending,
    String? removeFromAttending,
    String? addToPending,
    String? removeFromPending,
    String? addToDeclined,
    String? removeFromDeclined,
  }) {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (addToAttending != null) {
      updates.addAll(FirebaseRepositoryBase.addUserToArray(
          'events_attending', addToAttending));
    }
    if (removeFromAttending != null) {
      updates.addAll(FirebaseRepositoryBase.removeUserFromArray(
          'events_attending', removeFromAttending));
    }
    if (addToPending != null) {
      updates.addAll(FirebaseRepositoryBase.addUserToArray(
          'events_pending', addToPending));
    }
    if (removeFromPending != null) {
      updates.addAll(FirebaseRepositoryBase.removeUserFromArray(
          'events_pending', removeFromPending));
    }
    if (addToDeclined != null) {
      updates.addAll(FirebaseRepositoryBase.addUserToArray(
          'events_declined', addToDeclined));
    }
    if (removeFromDeclined != null) {
      updates.addAll(FirebaseRepositoryBase.removeUserFromArray(
          'events_declined', removeFromDeclined));
    }

    return updates;
  }
}
