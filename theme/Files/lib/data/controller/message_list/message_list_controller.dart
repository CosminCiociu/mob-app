import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:get/get.dart';

class MessageListController extends GetxController {
  final TextEditingController searchController = TextEditingController();
List<Map<String, dynamic>> chatList = [
  {
    'name': 'Alice Johnson',
    'lastMessage': 'Hey, how are you?',
    'isActive': true,
    'pendingMessages': 2,
    'profilePicture': MyImages.girl1,
  },
  {
    'name': 'Bob Smith',
    'lastMessage': 'Let\'s meet tomorrow!',
    'isActive': false,
    'pendingMessages': 0,
    'profilePicture': MyImages.boySmile,
  },
  {
    'name': 'Catherine Lee',
    'lastMessage': 'I sent the documents.',
    'isActive': true,
    'pendingMessages': 1,
    'profilePicture': MyImages.girl2,
  },
  {
    'name': 'David Miller',
    'lastMessage': 'Got it. Thanks!',
    'isActive': false,
    'pendingMessages': 0,
    'profilePicture': MyImages.girl2,
  },
  {
    'name': 'Emma Davis',
    'lastMessage': 'See you at the event.',
    'isActive': true,
    'pendingMessages': 5,
    'profilePicture': MyImages.girl1,
  },
  {
    'name': 'Frank Brown',
    'lastMessage': 'Good morning!',
    'isActive': false,
    'pendingMessages': 0,
    'profilePicture': MyImages.boySmile,
  },
  {
    'name': 'Grace Wilson',
    'lastMessage': 'Where are you?',
    'isActive': true,
    'pendingMessages': 3,
    'profilePicture': MyImages.girl1,
  },
  {
    'name': 'Henry Garcia',
    'lastMessage': 'Let\'s catch up soon.',
    'isActive': false,
    'pendingMessages': 0,
    'profilePicture': MyImages.girl2,
  },
  {
    'name': 'Isabella Martinez',
    'lastMessage': 'Call me when you\'re free.',
    'isActive': true,
    'pendingMessages': 1,
    'profilePicture': MyImages.girl1,
  },
  {
    'name': 'James Anderson',
    'lastMessage': 'Thanks for the update!',
    'isActive': false,
    'pendingMessages': 0,
    'profilePicture': MyImages.boySmile,
  },
];

}
