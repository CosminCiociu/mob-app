import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/partners_profile/partners_profile_controller.dart';
import 'package:ovo_meet/view/components/divider/custom_divider.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';

class PartnersProfileScreen extends StatefulWidget {
  const PartnersProfileScreen({super.key});

  @override
  State<PartnersProfileScreen> createState() => _PartnersProfileScreenState();
}

class _PartnersProfileScreenState extends State<PartnersProfileScreen> {
  @override
  void initState() {
    Get.put(PartnersProfileController());

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GetBuilder<PartnersProfileController>(
      builder: (controller) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Image.asset(
                      MyImages.girl1,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: Dimensions.space30,
                    left: Dimensions.space10,
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: const SizedBox(
                        height: Dimensions.space20,
                        width: Dimensions.space30,
                        child: CustomSvgPicture(
                          image: MyImages.arrowBack,
                          fit: BoxFit.contain,
                          color: MyColor.colorWhite,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.space20),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimensions.space20),
              child: Row(
                children: [
                  SizedBox(
                    width: Dimensions.space200 + Dimensions.space20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MyStrings.demoName,
                          style: boldOverLarge,
                        ),
                        Text(
                          MyStrings.demoOccupation,
                          style: regularDefault.copyWith(
                              color: MyColor.getSecondaryTextColor()),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.chatScreen);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.space8),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF76F96),
                            Color(0xFFF66D95),
                            Color(0xFFEB507E),
                            Color(0xFFE64375),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.space5),
                        child: Image.asset(
                          MyImages.message,
                          color: MyColor.colorWhite,
                          height: Dimensions.space30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.defaultScreenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomDivider(),
                  Text(
                    MyStrings.about,
                    style: boldOverLarge,
                  ),
                  Text(
                    MyStrings.aboutIntro,
                    style:
                        regularDefault.copyWith(color: MyColor.getGreyText()),
                  ),
                  const SizedBox(height: Dimensions.space10),
                  Text(
                    MyStrings.interst,
                    style: boldOverLarge,
                  ),
                  Wrap(
                    children: List.generate(
                      controller.interests.length,
                      (i) {
                        return Container(
                          padding: const EdgeInsets.all(Dimensions.space8),
                          margin: const EdgeInsets.all(Dimensions.space5),
                          decoration: BoxDecoration(
                              border: Border.all(width: .2),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.space10)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomSvgPicture(
                                  image: controller.interests[i]['image']),
                              const SizedBox(width: Dimensions.space5),
                              Text(controller.interests[i]['name'],
                                  style: regularLarge.copyWith(
                                      color: MyColor.colorBlack)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Dimensions.space20),
                  Text(
                    MyStrings.gallery,
                    style: boldOverLarge,
                  ),
                  const SizedBox(height: Dimensions.space10),
                  GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 6,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.all(Dimensions.space5),
                          child: GestureDetector(
                              onTap: () {
                                Get.toNamed(RouteHelper.previewImageScreen,
                                    arguments: MyImages.girl1);
                              },
                              child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(Dimensions.space10),
                                  child: Image.asset(MyImages.girl1,
                                      fit: BoxFit.cover))))),
                  const SizedBox(height: Dimensions.space50)
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
