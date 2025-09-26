import 'dart:async';
import 'package:get/get.dart';


class SmsVerificationController extends GetxController {



  bool hasError = false;
  bool isLoading = true;
  String currentText='';



  Future<void> intData() async {
    isLoading=true;
    update();
    isLoading=false;
    update();
    return;
  }


  bool submitLoading=false;

}