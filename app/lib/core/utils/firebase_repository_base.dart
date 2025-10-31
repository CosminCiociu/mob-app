import 'package:cloud_firestore/cloud_firestore.dart';

/// Base class for Firebase repository implementations
/// Provides common Firebase operations and utilities
abstract class FirebaseRepositoryBase {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get Firestore instance
  static FirebaseFirestore get firestore => _firestore;

  /// Common collection names
  static const String eventsCollection = 'users_events';
  static const String usersCollection = 'users';
  static const String notificationsCollection = 'notifications';
  static const String categoriesCollection = 'categories';

  /// Get collection reference
  static CollectionReference getCollection(String collectionName) {
    return _firestore.collection(collectionName);
  }

  /// Extract document data with ID
  static Map<String, dynamic> extractDocumentData(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return data;
  }

  /// Extract multiple documents data with IDs
  static List<Map<String, dynamic>> extractDocumentsData(
      List<DocumentSnapshot> docs) {
    return docs.map((doc) => extractDocumentData(doc)).toList();
  }

  /// Common timestamp operations
  static Map<String, dynamic> addCreateTimestamp(Map<String, dynamic> data) {
    return {
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active',
    };
  }

  static Map<String, dynamic> addUpdateTimestamp(Map<String, dynamic> data) {
    return {
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Array field operations
  static Map<String, dynamic> addToArrayField(String field, String value) {
    return {
      field: FieldValue.arrayUnion([value])
    };
  }

  static Map<String, dynamic> removeFromArrayField(String field, String value) {
    return {
      field: FieldValue.arrayRemove([value])
    };
  }

  /// User array operations helpers
  static Map<String, dynamic> addUserToArray(String field, String userId) {
    return addToArrayField(field, userId);
  }

  static Map<String, dynamic> removeUserFromArray(String field, String userId) {
    return removeFromArrayField(field, userId);
  }

  /// Safe list extraction from Firestore data
  static List<String> extractStringArray(
      Map<String, dynamic> data, String field) {
    if (data.containsKey(field) && data[field] != null) {
      return List<String>.from(data[field]);
    }
    return [];
  }

  /// Common error handling
  static Exception createRepositoryException(String operation, dynamic error) {
    return Exception('Failed to $operation: $error');
  }

  /// Execute with error handling
  static Future<T> executeWithErrorHandling<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    try {
      return await action();
    } catch (e) {
      throw createRepositoryException(operation, e);
    }
  }

  /// Check if user should be excluded from event results
  static bool shouldExcludeEventForUser(
    Map<String, dynamic> eventData,
    String? currentUserId,
  ) {
    if (currentUserId == null) return false;

    // Skip own events
    if (eventData['createdBy'] == currentUserId) {
      return true;
    }

    // Skip events that user has already declined
    if (eventData['users_declined'] != null) {
      final declinedUsers = extractStringArray(eventData, 'users_declined');
      if (declinedUsers.contains(currentUserId)) {
        return true;
      }
    }

    return false;
  }

  /// Check if event is active
  static bool isEventActive(Map<String, dynamic> eventData) {
    return eventData['status'] == 'active';
  }

  /// Batch update operations
  static Future<void> executeBatchUpdates(
    List<Map<String, dynamic>> updates,
  ) async {
    if (updates.isEmpty) return;

    final batch = _firestore.batch();

    for (final update in updates) {
      final ref = update['ref'] as DocumentReference;
      final data = update['data'] as Map<String, dynamic>;
      batch.update(ref, data);
    }

    await batch.commit();
  }

  /// Create notification helper
  static Future<void> createNotification({
    required String type,
    required String recipientId,
    required String senderId,
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
  }) async {
    final notificationData = {
      'type': type,
      'recipientId': recipientId,
      'senderId': senderId,
      'title': title,
      'message': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      ...?additionalData,
    };

    await getCollection(notificationsCollection).add(notificationData);
  }

  /// Common query operations
  static Future<List<DocumentSnapshot>> getActiveDocuments(
      String collectionName) async {
    final snapshot = await getCollection(collectionName)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs;
  }

  static Future<List<DocumentSnapshot>> getAllDocuments(
      String collectionName) async {
    final snapshot = await getCollection(collectionName).get();
    return snapshot.docs;
  }

  static Future<DocumentSnapshot?> getDocumentById(
      String collectionName, String docId) async {
    final doc = await getCollection(collectionName).doc(docId).get();
    return doc.exists ? doc : null;
  }

  static Future<bool> documentExists(
      String collectionName, String docId) async {
    final doc = await getCollection(collectionName).doc(docId).get();
    return doc.exists;
  }

  static Future<int> getCollectionCount(String collectionName,
      {Map<String, dynamic>? whereConditions}) async {
    Query query = getCollection(collectionName);

    if (whereConditions != null) {
      whereConditions.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });
    }

