import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:get/get.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      body: SingleChildScrollView(
          child: Stack(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height, child: Image.asset(MyImages.girl2, fit: BoxFit.cover)),
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .75,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    MyStrings.demoName,
                    style: regularLarge.copyWith(color: MyColor.colorWhite),
                  ),
                  const SizedBox(height: Dimensions.space10),
                  Text(
                    MyStrings.demoTime,
                    style: boldLarge.copyWith(color: MyColor.colorWhite),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .85, right: 70, left: 70),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(Dimensions.space15),
                    decoration: BoxDecoration(color: MyColor.greyColor, shape: BoxShape.circle),
                    child: CustomSvgPicture(
                      image: MyImages.micreophone,
                      color: MyColor.colorWhite,
                      height: Dimensions.space17,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(color: MyColor.colorRed, shape: BoxShape.circle),
                    child: CustomSvgPicture(
                      image: MyImages.phoneHangUp,
                      color: MyColor.colorWhite,
                      height: Dimensions.space25,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(Dimensions.space15),
                    decoration: BoxDecoration(color: MyColor.greyColor, shape: BoxShape.circle),
                    child: CustomSvgPicture(
                      image: MyImages.speaker,
                      color: MyColor.colorWhite,
                      height: Dimensions.space17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: Dimensions.space50, left: Dimensions.space20),
              width: 120,
              height: 150,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    MyImages.boySmile,
                    fit: BoxFit.cover,
                  )))
        ],
      )),
    );
  }
}
