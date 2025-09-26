import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/auth/login_controller.dart';
import 'package:ovo_meet/data/controller/auth/social_login_controller.dart';

import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:ovo_meet/view/components/will_pop_widget.dart';
import 'package:ovo_meet/view/screens/auth/login/widget/social_login_section.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Get.put(LoginController());

    Get.put(SocialLoginController());
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LoginController>().remember = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: '',
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Theme.of(context).primaryColor,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Theme.of(context).primaryColor,
          systemNavigationBarIconBrightness: Theme.of(context).brightness,
        ),
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          body: GetBuilder<LoginController>(
            builder: (controller) => SingleChildScrollView(
              padding: Dimensions.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * .15),
                  Image.asset(
                    MyImages.appLogo,
                    height: Dimensions.space100,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  Text(MyStrings.signUptoContinue,
                      style:
                          boldOverLarge.copyWith(fontSize: Dimensions.space25)),
                  Text(MyStrings.pleaseLogintoContinue,
                      style: regularDefault.copyWith(
                          color: MyColor.getGreyText())),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: Dimensions.space30),
                        InkWell(
                          onTap: () {
                            Get.toNamed(RouteHelper.enterEmailScreen);
                          },
                          child: const CustomGradiantButton(
                            text: MyStrings.continuewithEmail,
                          ),
                        ),
                        const SizedBox(height: Dimensions.space20),
                        InkWell(
                            onTap: () {
                              Get.toNamed(RouteHelper.enterPhNumberScreen);
                            },
                            child: const CustomGradiantButton(
                                text: MyStrings.continuewithPhone,
                                hasBorder: true,
                                textColor: MyColor.buttonColor)),
                        const SocialLoginSection(),
                        const SizedBox(height: 35),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions
                                  .space50), // Optional: for padding around the content
                          child: Wrap(
                            alignment:
                                WrapAlignment.center, // Center the content
                            spacing: 8.0, // Space between the text widgets
                            children: [
                              Text(
                                MyStrings.iAcceptAllthe.tr,
                                overflow: TextOverflow.ellipsis,
                                style: regularDefault.copyWith(
                                  color: MyColor.getSecondaryTextColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Get.toNamed(
                                      RouteHelper.termsAndConditionsScreen);
                                },
                                child: Text(
                                  MyStrings.termsAndConditions.tr,
                                  overflow: TextOverflow.ellipsis,
                                  style: regularDefault.copyWith(
                                    color: MyColor.buttonColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                "&",
                                overflow: TextOverflow.ellipsis,
                                style: regularDefault.copyWith(
                                  color: MyColor.getSecondaryTextColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(RouteHelper.privacyScreen);
                                },
                                child: Text(
                                  MyStrings.privacyPolicy.tr,
                                  overflow: TextOverflow.ellipsis,
                                  style: regularDefault.copyWith(
                                    color: MyColor.buttonColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
