import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/core/utils/util.dart';
import 'package:ovo_meet/data/controller/onboard/onboard_controller.dart';
import 'package:ovo_meet/view/components/buttons/custom_elevated_button.dart';
import 'package:ovo_meet/view/screens/onboard/widget/onboard_body.dart';
import 'package:ovo_meet/view/screens/onboard/widget/onboard_ripple_body.dart';
import 'package:get/get.dart';
import 'package:dots_indicator/dots_indicator.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    Get.put(OnBoardController());
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
       Orientation orientation = MediaQuery.of(context).orientation;

    

    return GetBuilder<OnBoardController>(builder: (controller) {
      return currentIndex == 0
          ? Scaffold(
              backgroundColor: MyColor.getWhiteColor(),
              body: Padding(
                padding: Dimensions.screenPadding,
                child: Column(
                  children: [
                    SizedBox(height: height * 0.1),
                    Expanded(
                      flex: 2,
                      child: PageView.builder(
                        controller: controller.controller,
                        itemCount: controller.appBanners.length,
                        onPageChanged: (i) {
                          controller.setCurrentIndex(i);
                        },
                        itemBuilder: (_, index) {
                          return OnBoardBody(
                            data: controller.appBanners[index],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: height * 0.1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        controller.currentIndex == controller.appBanners.length
                            ? const SizedBox.shrink()
                            : Text(
                                "Skip",
                                style: regularDefault.copyWith(fontSize: 18),
                              ),
                        DotsIndicator(
                          dotsCount: controller.appBanners.length,
                          position: controller.currentIndex,
                          mainAxisSize: MainAxisSize.min,
                          decorator: DotsDecorator(
                            size: const Size.square(8),
                            activeColor: MyColor.getPrimaryColor(),
                            color: MyColor.getPrimaryColor().withOpacity(0.2),
                          ),
                        ),
                        controller.currentIndex == controller.appBanners.length - 1
                            ? Text(
                                "Done",
                                style: boldDefault.copyWith(fontSize: 18),
                              )
                            : Text(
                                "Next",
                                style: boldDefault.copyWith(fontSize: 18),
                              )
                      ],
                    ),
                  ],
                ),
              ),
            )
          : AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light.copyWith(statusBarColor: MyColor.getTransparentColor(), statusBarIconBrightness: Brightness.light, systemNavigationBarColor: MyColor.getTransparentColor(), systemNavigationBarIconBrightness: Brightness.dark),
              child: Scaffold(
                body: PageView.builder(
                  controller: controller.controller,
                  itemCount: controller.appBanners.length,
                  onPageChanged: (i) {
                    controller.setCurrentIndex(i);
                  },
                  itemBuilder: (_, index) {
                    return Stack(
                      children: [
                        OnBoardRippleBody(data: controller.appBanners[index], controller: controller),
                        Positioned.fill(
                          bottom: height * 0.01,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: Dimensions.defaultPaddingHV,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height:orientation == Orientation.portrait? MediaQuery.of(context).size.height / 2.5:MediaQuery.of(context).size.height / 1.7,
                                    width:orientation == Orientation.portrait? 330: 800,
                                    decoration: BoxDecoration(color: MyColor.getWhiteColor(), borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          controller.appBanners[index].title,
                                          style: title.copyWith(fontSize: 24, fontWeight: FontWeight.w400, color: MyColor.getBlackColor()),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: Dimensions.space10),
                                        Text(
                                          controller.appBanners[index].subtitle,
                                          style: regularDefault.copyWith(color: MyColor.getGreyColor(), fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: Dimensions.space10),
                                        DotsIndicator(
                                          dotsCount: controller.appBanners.length,
                                          position: controller.currentIndex,
                                          mainAxisSize: MainAxisSize.min,
                                          decorator: DotsDecorator(
                                            size: const Size.square(8),
                                            activeColor: MyColor.buttonColor,
                                            color: MyColor.getGreyColor().withOpacity(.2),
                                          ),
                                        ),
                                        const Spacer(),
                                        controller.currentIndex == controller.appBanners.length - 1
                                            ? InkWell(
                                                onTap: () {},
                                                child: Container(
                                                  padding: const EdgeInsets.all(14),
                                                  decoration: BoxDecoration(
                                                    boxShadow: MyUtils.getCardShadow(),
                                                    shape: BoxShape.circle,
                                                    color: Colors.white24,
                                                  ),
                                                  child: SizedBox(
                                                    height: 50,
                                                    child: CustomElevatedBtn(
                                                      bgColor: MyColor.buttonColor,
                                                      press: () {
                                                       Get.toNamed(RouteHelper.loginScreen);
                                                      },
                                                      text: MyStrings.done,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () {},
                                                child: Container(
                                                  padding: const EdgeInsets.all(14),
                                                  decoration: BoxDecoration(
                                                    boxShadow: MyUtils.getCardShadow(),
                                                    shape: BoxShape.circle,
                                                    color: Colors.white24,
                                                  ),
                                                  child: SizedBox(
                                                    height: 50,
                                                    child: CustomElevatedBtn(
                                                      bgColor: MyColor.buttonColor,
                                                      press: () {
                                                        controller.setCurrentIndex(controller.currentIndex + 1);
                                                        controller.controller?.nextPage(duration: const Duration(microseconds: 500), curve: Curves.decelerate);
                                                      },
                                                      text: MyStrings.next,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
    });
  }
}
