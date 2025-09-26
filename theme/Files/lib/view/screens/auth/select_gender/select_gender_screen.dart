import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/auth/auth/select_gender_controller.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:get/get.dart';

class SelectGenderScreen extends StatefulWidget {
  const SelectGenderScreen({super.key});

  @override
  State<SelectGenderScreen> createState() => _SelectGenderScreenState();
}

class _SelectGenderScreenState extends State<SelectGenderScreen> {
  @override
  void initState() {
    Get.put(SelectGenderController());

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ""),
      body: GetBuilder<SelectGenderController>(
        builder: (controller) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.defaultScreenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MyStrings.selectGender,
                  style: boldOverLarge.copyWith(fontSize: Dimensions.space20),
                ),
                const SizedBox(height: Dimensions.space10),
                Text(
                  MyStrings.pleaseSelectYourGender,
                  style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                ),
                const SizedBox(height: Dimensions.space100),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      controller.changeStatus();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.space35),
                      height: Dimensions.space150,
                      decoration: BoxDecoration(border: Border.all(color: controller.isMen ? MyColor.buttonColor : MyColor.greyColor.withOpacity(.4)), borderRadius: BorderRadius.circular(Dimensions.space12), color: controller.isMen ? MyColor.primaryColor : MyColor.transparentColor ),
                      child: Image.asset(
                        MyImages.men,
                        color: controller.isMen ? MyColor.buttonColor : MyColor.colorBlack,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.space25),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      controller.changeStatus();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.space30),
                      height: Dimensions.space150,
                      decoration: BoxDecoration(
                        border: Border.all(color: controller.isMen ? MyColor.greyColor.withOpacity(.4) : MyColor.buttonColor,), borderRadius: BorderRadius.circular(Dimensions.space12), color: controller.isMen ? MyColor.transparentColor : MyColor.primaryColor),
                      child: Image.asset(
                        MyImages.women,
                        color: controller.isMen ? MyColor.colorBlack : MyColor.buttonColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.space100),
                InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.selectIntersetScreen);
                    },
                    child: const CustomGradiantButton(text: MyStrings.continues)),
                   const SizedBox(height: Dimensions.space50)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
