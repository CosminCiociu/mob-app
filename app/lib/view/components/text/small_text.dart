import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/style.dart';

class SmallText extends StatelessWidget {

  final String text;
  final TextAlign? textAlign;
  final TextStyle textStyle;
  final int maxLine;
  final Color textColor;

  const SmallText({
    super.key,
    required this.text,
    this.textAlign,
    this.maxLine = 1,
    this.textColor = MyColor.hintTextColor,
    this.textStyle = regularSmall
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr,
      textAlign: textAlign,
      style: textStyle,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
    );
  }
}
