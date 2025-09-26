import 'package:get/get.dart';


class PrivacyController extends GetxController{


  int selectedIndex = 1;
  bool isLoading    = true;

  late var selectedHtml = '';




  void changeIndex(int index){

    selectedIndex = index;
    update();

  }

  updateLoading(bool status){
    isLoading=status;
    update();
  }
}