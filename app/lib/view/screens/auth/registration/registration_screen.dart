import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/auth/auth/registration_controller.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/buttons/my_text_button.dart';
import 'package:ovo_meet/view/components/will_pop_widget.dart';
import 'package:ovo_meet/view/screens/auth/login/widget/social_login_section.dart';
import 'package:ovo_meet/view/screens/auth/registration/widget/registration_form.dart';
import 'package:get/get.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  void initState() {
    Get.put(RegistrationController());

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (controller) => WillPopWidget(
        nextRoute: RouteHelper.loginScreen,
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: const CustomAppBar(title: MyStrings.signUp, fromAuth: true),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.space30, horizontal: Dimensions.space15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * .01),
                Text(
                  MyStrings.signUP.tr,
                  style: boldMediumLarge.copyWith(),
                ),
                const SizedBox(height: Dimensions.space8),
                Text(MyStrings.startLearntingWithCreateAccount.tr,
                    style: lightDefault.copyWith(
                      color: MyColor.getBodyTextColor(),
                    )),
                SizedBox(height: MediaQuery.of(context).size.height * .03),
                const RegistrationForm(),
                const SocialLoginSection(),
                const SizedBox(height: Dimensions.space30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(MyStrings.alreadyAccount.tr,
                        style: regularLarge.copyWith(
                            color: MyColor.getTextColor(),
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: Dimensions.space5),
                    CustomTextButton(
                      press: () {
                        controller.clearAllData();
                        Get.offAndToNamed(RouteHelper.loginScreen);
                      },
                      text: MyStrings.signIn.tr,
                      style: regularLarge.copyWith(
                          color: MyColor.getPrimaryColor()),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
