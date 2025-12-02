import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Temporarily commented to avoid translation issues
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';
// import 'package:ovo_meet/services/stream_chat_service.dart';

class ChatController extends GetxController {
  final TextEditingController chatController = TextEditingController();

  // Stream Chat integration - temporarily disabled
  // StreamChatService? _streamChatService;
  // Channel? currentChannel;
  dynamic currentChannel; // Placeholder to avoid compilation issues

  // Reactive variables for UI
  RxBool isLoading = false.obs;
  RxBool isConnected = false.obs;
  RxList<Map<String, dynamic>> streamMessages = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> mockMessages = <Map<String, dynamic>>[].obs;

  // Chat partner info (can be passed from previous screen)
  Map<String, dynamic> person = {
    'name': 'Loading...',
    'isActive': false,
    'profilePicture': 'assets/images/place_holder.png',
    'userId': '',
  };

  @override
  void onInit() {
    super.onInit();
    // _initializeStreamChat(); // Temporarily disabled
    _loadMockMessages();
  }

  /// Initialize Stream Chat service - temporarily disabled
  // void _initializeStreamChat() async {
  //   try {
  //     _streamChatService = Get.find<StreamChatService>();
  //     isConnected.value = _streamChatService?.isConnected ?? false;
  //
  //     if (isConnected.value) {
  //       print('✅ ChatController: Stream Chat service found and connected');
  //     } else {
  //       print('⚠️ ChatController: Stream Chat not connected');
  //     }
  //   } catch (e) {
  //     print('❌ ChatController: Stream Chat service not found - $e');
  //     isConnected.value = false;
  //   }
  // }

  /// Load mock messages for demo
  void _loadMockMessages() {
    mockMessages.addAll([
      {
        'message': 'Hey! How are you doing?',
        'isSentByMe': false,
        'time': '9:30 AM',
      },
      {
        'message': 'I\'m doing great! Thanks for asking.',
        'isSentByMe': true,
        'time': '9:32 AM',
      },
      {
        'message': 'That\'s wonderful to hear!',
        'isSentByMe': false,
        'time': '9:35 AM',
      },
    ]);
  }

  /// Set up chat with a specific user - temporarily disabled
  void setupChatWithUser({
    required String otherUserId,
    required String otherUserName,
    String? otherUserImage,
  }) async {
    // Temporarily use mock data instead of Stream Chat
    person['name'] = otherUserName;
    person['userId'] = otherUserId;
    person['profilePicture'] =
        otherUserImage ?? 'assets/images/place_holder.png';
    person['isActive'] = true;
    update();
    return;

    // Original Stream Chat code commented out
    // if (_streamChatService == null) {
    //   print('❌ ChatController: Stream Chat service not available');
    //   return;
    // }

    // Commented out Stream Chat implementation
    // isLoading.value = true;
    //
    // try {
    //   // Update person info
    //   person = {
    //     'name': otherUserName,
    //     'isActive': true, // You can check online status from Stream
    //     'profilePicture': otherUserImage ?? 'assets/images/place_holder.png',
    //     'userId': otherUserId,
    //   };
    //
    //   // Get or create channel
    //   currentChannel = await _streamChatService!
    //       .getDirectMessageChannel(otherUserId, otherUserName);
    //
    //   if (currentChannel != null) {
    //     print('✅ ChatController: Channel created successfully');
    //     _listenToMessages();
    //   } else {
    //     print('❌ ChatController: Failed to create channel');
    //   }
    // } catch (e) {
    //   print('❌ ChatController: Error setting up chat - $e');
    // }
    //
    // isLoading.value = false;
    update(); // Update UI
  }

  /// Listen to real-time messages - temporarily disabled
  // void _listenToMessages() {
  //   if (currentChannel == null) return;
  //
  //   // Listen to messages stream
  //   currentChannel!.state?.messagesStream.listen((messageList) {
  //     streamMessages.value = messageList;
  //   });
  // }

  /// Send a message - temporarily disabled Stream Chat functionality
  void sendMessage() async {
    // Use mock message instead of Stream Chat
    sendMockMessage();
    return;

    // Original Stream Chat implementation commented out
    // final text = chatController.text.trim();
    // if (text.isEmpty || _streamChatService == null || currentChannel == null) {
    //   return;
    // }
    //
    // try {
    //   final success =
    //       await _streamChatService!.sendMessage(currentChannel!, text);
    //   if (success) {
    //     chatController.clear();
    //     print('✅ ChatController: Message sent successfully');
    //   } else {
    //     print('❌ ChatController: Failed to send message');
    //     // Show error to user
    //     Get.snackbar('Error', 'Failed to send message');
    //   }
    // } catch (e) {
    //   print('❌ ChatController: Error sending message - $e');
    //   Get.snackbar('Error', 'Failed to send message: $e');
    // }
  }

  /// Format message time for display
  String formatMessageTime(DateTime? createdAt) {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${createdAt.day}/${createdAt.month}';
    } else if (difference.inHours > 0) {
      return '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Check if current user sent the message
  bool isMessageFromCurrentUser(Map<String, dynamic> message) {
    return message['isSentByMe'] == true;
  }

  @override
  void onClose() {
    chatController.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    // Initialize mock messages
    mockMessages.addAll([
      {
        'isSentByMe': true,
        'message': 'Hey Alice!',
        'time': '10:30 AM',
      },
      {
        'isSentByMe': false,
        'message': 'Hello! How are you?',
        'time': '10:31 AM',
      },
      {
        'isSentByMe': true,
        'message': 'I am good, thanks!',
        'time': '10:32 AM',
      },
      {
        'isSentByMe': false,
        'message': 'What about our meeting?',
        'time': '10:33 AM',
      },
      {
        'isSentByMe': true,
        'message': 'Let\'s meet tomorrow.',
        'time': '10:35 AM',
      },
    ]);
  }

  /// Send a mock message (for fallback mode)
  void sendMockMessage() {
    final text = chatController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeString = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    mockMessages.add({
      'isSentByMe': true,
      'message': text,
      'time': timeString,
    });

    chatController.clear();
    update();
  }
}
