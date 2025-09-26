import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/auth/auth/verification_code_controller.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:ovo_meet/view/components/otp_field_widget/otp_field_widget.dart';
import 'package:get/get.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  @override
  void initState() {
    final controller = Get.put(VerificationCodeController());

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.startTimer();
      controller.fromloginScreen = Get.arguments[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "",
      ),
      body: GetBuilder<VerificationCodeController>(
        builder: (controller) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.defaultScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.space20),
              Text(
                MyStrings.enterVerificationCode,
                style: boldOverLarge.copyWith(fontSize: Dimensions.space20),
              ),
              const SizedBox(height: Dimensions.space10),
              Text(
                MyStrings.pleaseEnterYourPhoneNumbertoContinue,
                style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
              ),
              const SizedBox(height: Dimensions.space20),
              OTPFieldWidget(
                onChanged: (value) {},
              ),
              const SizedBox(height: Dimensions.space30),
              InkWell(
                  onTap: () {
                    controller.fromloginScreen?Get.toNamed(RouteHelper.twoFactorScreen):
                    Get.toNamed(RouteHelper.addProfileDetailsScreen);
                  },
                  child: const CustomGradiantButton(text: MyStrings.verify)),
              const SizedBox(height: Dimensions.space30),
              controller.resendCode
                  ? Align(
                      alignment: Alignment.center,
                      child: Text(
                        MyStrings.resendCode,
                        style: regularDefault.copyWith(color: MyColor.buttonColor),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          MyStrings.resendIn,
                          style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                        ),
                        const SizedBox(width: Dimensions.space5),
                        Text(
                          "${controller.seconds}:00",
                          style: regularDefault.copyWith(color: MyColor.buttonColor),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
