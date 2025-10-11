import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';

class HeaderText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextStyle textStyle;

  const HeaderText(
      {super.key,
      required this.text,
      this.textAlign,
      this.textStyle = semiBoldOverLarge});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr,
      textAlign: textAlign,
      style: textStyle.copyWith(color: MyColor.getHeadingTextColor()),
    );
  }
}
