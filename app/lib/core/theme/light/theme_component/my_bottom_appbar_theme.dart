import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class MyBottomAppbarTheme {
  static BottomAppBarTheme get lightBottomAppbarTheme => BottomAppBarTheme(
        color: MyColor.getBottomNavBgColor(),
        height: 90,
        surfaceTintColor: MyColor.getSurfaceTintColor(),
      );

  static BottomAppBarTheme get darkBottomAppbarTheme => BottomAppBarTheme(
        color: MyColor.getBottomNavBgColor(),
        height: 90,
        surfaceTintColor: MyColor.getSurfaceTintColor(),
      );
}
