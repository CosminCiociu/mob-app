import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/core/utils/url_container.dart';
import 'package:ovo_meet/data/controller/account/profile_complete_controller.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:ovo_meet/view/components/image/my_image_widget.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:ovo_meet/view/screens/auth/profile_complete/widget/country_bottom_sheet.dart';
import 'package:get/get.dart';

class EnterPhoneNumberRegistrationScreen extends StatefulWidget {
  const EnterPhoneNumberRegistrationScreen({super.key});

  @override
  State<EnterPhoneNumberRegistrationScreen> createState() => _EnterPhoneNumberRegistrationScreenState();
}

class _EnterPhoneNumberRegistrationScreenState extends State<EnterPhoneNumberRegistrationScreen> {
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
                MyStrings.enterPhoneNumber,
                style: boldOverLarge.copyWith(fontSize: Dimensions.space20),
              ),
              const SizedBox(height: Dimensions.space10),
              Text(
                MyStrings.pleaseEnterYourPhoneNumbertoContinue,
                style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
              ),
             const SizedBox(height: Dimensions.space20),
              LabelTextField(
                onChanged: (v) {},
                labelText: "",
                hideLabel: true,
                hintText: MyStrings.enterYourPhoneNumber,
                controller: controller.mobileNoController,
                focusNode: controller.mobileNoFocusNode,
                textInputType: TextInputType.phone,
                inputAction: TextInputAction.next,
                prefixIcon: SizedBox(
                  width: Dimensions.space100,
                  child: FittedBox(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            CountryBottomSheet.profileCompleteCountryBottomSheet(context, controller);
                          },
                          child: Container(
                            padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space12),
                            decoration: BoxDecoration(
                              color: MyColor.getTransparentColor(),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                MyImageWidget(
                                  imageUrl: UrlContainer.countryFlagImageLink.replaceAll('{countryCode}', controller.countryCode.toString().toLowerCase()),
                                  height: Dimensions.space25,
                                  width: Dimensions.space40 + Dimensions.space2,
                                ),
                                const SizedBox(width: Dimensions.space5),
                                Text(controller.mobileCode ?? ''),
                                const SizedBox(width: Dimensions.space3),
                                Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: MyColor.getIconColor(),
                                ),
                                Container(
                                  width: .6,
                                  height: Dimensions.space50,
                                  color: MyColor.buttonColor,
                                ),
                                const SizedBox(width: Dimensions.space8)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
             const SizedBox(height: Dimensions.space20),
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
                    Get.toNamed(RouteHelper.verificationCodeScreen,arguments: [true]);
                  },
                  child:const CustomGradiantButton(text: MyStrings.continues)),
            ],
          ),
        ),
      ),
    );
  }
}
