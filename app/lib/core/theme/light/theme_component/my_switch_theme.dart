

import 'package:flutter/material.dart';

class MySwitchTheme {

  static SwitchThemeData get lightSwitchThemeData => SwitchThemeData(
    thumbColor: MaterialStateProperty.all(Colors.blue),
    trackColor: MaterialStateProperty.all(Colors.grey),
  );

  static SwitchThemeData get darkSnackbarThemeData => SwitchThemeData(
    thumbColor: MaterialStateProperty.all(Colors.blue),
    trackColor: MaterialStateProperty.all(Colors.grey),
  );

}