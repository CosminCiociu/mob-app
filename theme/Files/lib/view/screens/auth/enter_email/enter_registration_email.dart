import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/account/profile_complete_controller.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:get/get.dart';

class EnterRegistrationEmailScreen extends StatefulWidget {
  const EnterRegistrationEmailScreen({super.key});

  @override
  State<EnterRegistrationEmailScreen> createState() => _EnterRegistrationEmailScreenState();
}

class _EnterRegistrationEmailScreenState extends State<EnterRegistrationEmailScreen> {
  @override
  void initState() {
    final controller = Get.put(ProfileCompleteController());

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:const CustomAppBar(
        title: "",
      ),
      body: GetBuilder<ProfileCompleteController>(
        builder: (controller) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.defaultScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.space20),
              Text(
                MyStrings.enterEmail,
                style: boldOverLarge.copyWith(fontSize: Dimensions.space20),
              ),
              const SizedBox(height: Dimensions.space10),
              Text(
                MyStrings.pleaseEnterYourEmailtoContinue,
                style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
              ),
             const SizedBox(height: Dimensions.space20),
              LabelTextField(
                onChanged: (v) {},
                labelText: "",
                hideLabel: true,
                hintText: MyStrings.enterYourEmail,
                controller: controller.mobileNoController,
                focusNode: controller.mobileNoFocusNode,
                textInputType: TextInputType.phone,
                inputAction: TextInputAction.next,
              ),
             const SizedBox(height: Dimensions.space30),
              LabelTextField(
                onChanged: (v) {},
                labelText: "",
                hideLabel: true,
                hintText: MyStrings.password,
                isPassword: true,
                controller: controller.passwordController,
                focusNode: controller.mobileNoFocusNode,
                textInputType: TextInputType.phone,
                inputAction: TextInputAction.next,
              ),
             const SizedBox(height: Dimensions.space30),
              LabelTextField(
                onChanged: (v) {},
                labelText: "",
                hideLabel: true,
                hintText: MyStrings.confirmPassword,
                isPassword: true,
                controller: controller.passwordController,
                focusNode: controller.mobileNoFocusNode,
                textInputType: TextInputType.phone,
                inputAction: TextInputAction.next,
              ),
             const SizedBox(height: Dimensions.space30),
              InkWell(
                  onTap: () {
                    Get.toNamed(RouteHelper.verificationCodeScreen);
                  },
                  child:const CustomGradiantButton(text: MyStrings.continues))
            ],
          ),
        ),
      ),
    );
  }
}
