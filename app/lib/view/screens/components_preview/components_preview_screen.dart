import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/common/theme_controller.dart';
import 'package:ovo_meet/view/components/animations/tween_animation.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/card/demo_card.dart';
import 'package:get/get.dart';

class ComponentPreviewScreen extends StatefulWidget {
  const ComponentPreviewScreen({super.key});

  @override
  State<ComponentPreviewScreen> createState() => _ComponentPreviewScreenState();
}

class _ComponentPreviewScreenState extends State<ComponentPreviewScreen> {
  int selectedIndex = -999;
  String label = "Some Label";
  List<String> dummyList = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];
  TextEditingController myController = TextEditingController();
  ThemeController themeController = Get.find<ThemeController>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: CustomAppBar(
          title: "Components Preview Screen",
          backButtonOnPress: () {
            Get.toNamed(RouteHelper.loginScreen);
          },
          action: [
            GestureDetector(
              onTap: () {
                Get.find<ThemeController>().changeTheme();
              },
              child: Icon(
                Get.find<ThemeController>().darkTheme ? CupertinoIcons.moon : CupertinoIcons.sun_min,
                color: MyColor.getWhiteColor(),
              ),
            ),
            const SizedBox(width: 10)
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: Dimensions.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                width: context.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: MyColor.getCardBgColor(),
                  border: Border.all(color: MyColor.getBorderColor()),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "TypoGraphy primary",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: MyColor.getPrimaryTextColor()),
                    ),
                    const SizedBox(height: Dimensions.space10),
                    Text(
                      "TypoGraphy secondary",
                      style: title.copyWith(color: MyColor.getPrimaryTextColor()),
                    ),
                    const TweenAnimation()
                  ],
                ),
              ),
             
              const SizedBox(height: Dimensions.space20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(20, (index) {
                    return DemoCard();
                  }),
                ),
              ),
              const SizedBox(height: Dimensions.space20),
           
            ],
           
          ),
        ),
      ),
    );
  }
}
