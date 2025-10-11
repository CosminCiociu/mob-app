import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddProfileDetailsController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  int seconds = 5; // Countdown starts from 30 seconds
  Timer? timer;
  bool resendCode = false;
  String imageUrl = '';
  File? imageFile;
  TextEditingController dateController = TextEditingController();

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), // The earliest selectable date
      lastDate: DateTime(2100), // The latest selectable date
    );

    if (pickedDate != null) {
      dateController.text = DateFormat('yyyy-MM-dd')
          .format(pickedDate); // Format the date as needed
      update();
    }
  }
}
