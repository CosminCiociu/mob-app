import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final TextEditingController chatController = TextEditingController();
  final Map<String, dynamic> person = {
    'name': 'Alice Johnson',
    'isActive': true,
    'profilePicture': 'assets/images/girl1.jpg', // Profile image path
  };

  final List<Map<String, dynamic>> messages = [
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
  ];
}
