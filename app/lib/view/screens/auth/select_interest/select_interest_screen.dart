import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/auth/auth/select_interest_controller.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:get/get.dart';

class SelectInterstScreen extends StatefulWidget {
  const SelectInterstScreen({super.key});

  @override
  State<SelectInterstScreen> createState() => _SelectInterstScreenState();
}

class _SelectInterstScreenState extends State<SelectInterstScreen> {
  @override
  void initState() {
    Get.put(SelectInterestController());

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ""),
      body: GetBuilder<SelectInterestController>(
        builder: (controller) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.defaultScreenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MyStrings.selectYourInterst,
                  style: boldOverLarge.copyWith(fontSize: Dimensions.space20),
                ),
                const SizedBox(height: Dimensions.space10),
                Text(
                  MyStrings
                      .selectaFewofYourIntersttoMatchWithUsersWhoHaveSimilarThingsinCommon,
                  style: regularDefault.copyWith(
                      color: MyColor.getSecondaryTextColor()),
                ),
                const SizedBox(height: Dimensions.space50),
                GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 4),
                    itemCount: controller.interests.length,
                    itemBuilder: (context, i) {
                      return Center(
                        child: InkWell(
                          onTap: () {
                            controller.tappedStatus(i);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: Dimensions.space5,
                                vertical: Dimensions.space2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.space8,
                                vertical: Dimensions.space2),
                            decoration: BoxDecoration(
                                gradient: controller.interests[i]['status']
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFF76F96),
                                          Color(0xFFF66D95),
                                          Color(0xFFEB507E),
                                          Color(0xFFE64375),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                border: Border.all(
                                    width: .5,
                                    color: controller.interests[i]['status']
                                        ? MyColor.buttonColor
                                        : MyColor
                                            .greyColorWithShadeFourHundred),
                                borderRadius:
                                    BorderRadius.circular(Dimensions.space5)),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.all(Dimensions.space5),
                                    child: CustomSvgPicture(
                                      image: controller.interests[i]['image'],
                                      height: Dimensions.space15,
                                      color: controller.interests[i]['status']
                                          ? MyColor.colorWhite
                                          : MyColor.colorBlack,
                                    ),
                                  ),
                                  SizedBox(
                                      width: Dimensions.space100,
                                      child: Text(
                                        controller.interests[i]['name'],
                                        style: regularDefault.copyWith(
                                            color: controller.interests[i]
                                                    ['status']
                                                ? MyColor.colorWhite
                                                : MyColor.colorBlack),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                const SizedBox(height: Dimensions.space80),
                InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.idealMatchScreen);
                    },
                    child:
                        const CustomGradiantButton(text: MyStrings.continues)),
                const SizedBox(height: Dimensions.space80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
