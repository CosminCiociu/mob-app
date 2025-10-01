import 'package:flutter/material.dart';
import 'package:ovo_meet/data/controller/auth/social_login_controller.dart';
import 'package:get/get.dart';

// Removed unused import: '../../../../../core/utils/my_color.dart'
import '../../../../../core/utils/my_images.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../components/buttons/custom_outlined_button.dart';

class SocialLoginSection extends StatefulWidget {
  const SocialLoginSection({super.key});

  @override
  State<SocialLoginSection> createState() => _SocialLoginSectionState();
}

class _SocialLoginSectionState extends State<SocialLoginSection> {
  @override
  void initState() {
    Get.put(SocialLoginController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SocialLoginController>(builder: (controller) {
      return Visibility(
        visible: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const SizedBox(height: 30),
            CustomOutlinedBtn(
              btnText: MyStrings.signInWithGoogle.tr,
              onTap: () {
                controller.isGoogleSignInLoading = true;
                controller.signInWithGoogle().then((user) {
                  controller.isGoogleSignInLoading = false;
                  if (user != null) {
                    Get.offAllNamed('/bottom_nav_bar');
                    // Handle successful sign-in (e.g., navigate to home screen)
                  } else {
                    print("❌ Google sign-in failed or was canceled by user.");
                    // Handle sign-in failure or cancellation
                  }
                }).catchError((error) {
                  controller.isGoogleSignInLoading = false;
                  print("❌ Google sign-in error: $error");
                  // Handle error during sign-in
                });
              },
              bgColor: Colors.white,
              isLoading: controller.isGoogleSignInLoading,
              textColor: Colors.black87,
              radius: 14,
              height: 55,
              icon: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: Image.asset(
                  MyImages.google,
                  height: 26,
                  width: 26,
                ),
              ),
              borderColor:
                  Colors.grey[400]!, // Changed to a more visible border
              borderWidth: 2, // Add this line for thicker border
            ),
            const SizedBox(height: 18),
            CustomOutlinedBtn(
              btnText: MyStrings.signInWithFacebook.tr,
              bgColor: const Color(0xFF1877F3),
              onTap: () {},
              textColor: Colors.white,
              radius: 14,
              height: 55,
              icon: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: Image.asset(
                  MyImages.facebook,
                  height: 26,
                  width: 26,
                ),
              ),
              borderColor: Colors.blue[900]!, // Add a visible border color
              borderWidth: 2, // Add this line for thicker border
            ),
            const SizedBox(height: 100),
          ],
        ),
      );
    });
  }
}
