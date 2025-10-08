import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/home/home_controller.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:get/get.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * .12),
              Stack(children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: Dimensions.space100, bottom: Dimensions.space50),
                  child: Transform.rotate(
                      angle: 0.2,
                      child: SizedBox(
                          height: size.height * .25,
                          child: SizedBox(
                              height: Dimensions.space300,
                              width: Dimensions.space170,
                              child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(Dimensions.space10),
                                  child: Image.asset(
                                    MyImages.boySmile,
                                    fit: BoxFit.cover,
                                  ))))),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: Dimensions.space80, top: Dimensions.space60),
                  child: Transform.rotate(
                      angle: -0.3,
                      child: SizedBox(
                          height: size.height * .25,
                          child: Stack(
                            children: [
                              SizedBox(
                                  height: Dimensions.space300,
                                  width: Dimensions.space170,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.space10),
                                      child: Image.asset(
                                        MyImages.girl1,
                                        fit: BoxFit.cover,
                                      ))),
                            ],
                          ))),
                ),
              ]),
              SizedBox(height: size.height * .12),
              Text(MyStrings.congratulations,
                  style: regularOverLarge.copyWith(
                      color: MyColor.buttonColor,
                      fontFamily: 'dancing',
                      fontSize: Dimensions.space40)),
              const SizedBox(height: Dimensions.space20),
              Text(MyStrings.itsaMatch,
                  style: boldOverLarge.copyWith(color: MyColor.buttonColor)),
              Text(
                MyStrings.startConversationNowtoEachOther,
                style: regularLarge.copyWith(color: MyColor.getGreyText1()),
              ),
              const SizedBox(height: Dimensions.space20),
              InkWell(
                  onTap: () {
                    Get.toNamed(RouteHelper.messageListScreen);
                  },
                  child: const CustomGradiantButton(text: MyStrings.sayHello)),
              const SizedBox(height: Dimensions.space10),
              InkWell(
                  onTap: () {
                    Get.find<HomeController>().currentIndex = 0;
                    Get.find<HomeController>().update();
                    Get.back();
                  },
                  child: const CustomGradiantButton(
                    text: MyStrings.keepSwiping,
                    hasBorder: true,
                    textColor: MyColor.buttonColor,
                    padding: 14,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
