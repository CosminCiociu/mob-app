
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class MySliderTheme{

  static SliderThemeData get lightSliderTheme => SliderThemeData(
    trackHeight: 2,  // Adjust track height for better visibility
    thumbColor: Colors.blue,
    activeTrackColor: MyColor.getPrimaryColor(),
    inactiveTrackColor: MyColor.getPrimaryColor().withOpacity(.9),
  );

  static SliderThemeData get darkSliderTheme => SliderThemeData(
    trackHeight: 2,
    thumbColor: Colors.blue,
    activeTrackColor: MyColor.getPrimaryColor(),
    inactiveTrackColor: MyColor.getPrimaryColor().withOpacity(.9),
  );

}