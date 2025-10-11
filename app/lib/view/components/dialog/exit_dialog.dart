import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';

showExitDialog(BuildContext context) {
  AwesomeDialog(
    padding: const EdgeInsets.symmetric(vertical: Dimensions.space10),
    context: context,
    dialogType: DialogType.noHeader,
    dialogBackgroundColor: MyColor.getCardBgColor(),
    width: MediaQuery.of(context).size.width,
    buttonsBorderRadius: BorderRadius.circular(Dimensions.defaultRadius),
    dismissOnTouchOutside: true,
    dismissOnBackKeyPress: true,
    onDismissCallback: (type) {},
    headerAnimationLoop: false,
    animType: AnimType.bottomSlide,
    title: MyStrings.exitTitle.tr,
    titleTextStyle: regularLarge.copyWith(
        color: MyColor.getBlackColor(), fontWeight: FontWeight.w600),
    showCloseIcon: false,
    btnCancel: GestureDetector(
        onTap: () {
          SystemNavigator.pop();
        },
        child: CustomGradiantButton(
          text: MyStrings.no.tr,
          hasBorder: true,
          textColor: MyColor.buttonColor,
          padding: 12,
        )),
    btnOk: GestureDetector(
        onTap: () {
          SystemNavigator.pop();
        },
        child: CustomGradiantButton(text: MyStrings.yes.tr)),
    btnCancelOnPress: () {},
    btnOkOnPress: () {
      SystemNavigator.pop();
    },
  ).show();
}
