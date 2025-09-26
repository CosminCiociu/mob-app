import 'package:flutter/material.dart';
import 'package:ovo_meet/view/components/buttons/custom_elevated_button.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/auth/auth/email_verification_controler.dart';

import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/text/small_text.dart';
import 'package:ovo_meet/view/components/will_pop_widget.dart';

import '../../../components/image/custom_svg_picture.dart';
import '../../../components/otp_field_widget/otp_field_widget.dart';

class EmailVerificationScreen extends StatefulWidget {

  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  @override
  void initState() {
    final controller = Get.put(EmailVerificationController());

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
 
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: RouteHelper.loginScreen,
      child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: CustomAppBar(fromAuth: true, title: MyStrings.emailVerification.tr, isShowBackBtn: true, isShowActionBtn: false, bgColor: MyColor.getAppBarColor()),
          body: GetBuilder<EmailVerificationController>(
            builder: (controller) => controller.isLoading
                ? Center(child: CircularProgressIndicator(color: MyColor.getPrimaryColor()))
                : SingleChildScrollView(
                    padding: Dimensions.screenPadding,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: Dimensions.space30),
                          Container(
                            height: 100,
                            width: 100,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: MyColor.getPrimaryColor().withOpacity(.075), shape: BoxShape.circle),
                            child: CustomSvgPicture(image: MyImages.emailVerifyImage, height: 50, width: 50, color: MyColor.getPrimaryColor()),
                          ),
                          const SizedBox(height: Dimensions.space50),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .07),
                            child: SmallText(text: MyStrings.viaEmailVerify.tr, maxLine: 3, textAlign: TextAlign.center, textStyle: regularDefault.copyWith(color: MyColor.getLabelTextColor())),
                          ),
                          const SizedBox(height: 30),
                          OTPFieldWidget(
                            onChanged: (value) {
                              controller.currentText = value;
                            },
                          ),
                          const SizedBox(height: Dimensions.space30),
                          CustomElevatedBtn(
                            isLoading: controller.submitLoading,
                            text: MyStrings.verify.tr,
                            press: () {
                            
                            },
                          ),
                          const SizedBox(height: Dimensions.space30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(MyStrings.didNotReceiveCode.tr, style: regularDefault.copyWith(color: MyColor.getLabelTextColor())),
                              const SizedBox(width: Dimensions.space10),
                              controller.resendLoading
                                  ? Container(margin: const EdgeInsets.only(left: 5, top: 5), height: 20, width: 20, child: CircularProgressIndicator(color: MyColor.getPrimaryColor()))
                                  : GestureDetector(
                                      onTap: () {
                                       
                                      },
                                      child: Text(MyStrings.resendCode.tr, style: regularDefault.copyWith(color: MyColor.getPrimaryColor(), decoration: TextDecoration.underline)),
                                    )
                            ],
                          )
                        ],
                      ),
                    )),
          )),
    );
  }
}
