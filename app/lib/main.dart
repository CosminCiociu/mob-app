import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ovo_meet/core/theme/dark/dark.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/data/controller/common/theme_controller.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/messages.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/data/controller/localization/localization_controller.dart';
import 'core/di_service/di_services.dart' as di_service;
import 'core/theme/light/light.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, Map<String, String>> languages = await di_service.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: MyColor.buttonColor,
    systemNavigationBarColor: MyColor.buttonColor,
  ));
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp(languages: languages));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>> languages;
  const MyApp({super.key, required this.languages});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (localizeController) => GetBuilder<ThemeController>(
        builder: (themeController) {
          return GetMaterialApp(
            title: MyStrings.appName,
            debugShowCheckedModeBanner: false,
            defaultTransition: Transition.noTransition,
            transitionDuration: const Duration(milliseconds: 200),
            initialRoute: RouteHelper.splashScreen,
            theme: lightThemeData,
            darkTheme: darkThemeData,
            themeMode:
                themeController.darkTheme ? ThemeMode.dark : ThemeMode.light,
            navigatorKey: Get.key,
            getPages: RouteHelper().routes,
            locale: localizeController.locale,
            translations: Messages(languages: widget.languages),
            fallbackLocale: Locale(localizeController.locale.languageCode,
                localizeController.locale.countryCode),
          );
        },
      ),
    );
  }
}
