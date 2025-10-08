import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/helper/string_format_helper.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';

class CustomSnackBar {
  /// Build modern snackbar content with icon and styling
  static Widget _buildModernContent({
    required String message,
    required IconData icon,
    required bool isError,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isError
              ? [
                  MyColor.getRedColor(),
                  MyColor.getRedColor().withOpacity(0.8),
                ]
              : [
                  MyColor.getGreenColor(),
                  MyColor.getGreenColor().withOpacity(0.8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Dimensions.modernRadius),
        boxShadow: [
          BoxShadow(
            color: (isError ? MyColor.getRedColor() : MyColor.getGreenColor())
                .withOpacity(0.3),
            blurRadius: Dimensions.shadowBlur,
            offset: const Offset(0, Dimensions.shadowOffset),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space20,
          vertical: Dimensions.space15,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.space8),
              decoration: BoxDecoration(
                color: MyColor.getWhiteColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(Dimensions.cardRadius),
              ),
              child: Icon(
                icon,
                color: MyColor.getWhiteColor(),
                size: Dimensions.iconSize,
              ),
            ),
            const SizedBox(width: Dimensions.space15),
            Expanded(
              child: Text(
                message,
                style: regularLarge.copyWith(
                  color: MyColor.getWhiteColor(),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show error snackbar after current build frame is complete
  static errorDeferred({required List<String> errorList, int duration = 5}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      error(errorList: errorList, duration: duration);
    });
  }

  /// Show success snackbar after current build frame is complete
  static successDeferred(
      {required List<String> successList, int duration = 5}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      success(successList: successList, duration: duration);
    });
  }

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
    message =
        AppConverter.removeQuotationAndSpecialCharacterFromString(message);

    Get.rawSnackbar(
      messageText: _buildModernContent(
        message: message,
        icon: Icons.error_outline_rounded,
        isError: true,
      ),
      dismissDirection: DismissDirection.horizontal,
      snackPosition: SnackPosition.TOP,
      backgroundColor: MyColor.getTransparentColor(),
      borderRadius: Dimensions.modernRadius,
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.space15,
        vertical: Dimensions.space10,
      ),
      padding: EdgeInsets.zero,
      duration: Duration(seconds: duration),
      isDismissible: true,
      forwardAnimationCurve: Curves.elasticOut,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 600),
      showProgressIndicator: false,
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
    message =
        AppConverter.removeQuotationAndSpecialCharacterFromString(message);

    Get.rawSnackbar(
      messageText: _buildModernContent(
        message: message,
        icon: Icons.check_circle_outline_rounded,
        isError: false,
      ),
      dismissDirection: DismissDirection.horizontal,
      snackPosition: SnackPosition.TOP,
      backgroundColor: MyColor.getTransparentColor(),
      borderRadius: Dimensions.modernRadius,
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.space15,
        vertical: Dimensions.space10,
      ),
      padding: EdgeInsets.zero,
      duration: Duration(seconds: duration),
      isDismissible: true,
      forwardAnimationCurve: Curves.elasticOut,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 600),
      showProgressIndicator: false,
    );
  }

  /// Show info snackbar after current build frame is complete
  static infoDeferred({required List<String> infoList, int duration = 4}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      info(infoList: infoList, duration: duration);
    });
  }

  /// Show warning snackbar after current build frame is complete
  static warningDeferred(
      {required List<String> warningList, int duration = 4}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      warning(warningList: warningList, duration: duration);
    });
  }

  static info({required List<String> infoList, int duration = 4}) {
    String message = '';
    if (infoList.isEmpty) {
      message = MyStrings.somethingWentWrong.tr;
    } else {
      for (var element in infoList) {
        String tempMessage = element.tr;
        message = message.isEmpty ? tempMessage : "$message\n$tempMessage";
      }
    }
    message =
        AppConverter.removeQuotationAndSpecialCharacterFromString(message);

    Get.rawSnackbar(
      messageText: _buildInfoContent(message: message),
      dismissDirection: DismissDirection.horizontal,
      snackPosition: SnackPosition.TOP,
      backgroundColor: MyColor.getTransparentColor(),
      borderRadius: Dimensions.modernRadius,
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.space15,
        vertical: Dimensions.space10,
      ),
      padding: EdgeInsets.zero,
      duration: Duration(seconds: duration),
      isDismissible: true,
      forwardAnimationCurve: Curves.elasticOut,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 600),
      showProgressIndicator: false,
    );
  }

  static warning({required List<String> warningList, int duration = 4}) {
    String message = '';
    if (warningList.isEmpty) {
      message = MyStrings.somethingWentWrong.tr;
    } else {
      for (var element in warningList) {
        String tempMessage = element.tr;
        message = message.isEmpty ? tempMessage : "$message\n$tempMessage";
      }
    }
    message =
        AppConverter.removeQuotationAndSpecialCharacterFromString(message);

    Get.rawSnackbar(
      messageText: _buildWarningContent(message: message),
      dismissDirection: DismissDirection.horizontal,
      snackPosition: SnackPosition.TOP,
      backgroundColor: MyColor.getTransparentColor(),
      borderRadius: Dimensions.modernRadius,
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.space15,
        vertical: Dimensions.space10,
      ),
      padding: EdgeInsets.zero,
      duration: Duration(seconds: duration),
      isDismissible: true,
      forwardAnimationCurve: Curves.elasticOut,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 600),
      showProgressIndicator: false,
    );
  }

  /// Build info snackbar content
  static Widget _buildInfoContent({required String message}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColor.getPrimaryColor(),
            MyColor.getPrimaryColor().withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Dimensions.modernRadius),
        boxShadow: [
          BoxShadow(
            color: MyColor.getPrimaryColor().withOpacity(0.3),
            blurRadius: Dimensions.shadowBlur,
            offset: const Offset(0, Dimensions.shadowOffset),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space20,
          vertical: Dimensions.space15,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.space8),
              decoration: BoxDecoration(
                color: MyColor.getWhiteColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(Dimensions.cardRadius),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: MyColor.getWhiteColor(),
                size: Dimensions.iconSize,
              ),
            ),
            const SizedBox(width: Dimensions.space15),
            Expanded(
              child: Text(
                message,
                style: regularLarge.copyWith(
                  color: MyColor.getWhiteColor(),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build warning snackbar content
  static Widget _buildWarningContent({required String message}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColor.getPendingColor(),
            MyColor.getPendingColor().withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Dimensions.modernRadius),
        boxShadow: [
          BoxShadow(
            color: MyColor.getPendingColor().withOpacity(0.3),
            blurRadius: Dimensions.shadowBlur,
            offset: const Offset(0, Dimensions.shadowOffset),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space20,
          vertical: Dimensions.space15,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.space8),
              decoration: BoxDecoration(
                color: MyColor.getWhiteColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(Dimensions.cardRadius),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: MyColor.getWhiteColor(),
                size: Dimensions.iconSize,
              ),
            ),
            const SizedBox(width: Dimensions.space15),
            Expanded(
              child: Text(
                message,
                style: regularLarge.copyWith(
                  color: MyColor.getWhiteColor(),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
