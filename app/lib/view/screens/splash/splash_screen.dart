import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/util.dart';
import 'package:ovo_meet/data/controller/localization/localization_controller.dart';
import 'package:ovo_meet/data/controller/splash/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    MyUtils.splashScreen();

    Get.put(LocalizationController(sharedPreferences: Get.find()));
    final controller = Get.put(SplashController());

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.gotoNextPage();
    });
  }

  @override
  void dispose() {
    MyUtils.allScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<SplashController>(
        builder: (controller) => Scaffold(
          backgroundColor: controller.noInternet
              ? MyColor.getWhiteColor()
              : MyColor.getPrimaryColor(),
          body: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(MyImages.appLogo2, height: 200, width: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
