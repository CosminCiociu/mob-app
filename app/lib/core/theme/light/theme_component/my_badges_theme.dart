import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';

class MyBadgeTheme {
  static BadgeThemeData get lightBadgeTheme => BadgeThemeData(
      backgroundColor: MyColor.getPrimaryColor(),
      textColor: MyColor.getPrimaryColor(),
      textStyle: regularSmall);

  static BadgeThemeData get darkBadgeTheme => BadgeThemeData(
      backgroundColor: MyColor.getPrimaryColor(),
      textColor: MyColor.getPrimaryColor(),
      textStyle: regularSmall);
}
