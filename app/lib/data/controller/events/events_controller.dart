import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventsController extends GetxController {
  bool isSubmitLoading = false;
  bool isLoading = false;
  bool isRepeatEvent = false;

  // eventImagePath
  String eventImagePath = '';
  // onPressed: controller.pickTimezone/
  String selectedTimezone = 'Selectează fusul orar';
  String timezoneLabel = 'Selectează fusul orar';

  void onTimezonePressed() {
    // Implement your timezone selection logic here
  }

  // TextEditingControllers for fields used in the form
  TextEditingController eventNameController = TextEditingController();
  TextEditingController inPersonOrVirtualController = TextEditingController();
  TextEditingController visibilityController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController();

  // Form validation getter (only checks fields used in the form)
  bool get isFormValid {
    return true;
  }

  // Create event method stub
  void createEvent() {
    // Implement your event creation logic here
  }

  // Dummy methods for image/GIF picking
  void pickGif() {
    // Implement GIF picker logic
  }

  void pickFromGallery() {
    // Implement gallery picker logic
  }

  void uploadImage() async {
    // Implement your image upload logic here
  }

  // Timezone picker stub
  void pickTimezone() {
    // Implement timezone picker logic
  }

  void toggleRepeatEvent() {
    isRepeatEvent = !isRepeatEvent;
    update();
  }

  // FocusNodes (if needed)
  FocusNode eventNameFocusNode = FocusNode();
  FocusNode inPersonOrVirtualFocusNode = FocusNode();
  FocusNode visibilityFocusNode = FocusNode();
  FocusNode detailsFocusNode = FocusNode();
  FocusNode dateTimeFocusNode = FocusNode();

  File? imageFile;

  List<Map<String, String>> favouritePersons = [
    {
      'name': 'Alice Johnson, 21',
      'occupation': 'UI UX Designer',
      'image': MyImages.girl1,
    },
    {
      'name': 'Bob Smith, 20',
      'occupation': 'Software Engineer',
      'image': MyImages.boySmile,
    },
    {
      'name': 'Catherine Lee, 16',
      'occupation': 'Data Scientist',
      'image': MyImages.girl2,
    },
    {
      'name': 'David Miller, 25',
      'occupation': 'Product Manager',
      'image': MyImages.girl1,
    },
    {
      'name': 'Emma Davis ,18',
      'occupation': 'Marketing Specialist',
      'image': MyImages.girl2,
    },
    {
      'name': 'Frank Brown, 21',
      'occupation': 'Graphic Designer',
      'image': MyImages.boySmile,
    },
    {
      'name': 'Grace Wilson, 25',
      'occupation': 'Business Analyst',
      'image': MyImages.girl1,
    },
    {
      'name': 'Henry Garcia, 22',
      'occupation': 'Financial Advisor',
      'image': MyImages.boySmile,
    },
    {
      'name': 'Isabella Martinez, 21',
      'occupation': 'Project Coordinator',
      'image': MyImages.girl2,
    },
    {
      'name': 'James Anderson, 25',
      'occupation': 'Operations Manager',
      'image': MyImages.girl1,
    },
    {
      'name': 'Katherine Thomas, 23',
      'occupation': 'Human Resources',
      'image': MyImages.boySmile,
    },
  ];
}