    final snapshot = await query.get();
    return snapshot.docs.length;
  }

  /// Search operations
  static List<Map<String, dynamic>> searchInDocuments(
    List<DocumentSnapshot> docs,
    String searchQuery,
    List<String> searchFields,
  ) {
    final query = searchQuery.toLowerCase();

    return docs.map((doc) => extractDocumentData(doc)).where((data) {
      return searchFields.any((field) {
        final fieldValue = data[field]?.toString().toLowerCase() ?? '';
        return fieldValue.contains(query);
      });
    }).toList();
  }

  /// User location operations
  static Future<Map<String, dynamic>?> getUserLocation(String userId) async {
    final userDoc = await getDocumentById(usersCollection, userId);
    if (userDoc?.data() != null) {
      final data = userDoc!.data() as Map<String, dynamic>;
      return data['location'] as Map<String, dynamic>?;
    }
    return null;
  }

  static Future<void> updateUserLocation(
    String userId,
    Map<String, dynamic> locationData,
  ) async {
    await getCollection(usersCollection).doc(userId).update({
      'location': locationData,
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    });
  }

  /// Logging utilities
  static void logInfo(String repositoryName, String message) {
    print('✅ $repositoryName: $message');
  }

  static void logError(String repositoryName, String message, [dynamic error]) {
    print('❌ $repositoryName: $message${error != null ? ': $error' : ''}');
  }

  static void logWarning(String repositoryName, String message) {
    print('⚠️ $repositoryName: $message');
  }

  static void logDebug(String repositoryName, String message) {
    print('🔄 $repositoryName: $message');
  }

  /// Sorting utilities
  static List<T> sortByCreatedAt<T>(
    List<T> items,
    DateTime Function(T) getCreatedAt, {
    bool ascending = true,
  }) {
    items.sort((a, b) {
      final aTime = getCreatedAt(a);
      final bTime = getCreatedAt(b);
      return ascending ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
    });
    return items;
  }

  static List<Map<String, dynamic>> sortDocumentsByField(
    List<Map<String, dynamic>> docs,
    String field, {
    bool ascending = true,
  }) {
    docs.sort((a, b) {
      final aValue = a[field];
      final bValue = b[field];

      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return ascending ? -1 : 1;
      if (bValue == null) return ascending ? 1 : -1;

      if (aValue is Comparable && bValue is Comparable) {
        return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      }

      return 0;
    });
    return docs;
  }

  /// Model conversion utilities
  static List<T> convertDocumentsToModels<T>(
    List<DocumentSnapshot> docs,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    return docs.map((doc) {
      final data = extractDocumentData(doc);
      return fromMap(data);
    }).toList();
  }

  /// Geo operations helper
  static bool isValidGeoPoint(dynamic geopoint) {
    return geopoint != null && geopoint is GeoPoint;
  }

  /// Safe field extraction
  static T? safeGet<T>(Map<String, dynamic> data, String field) {
    try {
      return data[field] as T?;
    } catch (e) {
      return null;
    }
  }

  static String safeGetString(Map<String, dynamic> data, String field,
      {String defaultValue = ''}) {
    return safeGet<String>(data, field) ?? defaultValue;
  }

  static bool safeGetBool(Map<String, dynamic> data, String field,
      {bool defaultValue = false}) {
    return safeGet<bool>(data, field) ?? defaultValue;
  }

  static int safeGetInt(Map<String, dynamic> data, String field,
      {int defaultValue = 0}) {
    return safeGet<int>(data, field) ?? defaultValue;
  }
}
