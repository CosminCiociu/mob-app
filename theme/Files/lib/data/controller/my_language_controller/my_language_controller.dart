
import 'package:ovo_meet/data/model/language/language_model.dart';

import 'package:get/get.dart';

class MyLanguageController extends GetxController {

  bool isLoading = true;
  String languageImagePath = "";
  List<MyLanguageModel> langList = [];



  String selectedLangCode = 'en';

  bool isChangeLangLoading = false;


  int selectedIndex = 0;
  void changeSelectedIndex(int index) {
    selectedIndex = index;
    update();
  }
}
