import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/event_repository.dart';
import '../../core/utils/firebase_repository_base.dart';

/// Firebase implementation of EventRepository
class FirebaseEventRepository extends FirebaseRepositoryBase
    implements EventRepository {
  static CollectionReference get _eventsCollection =>
      FirebaseRepositoryBase.getCollection(
          FirebaseRepositoryBase.eventsCollection);

  @override
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('create event',
        () async {
      await _eventsCollection
          .add(FirebaseRepositoryBase.addCreateTimestamp(eventData));
    });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchUserEvents(String userId) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('fetch user events',
        () async {
      final QuerySnapshot eventsSnapshot = await _eventsCollection
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return FirebaseRepositoryBase.extractDocumentsData(eventsSnapshot.docs);
    });
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('delete event',
        () async {
      await _eventsCollection.doc(eventId).delete();
    });
  }

  @override
  Future<void> updateEvent(
      String eventId, Map<String, dynamic> eventData) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('update event',
        () async {
      await _eventsCollection
          .doc(eventId)
          .update(FirebaseRepositoryBase.addUpdateTimestamp(eventData));
    });
  }

  @override
  Future<Map<String, dynamic>?> getEvent(String eventId) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('get event',
        () async {
      final DocumentSnapshot doc = await _eventsCollection.doc(eventId).get();

      if (doc.exists) {
        return FirebaseRepositoryBase.extractDocumentData(doc);
      }
      return null;
    });
  }

  @override
  Future<int> countUserEvents(String userId) async {
    return FirebaseRepositoryBase.executeWithErrorHandling('count user events',
        () async {
      final QuerySnapshot eventsSnapshot =
          await _eventsCollection.where('createdBy', isEqualTo: userId).get();

      return eventsSnapshot.docs.length;
    });
  }
}
