import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:ovo_meet/view/screens/profile/widget/pick_image_widgte.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/data/controller/account/profile_controller.dart';
import 'package:ovo_meet/view/components/column_widget/card_column.dart';
import 'package:ovo_meet/view/components/divider/custom_divider.dart';
import 'package:ovo_meet/view/components/image/circle_shape_image.dart';

class ProfileTopSection extends StatefulWidget {
  const ProfileTopSection({super.key});

  @override
  State<ProfileTopSection> createState() => _ProfileTopSectionState();
}

class _ProfileTopSectionState extends State<ProfileTopSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!Get.isRegistered<ProfileController>()) {
        Get.put(ProfileController());
      }
      Get.find<ProfileController>().fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) => Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(
            vertical: Dimensions.space15, horizontal: Dimensions.space15),
        decoration: BoxDecoration(
            color: MyColor.getCardBgColor(),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PickImageWidget(
              isEdit: true,
              imagePath: controller.imageUrl,
              onClicked: () async {},
            ),
            const SizedBox(height: Dimensions.space15),
            Align(
                alignment: Alignment.center,
                child: Text(controller.displayNameController.text,
                    style: boldMediumLarge)),
            Align(
                alignment: Alignment.center,
                child: Text(controller.emailController.text,
                    style: regularDefault.copyWith(
                        color: MyColor.getGreyText1()))),
            const SizedBox(height: Dimensions.space15),
            InkWell(
              onTap: () {
                Get.toNamed(RouteHelper.editProfileScreen);
              },
              child: Row(
                children: [
                  CircleShapeImage(
                    imageColor: MyColor.getIconColor(),
                    image: MyImages.userFilledSvg,
                    backgroundColor: MyColor.getCircleColor(),
                  ),
                  const SizedBox(width: Dimensions.space15),
                  CardColumn(
                    header: MyStrings.personalDetails.tr,
                    body: "",
                    isOnlyHeader: true,
                  ),
                  const Spacer(),
                  const CustomSvgPicture(image: MyImages.arrowForward)
                ],
              ),
            ),
            const CustomDivider(space: Dimensions.space10),
            InkWell(
              onTap: () {
                Get.toNamed(RouteHelper.changePasswordScreen);
              },
              child: Row(
                children: [
                  CircleShapeImage(
                    imageColor: MyColor.getIconColor(),
                    image: MyImages.changePassword,
                    backgroundColor: MyColor.getCircleColor(),
                  ),
                  const SizedBox(width: Dimensions.space15),
                  CardColumn(
                    header: MyStrings.changePassword.tr,
                    body: "",
                    isOnlyHeader: true,
                  ),
                  const Spacer(),
                  const CustomSvgPicture(image: MyImages.arrowForward)
                ],
              ),
            ),
            const CustomDivider(space: Dimensions.space10),
            InkWell(
              onTap: () {
                Get.toNamed(RouteHelper.termsAndConditionsScreen);
              },
              child: Row(
                children: [
                  CircleShapeImage(
                      imageColor: MyColor.getIconColor(),
                      image: MyImages.termsAndConditions,
                      backgroundColor: MyColor.getCircleColor()),
                  const SizedBox(width: Dimensions.space15),
                  CardColumn(
                    header: MyStrings.termsAndConditions.tr,
                    body: "",
                    isOnlyHeader: true,
                  ),
                  const Spacer(),
                  const CustomSvgPicture(image: MyImages.arrowForward)
                ],
              ),
            ),
            const CustomDivider(space: Dimensions.space10),
            InkWell(
              onTap: () {
                Get.toNamed(RouteHelper.privacyScreen);
              },
              child: Row(
                children: [
                  CircleShapeImage(
                      imageColor: MyColor.getIconColor(),
                      image: MyImages.privacyPolicy,
                      backgroundColor: MyColor.getCircleColor()),
                  const SizedBox(width: Dimensions.space15),
                  CardColumn(
                    header: MyStrings.privacyPolicy.tr,
                    body: "",
                    isOnlyHeader: true,
                  ),
                  const Spacer(),
                  const CustomSvgPicture(image: MyImages.arrowForward)
                ],
              ),
            ),
            const CustomDivider(space: Dimensions.space10),
            InkWell(
              onTap: () {
                Get.toNamed(RouteHelper.aboutScreen);
              },
              child: Row(
                children: [
                  CircleShapeImage(
                      imageColor: MyColor.getIconColor(),
                      image: MyImages.about,
                      backgroundColor: MyColor.getCircleColor()),
                  const SizedBox(width: Dimensions.space15),
                  CardColumn(
                    header: MyStrings.about.tr,
                    body: "",
                    isOnlyHeader: true,
                  ),
                  const Spacer(),
                  const CustomSvgPicture(image: MyImages.arrowForward)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
