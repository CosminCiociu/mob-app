import 'package:flutter/cupertino.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class MyCupertinoTheme {
  static CupertinoThemeData get lightCupertinoTheme => CupertinoThemeData(
      primaryColor: MyColor.getPrimaryColor(),
      scaffoldBackgroundColor: MyColor.getScreenBgColor(),
      brightness: Brightness.light);

  static CupertinoThemeData get darkCupertinoTheme => CupertinoThemeData(
      primaryColor: MyColor.getPrimaryColor(),
      scaffoldBackgroundColor: MyColor.getScreenBgColor(),
      brightness: Brightness.light);
}
