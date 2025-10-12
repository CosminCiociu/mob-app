import 'package:flutter/material.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_images.dart';
import '../../../../data/controller/home/home_controller.dart';
import '../../../components/image/custom_svg_picture.dart';

class ActionButtonsWidget extends StatelessWidget {
  final HomeController controller;

  const ActionButtonsWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * .67, right: 70, left: 70),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              controller.cardController?.triggerLeft();
            },
            child: Container(
              padding: const EdgeInsets.all(Dimensions.space15),
              decoration: const BoxDecoration(
                  color: MyColor.lBackgroundColor, shape: BoxShape.circle),
              child: const CustomSvgPicture(
                image: MyImages.cancel,
                color: MyColor.colorRed,
                height: Dimensions.space12,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              controller.cardController?.triggerRight();
            },
            child: Container(
              padding: const EdgeInsets.all(Dimensions.space15),
              decoration: const BoxDecoration(
                  color: MyColor.lBackgroundColor, shape: BoxShape.circle),
              child: const CustomSvgPicture(
                image: MyImages.like,
                color: MyColor.travelColor,
                height: Dimensions.space20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
