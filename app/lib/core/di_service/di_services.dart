import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ovo_meet/data/controller/common/theme_controller.dart';
import 'package:ovo_meet/data/controller/localization/localization_controller.dart';

Future<Map<String, Map<String, String>>> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  Get.lazyPut(() => sharedPreferences, fenix: true);
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()));
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()));

  Map<String, Map<String, String>> language = {};
  language['en_US'] = {'': ''};

  return language;
}
