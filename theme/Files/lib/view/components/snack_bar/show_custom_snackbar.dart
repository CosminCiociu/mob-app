
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/helper/string_format_helper.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';

class CustomSnackBar {
  static error({required List<String> errorList, int duration = 5}) {
    String message = '';
    if (errorList.isEmpty) {
      message = MyStrings.somethingWentWrong.tr;
    } else {
      for (var element in errorList) {
        String tempMessage = element.tr;
        message = message.isEmpty ? tempMessage : "$message\n$tempMessage";
      }
    }
    message = AppConverter.removeQuotationAndSpecialCharacterFromString(message);

      Get.rawSnackbar(
        progressIndicatorBackgroundColor: MyColor.getTransparentColor(),
        progressIndicatorValueColor:  AlwaysStoppedAnimation<Color>(MyColor.getTransparentColor()),
        messageText: Text(message, style: regularLarge.copyWith(color: MyColor.getWhiteColor())),
        dismissDirection: DismissDirection.horizontal,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: MyColor.getRedColor(),
        borderRadius: 4,
        margin: const EdgeInsets.all(Dimensions.space8),
        padding: const EdgeInsets.all(Dimensions.space8),
        duration: Duration(seconds: duration),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeIn,
        showProgressIndicator: true,
        leftBarIndicatorColor: MyColor.getTransparentColor(),
        animationDuration: const Duration(seconds: 1),
        borderColor: MyColor.getTransparentColor(),
        reverseAnimationCurve: Curves.easeOut,
        borderWidth: 2,
      );
   
  }

  static success({required List<String> successList, int duration = 5}) {
    String message = '';
    if (successList.isEmpty) {
      message = MyStrings.somethingWentWrong.tr;
    } else {
      for (var element in successList) {
        String tempMessage = element.tr;
        message = message.isEmpty ? tempMessage : "$message\n$tempMessage";
      }
    }
    message = AppConverter.removeQuotationAndSpecialCharacterFromString(message);

    Get.rawSnackbar(
      progressIndicatorBackgroundColor: MyColor.getGreenColor(),
      progressIndicatorValueColor:  AlwaysStoppedAnimation<Color>(MyColor.getTransparentColor()),
      messageText: Text(message, style: regularLarge.copyWith(color: MyColor.getWhiteColor())),
      dismissDirection: DismissDirection.horizontal,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: MyColor.getGreenColor(),
      borderRadius: 4,
      margin: const EdgeInsets.all(Dimensions.space8),
      padding: const EdgeInsets.all(Dimensions.space8),
      duration: Duration(seconds: duration),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeInOutCubicEmphasized,
      showProgressIndicator: true,
      leftBarIndicatorColor: MyColor.getTransparentColor(),
      animationDuration: const Duration(seconds: 2),
      borderColor: MyColor.getTransparentColor(),
      reverseAnimationCurve: Curves.easeOut,
      borderWidth: 2,
    );
  }
}
