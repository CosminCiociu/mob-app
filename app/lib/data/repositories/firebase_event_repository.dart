import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/event_repository.dart';

/// Firebase implementation of EventRepository
class FirebaseEventRepository implements EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users_events';

  @override
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    try {
      await _firestore.collection(_collection).add({
        ...eventData,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchUserEvents(String userId) async {
    try {
      final QuerySnapshot eventsSnapshot = await _firestore
          .collection(_collection)
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return eventsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user events: $e');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  @override
  Future<void> updateEvent(
      String eventId, Map<String, dynamic> eventData) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        ...eventData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getEvent(String eventId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(eventId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }
}
