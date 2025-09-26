import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationCodeController extends GetxController {
  bool fromloginScreen = false;
  TextEditingController countryController = TextEditingController();
  int seconds = 5;
  Timer? timer;
  bool resendCode = false;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    fromloginScreen = false;
    update();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        seconds--;
      } else {
        timer.cancel();
        resendCode = true;
        update();
      }
      update();
    });
  }
}
