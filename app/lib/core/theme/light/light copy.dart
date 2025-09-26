// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:ovo_meet/core/theme/light/theme_component/button_theme.dart';
// import 'package:ovo_meet/core/theme/light/theme_component/my_appbar_theme.dart';
// import '../../utils/my_color.dart';

// ThemeData light = ThemeData(
//   fontFamily: 'Inter',
//   primaryColor: MyColor.primaryColor,
//   brightness: Brightness.light,
//   scaffoldBackgroundColor: MyColor.colorGrey.withOpacity(0.3),
//   hintColor: MyColor.hintTextColor,
//   buttonTheme: MyButtonTheme.lightButtonTheme,
//   cardColor: MyColor.getCardBgColor(),
//   appBarTheme: MyAppbarTheme.lightAppbarTheme,


//   segmentedButtonTheme: MyButtonTheme.lightSegmentButtonTheme,

//   useMaterial3: true,
//   radioTheme: RadioThemeData(
//     fillColor: MaterialStateProperty.all(MyColor.primaryColor),
//   ),

//   dialogBackgroundColor: Colors.white,
//   disabledColor: Colors.grey,
//   highlightColor: Colors.lightBlueAccent,
//   hoverColor: Colors.blue[50],
//   typography: Typography.material2018(),

//   // Buttons
//   elevatedButtonTheme: MyButtonTheme.lightElevatedButtonTheme,
//   filledButtonTheme: MyButtonTheme.lightFilledButtonTheme,
//   outlinedButtonTheme: OutlinedButtonThemeData(
//     style: OutlinedButton.styleFrom(backgroundColor: Colors.blue),
//   ),

//   dialogTheme: const DialogTheme(
//     backgroundColor: Colors.white,
//     elevation: 24,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
//     titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//     contentTextStyle: TextStyle(fontSize: 16),
//   ),
//   dataTableTheme: const DataTableThemeData(
//     columnSpacing: 16.0, // Adjust spacing as needed
//   ),
//   datePickerTheme: const DatePickerThemeData(
//     dayStyle: TextStyle(
//       color: Colors.black,
//       fontSize: 16,
//     ),
//   ),
//   dividerTheme: const DividerThemeData(
//     color: MyColor.borderColor,
//     thickness: 1.0, // Adjust thickness as needed
//     indent: 20.0, // Adjust indent as needed
//   ),
//   drawerTheme: const DrawerThemeData(
//     backgroundColor: Colors.white,
//   ),
//   dropdownMenuTheme: const DropdownMenuThemeData(
//     textStyle: TextStyle(color: Colors.black), // Adjust based on your theme
//   ),
//   expansionTileTheme: ExpansionTileThemeData(
//     backgroundColor: MyColor.getCardBgColor(),
//     collapsedTextColor: Colors.black,
//     iconColor: Colors.black, // Adjust based on your theme
//   ),
//   listTileTheme: const ListTileThemeData(
//     iconColor: Colors.black, // Adjust based on your theme
//     textColor: Colors.black, // Adjust based on your theme
//   ),
//   menuBarTheme: const MenuBarThemeData(style: MenuStyle()),
//   menuButtonTheme: const MenuButtonThemeData(),
//   menuTheme: const MenuThemeData(),
//   navigationBarTheme: const NavigationBarThemeData(),
//   navigationRailTheme: const NavigationRailThemeData(),
//   progressIndicatorTheme: const ProgressIndicatorThemeData(),
//   buttonBarTheme: const ButtonBarThemeData(),
//   chipTheme: const ChipThemeData(),
//   cardTheme: CardTheme(
//     color: MyColor.getCardBgColor(),
//     surfaceTintColor: MyColor.getSplashColor(),
//   ),
//   materialTapTargetSize: MaterialTapTargetSize.padded,
//   pageTransitionsTheme: const PageTransitionsTheme(),
//   scrollbarTheme: const ScrollbarThemeData(),
//   dividerColor: Colors.grey,
//   focusColor: Colors.lightBlueAccent,
//   iconTheme: const IconThemeData(
//     color: MyColor.colorBlack,
//     size: 18,
//   ),
//   iconButtonTheme: const IconButtonThemeData(),
//   primaryIconTheme: const IconThemeData(color: Colors.blue),
//   primaryTextTheme: const TextTheme(),
//   textButtonTheme: const TextButtonThemeData(
//       // style: TextButton.styleFrom( : Colors.blue),
//       ),
//   textTheme: const TextTheme(
//     displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
//     displaySmall: TextStyle(fontSize: 45, fontWeight: FontWeight.normal),
//     bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//     bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
//     bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
//     displayMedium: TextStyle(fontSize: 41, fontWeight: FontWeight.normal),
//     headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
//     headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
//     headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
//     labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//     labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
//     labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//     titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//     titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//     titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//   ),
//   textSelectionTheme: const TextSelectionThemeData(
//     cursorColor: MyColor.primaryColor,
//     selectionColor: MyColor.primaryColor,
//     selectionHandleColor: MyColor.primaryColor,
//   ),
//   bannerTheme: MaterialBannerThemeData(
//     backgroundColor: MyColor.primaryColor.withOpacity(.1),
//   ),
//   bottomNavigationBarTheme: const BottomNavigationBarThemeData(),
//   timePickerTheme: const TimePickerThemeData(),
//   // toggleButtonsTheme: const ToggleButtonsThemeData(), colorScheme: ColorScheme.fromSeed(seedColor: MyColor.primaryColor).copyWith(primarySwatch: MyColor.buildMaterialColor(MyColor.primaryColor), error: Colors.red),
//   tooltipTheme: const TooltipThemeData(),
//   indicatorColor: Colors.blue,
//   inputDecorationTheme: const InputDecorationTheme(),
//   navigationDrawerTheme: const NavigationDrawerThemeData(),
//   popupMenuTheme: const PopupMenuThemeData(),
//   checkboxTheme: CheckboxThemeData(
//     checkColor: MaterialStateProperty.all(MyColor.colorBlack),
//     fillColor: MaterialStateProperty.all(MyColor.primaryColor),
//     overlayColor: MaterialStateProperty.all(MyColor.primaryColor),
//   ),
// );
