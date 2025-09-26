import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';

class LabelText extends StatelessWidget {
  final bool isRequired;
  final String text;
  final TextAlign? textAlign;
  final TextStyle? textStyle;

  const LabelText({
    super.key,
    required this.text,
    this.textAlign,
    this.textStyle,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return isRequired
        ? Row(
            children: [
              Text(text.tr, textAlign: textAlign, style: textStyle ?? regularDefault.copyWith(color: MyColor.getLabelTextColor())),
              const SizedBox(
                width: 2,
              ),
              Text(
                '*',
                style: semiBoldDefault.copyWith(color: MyColor.getRedColor()),
              )
            ],
          )
        : Text(
            text.tr, 
            textAlign: textAlign,
            style: textStyle ?? semiBoldDefault.copyWith(color: MyColor.getBlackColor()),
          );
  }
}
