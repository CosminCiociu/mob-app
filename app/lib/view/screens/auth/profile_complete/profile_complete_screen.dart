import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/data/controller/account/profile_complete_controller.dart';

import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/buttons/custom_elevated_button.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:ovo_meet/view/components/will_pop_widget.dart';
import 'package:ovo_meet/view/screens/auth/profile_complete/widget/country_bottom_sheet.dart';
import 'package:get/get.dart';
import '../../../../core/utils/url_container.dart';
import '../../../components/image/my_image_widget.dart';

class ProfileCompleteScreen extends StatefulWidget {
  const ProfileCompleteScreen({super.key});

  @override
  State<ProfileCompleteScreen> createState() => _ProfileCompleteScreenState();
}

class _ProfileCompleteScreenState extends State<ProfileCompleteScreen> {
  @override
  void initState() {
    final controller = Get.put(ProfileCompleteController());

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: '',
      child: Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: CustomAppBar(
          title: MyStrings.profileComplete.tr,
          isShowBackBtn: true,
          fromAuth: false,
          isProfileCompleted: true,
          bgColor: MyColor.getAppBarColor(),
        ),
        body: GetBuilder<ProfileCompleteController>(
          builder: (controller) => RefreshIndicator(
            onRefresh: () async {
              controller.initData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: Dimensions.screenPadding,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimensions.space15),
                    LabelTextField(
                      isRequired: true,
                      labelText: MyStrings.username.tr,
                      hintText: "",
                      textInputType: TextInputType.text,
                      inputAction: TextInputAction.next,
                      focusNode: controller.usernameFocusNode,
                      controller: controller.usernameController,
                      nextFocus: controller.mobileNoFocusNode,
                      onChanged: (value) {
                        return;
                      },
                    ),
                    const SizedBox(height: Dimensions.space25),
                    LabelTextField(
                      onChanged: (v) {},
                      labelText: (MyStrings.phoneNo).replaceAll('.', '').tr,
                      hintText: MyStrings.enterYourPhoneNumber,
                      controller: controller.mobileNoController,
                      focusNode: controller.mobileNoFocusNode,
                      textInputType: TextInputType.phone,
                      inputAction: TextInputAction.next,
                      prefixIcon: SizedBox(
                        width: 100,
                        child: FittedBox(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  CountryBottomSheet
                                      .profileCompleteCountryBottomSheet(
                                          context, controller);
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                          horizontal: Dimensions.space12),
                                  decoration: BoxDecoration(
                                    color: MyColor.getTransparentColor(),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      MyImageWidget(
                                        imageUrl: UrlContainer
                                            .countryFlagImageLink
                                            .replaceAll(
                                                '{countryCode}',
                                                controller.countryCode
                                                    .toString()
                                                    .toLowerCase()),
                                        height: Dimensions.space25,
                                        width: Dimensions.space40 + 2,
                                      ),
                                      const SizedBox(width: Dimensions.space5),
                                      Text(controller.mobileCode ?? ''),
                                      const SizedBox(width: Dimensions.space3),
                                      Icon(
                                        Icons.arrow_drop_down_rounded,
                                        color: MyColor.getIconColor(),
                                      ),
                                      Container(
                                        width: 2,
                                        height: Dimensions.space12,
                                        color: MyColor.getBorderColor(),
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
                    const SizedBox(height: Dimensions.space25),
                    LabelTextField(
                      labelText: MyStrings.address,
                      hintText: "",
                      textInputType: TextInputType.text,
                      inputAction: TextInputAction.next,
                      focusNode: controller.addressFocusNode,
                      controller: controller.addressController,
                      nextFocus: controller.stateFocusNode,
                      onChanged: (value) {
                        return;
                      },
                    ),
                    const SizedBox(height: Dimensions.space25),
                    LabelTextField(
                      labelText: MyStrings.state,
                      hintText: "",
                      textInputType: TextInputType.text,
                      inputAction: TextInputAction.next,
                      focusNode: controller.stateFocusNode,
                      controller: controller.stateController,
                      nextFocus: controller.cityFocusNode,
                      onChanged: (value) {
                        return;
                      },
                    ),
                    const SizedBox(height: Dimensions.space25),
                    LabelTextField(
                      labelText: MyStrings.city.tr,
                      hintText: "",
                      textInputType: TextInputType.text,
                      inputAction: TextInputAction.next,
                      focusNode: controller.cityFocusNode,
                      controller: controller.cityController,
                      nextFocus: controller.zipCodeFocusNode,
                      onChanged: (value) {
                        return;
                      },
                    ),
                    const SizedBox(height: Dimensions.space25),
                    LabelTextField(
                      labelText: MyStrings.zipCode.tr,
                      hintText: "",
                      textInputType: TextInputType.text,
                      inputAction: TextInputAction.next,
                      focusNode: controller.zipCodeFocusNode,
                      controller: controller.zipCodeController,
                      nextFocus: controller.ageFocusNode,
                      onChanged: (value) {
                        return;
                      },
                    ),
                    const SizedBox(height: Dimensions.space25),
                    LabelTextField(
                      labelText: MyStrings.enterYourAge.tr,
                      hintText: MyStrings.ageHint.tr,
                      textInputType: TextInputType.number,
                      inputAction: TextInputAction.done,
                      focusNode: controller.ageFocusNode,
                      controller: controller.ageController,
                      onChanged: (value) {
                        return;
                      },
                    ),
                    const SizedBox(height: Dimensions.space35),
                    CustomElevatedBtn(
                      isLoading: controller.submitLoading,
                      text: MyStrings.updateProfile.tr,
                      press: () {},
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
