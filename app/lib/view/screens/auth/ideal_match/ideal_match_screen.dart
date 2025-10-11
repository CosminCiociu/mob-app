import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/auth/auth/ideal_match_controller.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:get/get.dart';

class IdealMatchScreen extends StatefulWidget {
  const IdealMatchScreen({super.key});

  @override
  State<IdealMatchScreen> createState() => _IdealMatchScreenState();
}

class _IdealMatchScreenState extends State<IdealMatchScreen> {
  @override
  void initState() {
    Get.put(IdealMatchController());

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.lBackgroundColor,
      appBar: const CustomAppBar(
        title: "",
        bgColor: MyColor.lBackgroundColor,
      ),
      body: GetBuilder<IdealMatchController>(
        builder: (controller) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.defaultScreenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MyStrings.idealMatch,
                  style: boldOverLarge.copyWith(fontSize: Dimensions.space20),
                ),
                const SizedBox(height: Dimensions.space10),
                Text(
                  MyStrings.whatareYouHopingtoFindHereonSprout,
                  style: regularDefault.copyWith(
                      color: MyColor.getSecondaryTextColor()),
                ),
                const SizedBox(height: Dimensions.space50),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: Dimensions.space10,
                    );
                  },
                  shrinkWrap: true,
                  itemCount: controller.idealMatch.length,
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: () {
                        controller.changeTapStatus(i);
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: controller.idealMatch[i]['status']
                                ? MyColor.buttonColor
                                : MyColor.colorWhite,
                          ),
                          color: MyColor.colorWhite,
                          borderRadius:
                              BorderRadius.circular(Dimensions.space10),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: Dimensions.space5),
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.space15,
                            horizontal: Dimensions.space10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(Dimensions.space8),
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
                                  padding:
                                      const EdgeInsets.all(Dimensions.space8),
                                  child: CustomSvgPicture(
                                    image: controller.idealMatch[i]['image']
                                        .toString(),
                                    color: MyColor.colorWhite,
                                  ),
                                ),
                              ),
                              const SizedBox(width: Dimensions.space10),
                              SizedBox(
                                width: Dimensions.space200 + 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.idealMatch[i]['name'],
                                      style: boldLarge,
                                    ),
                                    Text(
                                      controller.idealMatch[i]['subTitle'],
                                      style: regularDefault.copyWith(
                                        color: MyColor.getSecondaryTextColor(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: Dimensions.space150),
                InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.bottomNavBar);
                    },
                    child:
                        const CustomGradiantButton(text: MyStrings.continues))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
