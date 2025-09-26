import 'package:ovo_meet/core/route/route.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  bool isLoading = true;

  bool noInternet = false;

  gotoNextPage() {
    Future.delayed(Duration(milliseconds: 800), () {
      Get.toNamed(RouteHelper.onboardScreen);
    });
  }
}
