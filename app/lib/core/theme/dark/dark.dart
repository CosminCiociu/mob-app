import 'package:flutter/material.dart';

import '../../utils/my_color.dart';
import '../../utils/style.dart';

ThemeData darkThemeData = ThemeData.dark().copyWith(
  primaryColor: MyColor.getPrimaryColor(),
  primaryColorDark: MyColor.getPrimaryColor(),
  secondaryHeaderColor: Colors.yellow,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: MyColor.dBackgroundColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: MyColor.getPrimaryColor(),
    brightness: Brightness.dark,
  ),
  appBarTheme: AppBarTheme(color: MyColor.dBackgroundColor, foregroundColor: MyColor.dPrimaryTextColor),
  drawerTheme: const DrawerThemeData(
    backgroundColor: MyColor.dBackgroundColor,
    surfaceTintColor: MyColor.transparentColor,
  ),
  cardColor: MyColor.dCardColor,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: 'Inter', fontSize: 57, fontWeight: FontWeight.bold, color: MyColor.dPrimaryTextColor),
    displaySmall: TextStyle(fontFamily: 'Inter', fontSize: 45, fontWeight: FontWeight.normal, color: MyColor.dPrimaryTextColor),
    bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: MyColor.dPrimaryTextColor),
    bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.normal, color: MyColor.dPrimaryTextColor),
    bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.normal, color: MyColor.dPrimaryTextColor),
    displayMedium: TextStyle(fontFamily: 'Inter', fontSize: 41, fontWeight: FontWeight.normal, color: MyColor.dPrimaryTextColor),
    headlineLarge: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w600, color: MyColor.dPrimaryTextColor),
    headlineMedium: TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w500, color: MyColor.dPrimaryTextColor),
    headlineSmall: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w500, color: MyColor.dPrimaryTextColor),
    labelMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: MyColor.dPrimaryTextColor),
    labelSmall: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, color: MyColor.dPrimaryTextColor),
    labelLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500, color: MyColor.dPrimaryTextColor),
    titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: MyColor.dPrimaryTextColor),
    titleMedium: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400, color: MyColor.dSecondaryTextColor),
    titleSmall: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: MyColor.dSecondaryTextColor),
  ),

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: MyColor.primaryColor,
    selectionColor: MyColor.primaryColor,
    selectionHandleColor: MyColor.primaryColor,
  ),
  bannerTheme: MaterialBannerThemeData(
    backgroundColor: MyColor.getWhiteColor(),
  ),
  //Bottom Navbar
  bottomNavigationBarTheme:  BottomNavigationBarThemeData(
    backgroundColor: MyColor.dBackgroundColor,
    // Selected item color
    selectedItemColor: MyColor.getPrimaryColor(),
    // Unselected item color
    unselectedItemColor: MyColor.dPrimaryTextColor,
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: MyColor.dBackgroundColor,
  ),
  //Text Filed
  inputDecorationTheme: const InputDecorationTheme(),
);
