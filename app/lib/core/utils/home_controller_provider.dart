import 'package:get/get.dart';
import '../../data/controller/home/home_controller.dart';

/// Singleton accessor for HomeController from anywhere in the app.
class HomeControllerProvider {
  static HomeController? _instance;

  static HomeController? get instance {
    _instance ??=
        Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
    return _instance;
  }
}
