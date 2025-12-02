import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Mock StreamChatService to avoid version compatibility issues
class StreamChatService extends GetxController {
  bool get isConnected => false; // Mock: always disconnected

  /// Mock initialize - does nothing but logs
  Future<void> initialize() async {
    try {
      print('🚀 StreamChatService: Mock initialization (Stream Chat disabled)');
      print('✅ StreamChatService: Mock client created successfully');
    } catch (e) {
      print('❌ StreamChatService: Failed to initialize - $e');
      rethrow;
    }
  }

  /// Mock connect user - does nothing but logs
  Future<void> connectUser() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('❌ StreamChatService: No Firebase user found');
        return;
      }

      print(
          '🔗 StreamChatService: Mock connecting user ${firebaseUser.uid}...');
      print('✅ StreamChatService: Mock user connected successfully');
      update();
    } catch (e) {
      print('❌ StreamChatService: Failed to connect user - $e');
      rethrow;
    }
  }

  /// Mock create DM channel - returns null
  Future<Map<String, dynamic>?> createDMChannel(
      String otherUserId, String otherUserName) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('❌ StreamChatService: No current user');
        return null;
      }

      if (otherUserId == firebaseUser.uid) {
        print('❌ StreamChatService: Cannot message yourself');
        return null;
      }

      print(
          '💬 StreamChatService: Mock creating DM channel with $otherUserName');
      print('✅ StreamChatService: Mock DM channel created successfully');

      // Return mock channel data
      return {
        'id': '${firebaseUser.uid}-$otherUserId',
        'type': 'messaging',
        'name': 'Direct Message with $otherUserName',
        'members': [firebaseUser.uid, otherUserId],
      };
    } catch (e) {
      print('❌ StreamChatService: Failed to create DM channel - $e');
      return null;
    }
  }

  /// Mock create event channel - returns null
  Future<Map<String, dynamic>?> createEventChannel(
      String eventId, String eventName) async {
    try {
      print('👥 StreamChatService: Mock creating event channel for $eventName');
      print('✅ StreamChatService: Mock event channel created successfully');

      // Return mock channel data
      return {
        'id': 'event-$eventId',
        'type': 'team',
        'name': eventName,
        'event_id': eventId,
      };
    } catch (e) {
      print('❌ StreamChatService: Failed to create event channel - $e');
      return null;
    }
  }

  /// Mock send message - does nothing but logs
  Future<void> sendMessage(Map<String, dynamic> channel, String text) async {
    try {
      print(
          '✅ StreamChatService: Mock message sent to channel ${channel['id']}');
    } catch (e) {
      print('❌ StreamChatService: Failed to send message - $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
