import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/theme/light/theme_component/button_theme.dart';
// import 'package:ovo_meet/core/theme/light/theme_component/my_appbar_theme.dart';
import '../../utils/my_color.dart';

ThemeData lightThemeData = ThemeData.light().copyWith(
  primaryColor: MyColor.getPrimaryColor(),
  primaryColorDark: MyColor.getPrimaryColor(),
  secondaryHeaderColor: Colors.yellow,

  // Define the default brightness and colors.
  scaffoldBackgroundColor: MyColor.getWhiteColor(),
  appBarTheme: AppBarTheme(color: MyColor.getWhiteColor(), foregroundColor: MyColor.lPrimaryTextColor),
  colorScheme: ColorScheme.fromSeed(
    seedColor: MyColor.primaryColor,
    brightness: Brightness.light,
  ),
  drawerTheme:  DrawerThemeData(
    backgroundColor: MyColor.getWhiteColor(),
    surfaceTintColor: MyColor.getTransparentColor(),
  ),
  cardColor: MyColor.lCardColor,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: 'Inter', fontSize: 57, fontWeight: FontWeight.bold, color: MyColor.lPrimaryTextColor),
    displaySmall: TextStyle(fontFamily: 'Inter', fontSize: 45, fontWeight: FontWeight.normal, color: MyColor.lPrimaryTextColor),
    bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: MyColor.lPrimaryTextColor),
    bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.normal, color: MyColor.lPrimaryTextColor),
    bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.normal, color: MyColor.lPrimaryTextColor),
    displayMedium: TextStyle(fontFamily: 'Inter', fontSize: 41, fontWeight: FontWeight.normal, color: MyColor.lPrimaryTextColor),
    headlineLarge: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w600, color: MyColor.lPrimaryTextColor),
    headlineMedium: TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w500, color: MyColor.lPrimaryTextColor),
    headlineSmall: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w500, color: MyColor.lPrimaryTextColor),
    labelMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: MyColor.lPrimaryTextColor),
    labelSmall: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, color: MyColor.lPrimaryTextColor),
    labelLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500, color: MyColor.lPrimaryTextColor),
    titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: MyColor.lPrimaryTextColor),
    titleMedium: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400, color: MyColor.dSecondaryTextColor),
    titleSmall: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: MyColor.dSecondaryTextColor),
  ),
  textSelectionTheme:  TextSelectionThemeData(
    cursorColor: MyColor.getPrimaryColor(),
    selectionColor: MyColor.getPrimaryColor(),
    selectionHandleColor: MyColor.getPrimaryColor(),
  ),
  bannerTheme: MaterialBannerThemeData(
    backgroundColor: MyColor.getPrimaryColor().withOpacity(.1),
  ),

  //Bottom Navbar
  bottomNavigationBarTheme:  BottomNavigationBarThemeData(
    backgroundColor: MyColor.getWhiteColor(),
    // Selected item color
    selectedItemColor: MyColor.getPrimaryColor(),
    // Unselected item color
    unselectedItemColor: MyColor.lPrimaryTextColor,
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: MyColor.colorWhite,
  ),
  datePickerTheme: DatePickerThemeData(
    headerHelpStyle: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: MyColor.lPrimaryTextColor),
    dayStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: MyColor.dSecondaryTextColor),
    weekdayStyle: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400, color: MyColor.getPrimaryColor()),
  ),
  timePickerTheme: TimePickerThemeData(dialTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: MyColor.dSecondaryTextColor), helpTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400, color: MyColor.getPrimaryColor())),
  //Text Filed
  inputDecorationTheme: const InputDecorationTheme(),
);
