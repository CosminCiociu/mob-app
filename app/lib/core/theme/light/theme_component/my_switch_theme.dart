import 'package:flutter/material.dart';

class MySwitchTheme {
  static SwitchThemeData get lightSwitchThemeData => SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.blue),
        trackColor: WidgetStateProperty.all(Colors.grey),
      );

  static SwitchThemeData get darkSnackbarThemeData => SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.blue),
        trackColor: WidgetStateProperty.all(Colors.grey),
      );
}
