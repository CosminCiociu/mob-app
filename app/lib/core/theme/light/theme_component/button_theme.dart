import '../../../utils/my_color.dart';
import 'package:flutter/material.dart';

class MyButtonTheme {
  static ButtonThemeData get lightButtonTheme => ButtonThemeData(buttonColor: MyColor.getPrimaryColor(), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));

  static ButtonThemeData get darkButtonTheme => ButtonThemeData(buttonColor: MyColor.getPrimaryColor(), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));

  static SegmentedButtonThemeData get lightSegmentButtonTheme =>  SegmentedButtonThemeData(
          style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(MyColor.getPrimaryColor()),
      ));

  static SegmentedButtonThemeData get darkSegmentButtonTheme =>  SegmentedButtonThemeData(
          style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(MyColor.getPrimaryColor()),
      ));

  static ElevatedButtonThemeData get lightElevatedButtonTheme => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: MyColor.getPrimaryColor()),
      );

  static ElevatedButtonThemeData get darkElevatedButtonTheme => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: MyColor.getPrimaryColor()),
      );

  static FilledButtonThemeData get lightFilledButtonTheme =>  FilledButtonThemeData(
        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(MyColor.getPrimaryColor())),
      );

  static FilledButtonThemeData get darkFilledButtonTheme =>  FilledButtonThemeData(
        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(MyColor.getPrimaryColor())),
      );

  /*static FilledButtonThemeData get lightFilledButtonTheme =>  const FilledButtonThemeData(
    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(MyColor.getPrimaryColor())),
  );*/
}

class TestColor extends WidgetStateColor {
  TestColor(super.defaultValue);

  @override
  Color resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return Colors.blue[800]!;
    } else if (states.contains(WidgetState.hovered)) {
      return Colors.blue[700]!;
    } else {
      return Colors.blue[600]!;
    }
  }
}
