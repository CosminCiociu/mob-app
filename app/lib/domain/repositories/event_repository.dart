/// Repository interface for event data operations
abstract class EventRepository {
  /// Create a new event in the database
  Future<void> createEvent(Map<String, dynamic> eventData);

  /// Fetch events created by a specific user
  Future<List<Map<String, dynamic>>> fetchUserEvents(String userId);

  /// Delete an event by ID
  Future<void> deleteEvent(String eventId);

  /// Update an event
  Future<void> updateEvent(String eventId, Map<String, dynamic> eventData);

  /// Get event by ID
  Future<Map<String, dynamic>?> getEvent(String eventId);

  /// Count total events created by a specific user
  Future<int> countUserEvents(String userId);
}
