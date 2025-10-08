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
import 'core/config/dependency_injection.dart';
import 'core/theme/light/light.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Only initialize if not already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  } else {}

  // Initialize services and repositories
  DependencyInjection.init();

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
            initialRoute: RouteHelper.loginScreen,
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
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

/// AuthGate widget controls navigation based on the user's authentication state.
/// Shows a loading indicator while checking, then navigates to HomePage or LoginPage.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Waiting for authentication...");
          return Center(child: CircularProgressIndicator()); // or splash screen
        } else if (snapshot.hasData) {
          print("User is authenticated: ${snapshot.data?.email}");
          if (RouteHelper().routes.isNotEmpty) {
            Future.microtask(() => Get.offAllNamed(RouteHelper.bottomNavBar));
          }
          return Center(child: CircularProgressIndicator());
        } else {
          print("User is not authenticated.");
          if (RouteHelper().routes.isNotEmpty) {
            Future.microtask(() => Get.offAllNamed(RouteHelper.loginScreen));
          }
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
