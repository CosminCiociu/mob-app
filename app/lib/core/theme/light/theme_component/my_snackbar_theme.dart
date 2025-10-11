import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class MySnackBarTheme {
  static SnackBarThemeData get lightSnackbarThemeData => SnackBarThemeData(
        behavior: SnackBarBehavior.floating, // Ensure visibility over content
        backgroundColor: MyColor.getWhiteColor(),
        contentTextStyle: TextStyle(color: MyColor.getTextColor()),
      );

  static SnackBarThemeData get darkSnackbarThemeData => SnackBarThemeData(
        behavior: SnackBarBehavior.floating, // Ensure visibility over content
        backgroundColor: MyColor.getWhiteColor(),
        contentTextStyle: TextStyle(color: MyColor.getTextColor()),
      );
}
