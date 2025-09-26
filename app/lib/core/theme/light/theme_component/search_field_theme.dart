

import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class MySearchFieldTheme{


  static SearchBarThemeData get lightSearchbarThemeData => const SearchBarThemeData(

  );

  static SearchBarThemeData get darkSearchbarThemeData => const SearchBarThemeData(

  );

  static SearchViewThemeData get lightSearchViewTheme => SearchViewThemeData(
    backgroundColor: MyColor.getTextFieldFillColor(),
  );

  static SearchViewThemeData get darkSearchViewTheme => SearchViewThemeData(
    backgroundColor: MyColor.getTextFieldFillColor(),
  );

}