

import 'package:flutter/material.dart';

import '../../../utils/my_color.dart';
import '../../../utils/style.dart';

class MyAppbarTheme{

  static AppBarTheme get lightAppbarTheme =>  AppBarTheme(
    backgroundColor: MyColor.getPrimaryColor(),
    elevation: 0,
    titleTextStyle: regularLarge.copyWith(color: MyColor.getWhiteColor()),
    iconTheme:  IconThemeData(
      size: 20,
      color: MyColor.getWhiteColor()
    )
  );

  static AppBarTheme get darkAppbarTheme =>  AppBarTheme(
      backgroundColor: MyColor.primaryColor,
      elevation: 0,
      titleTextStyle: regularLarge.copyWith(color: MyColor.getWhiteColor()),
      iconTheme:  IconThemeData(
          size: 20,
          color: MyColor.getWhiteColor()
      )
  );

}