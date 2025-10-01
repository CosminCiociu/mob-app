import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/view/components/divider/custom_divider.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:get/get.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: context.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF76F96),
              Color(0xFFF66D95),
              Color(0xFFEB507E),
              Color(0xFFE64375),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.space100),
                Image.asset(
                  MyImages.appLogo2,
                  height: Dimensions.space30,
                ),
                const SizedBox(height: Dimensions.space40),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: Dimensions.space17),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.profileScreen);
                    },
                    child: Row(children: [
                      const CustomSvgPicture(
                        image: MyImages.userFilledSvg,
                        color: MyColor.colorWhite,
                      ),
                      const SizedBox(width: Dimensions.space10),
                      Text(
                        MyStrings.myProfile,
                        style: regularMediumLarge.copyWith(
                            color: MyColor.colorWhite),
                      )
                    ]),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: Dimensions.space17),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.notificationScreen);
                    },
                    child: Row(children: [
                      const CustomSvgPicture(
                        image: MyImages.notificationFilledSvg,
                        color: MyColor.colorWhite,
                      ),
                      const SizedBox(width: Dimensions.space10),
                      Text(
                        MyStrings.notifications,
                        style: regularMediumLarge.copyWith(
                            color: MyColor.colorWhite),
                      )
                    ]),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: Dimensions.space17),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.myFavouriteScreen);
                    },
                    child: Row(children: [
                      const CustomSvgPicture(
                        image: MyImages.heart,
                        color: MyColor.colorWhite,
                      ),
                      const SizedBox(width: Dimensions.space10),
                      Text(
                        MyStrings.myFavourites,
                        style: regularMediumLarge.copyWith(
                            color: MyColor.colorWhite),
                      )
                    ]),
                  ),
                ),
                const CustomDivider(color: MyColor.colorWhite, thickness: 2),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: Dimensions.space10),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.privacyScreen);
                    },
                    child: Text(
                      MyStrings.privacyPolicy,
                      style: regularMediumLarge.copyWith(
                          color: MyColor.colorWhite),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: Dimensions.space10),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.termsAndConditionsScreen);
                    },
                    child: Text(
                      MyStrings.termsAndConditions,
                      style: regularMediumLarge.copyWith(
                          color: MyColor.colorWhite),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
