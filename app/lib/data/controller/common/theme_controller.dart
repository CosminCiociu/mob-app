import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ovo_meet/core/helper/shared_preference_helper.dart';
import '../../../core/theme/dark/dark.dart';
import '../../../core/theme/light/light.dart';

class ThemeController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  ThemeController({required this.sharedPreferences}) {
    _loadCurrentTheme();
  }

  void _loadCurrentTheme() {
    _darkTheme = sharedPreferences.getBool(SharedPreferenceHelper.theme) ?? false;
    update();
  }

  void changeTheme() {
    _darkTheme = !_darkTheme;
    sharedPreferences.setBool(SharedPreferenceHelper.theme, _darkTheme);
    if (_darkTheme) {
      _themeMode = ThemeMode.dark;
      Get.changeTheme(darkThemeData);
    } else {
      _themeMode = ThemeMode.dark;
      Get.changeTheme(lightThemeData);
    }

    update();
  }

  // initializing with the current theme of the device
  Rx<ThemeMode> currentTheme = ThemeMode.system.obs;

  // function to switch between themes
  void switchTheme() {
    currentTheme.value = currentTheme.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
