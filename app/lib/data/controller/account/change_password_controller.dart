import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';


class ChangePasswordController extends GetxController  {



  String? currentPass, password, confirmPass;

  bool isLoading      = false;
  List<String> errors = [];

  TextEditingController passController        = TextEditingController();
  TextEditingController currentPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  FocusNode currentPassFocusNode = FocusNode();
  FocusNode passwordFocusNode    = FocusNode();
  FocusNode confirmPassFocusNode = FocusNode();



  addError({required String error}) {
    if (!errors.contains(error)) {
      errors.add(error);
      update();
    }
  }

  removeError({required String error}) {
    if (errors.contains(error)) {
      errors.remove(error);
      update();
    }
  }

  bool submitLoading=false;


  void clearData() {
    isLoading=false;
    errors.clear();
    currentPassController.text='';
    passController.text='';
    confirmPassController.text='';
  }
}
