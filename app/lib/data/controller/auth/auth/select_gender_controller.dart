import 'package:get/get.dart';

class SelectGenderController extends GetxController {
  bool isMen = true;

  changeStatus() {
    isMen = !isMen;
    update();
  }
}
