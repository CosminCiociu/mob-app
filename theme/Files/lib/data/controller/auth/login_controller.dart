import 'package:get/get.dart';

class LoginController extends GetxController {
  String? email;
  String? password;

  List<String> errors = [];
  bool remember = false;

  bool isSubmitLoading = false;

  changeRememberMe() {
    remember = !remember;
    update();
  }

  bool isGoogleSignInLoading = false;
}
