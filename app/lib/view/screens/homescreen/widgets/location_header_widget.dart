import 'package:flutter/material.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_images.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../../data/controller/home/home_controller.dart';
import '../../../components/image/custom_svg_picture.dart';

class LocationHeaderWidget extends StatelessWidget {
  final HomeController controller;

  const LocationHeaderWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.forceLocationUpdate();
      },
      borderRadius: BorderRadius.circular(Dimensions.space10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Dimensions.space5),
        padding: const EdgeInsets.symmetric(
            vertical: Dimensions.space15, horizontal: Dimensions.space10),
        decoration: BoxDecoration(
            border: Border.all(color: MyColor.colorWhite),
            color: MyColor.colorWhite,
            borderRadius: BorderRadius.circular(Dimensions.space10)),
        child: Row(children: [
          Container(
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
            child: const Padding(
              padding: EdgeInsets.all(Dimensions.space8),
              child: CustomSvgPicture(
                image: MyImages.pinImage,
                color: MyColor.colorWhite,
              ),
            ),
          ),
          const SizedBox(width: Dimensions.space10),
          SizedBox(
            width: Dimensions.space200 + Dimensions.space20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MyStrings.location,
                  style: boldLarge.copyWith(
                    color: MyColor.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  controller.addressController.text.isEmpty
                      ? 'Finding your location...'
                      : controller.addressController.text,
                  style: regularDefault.copyWith(
                    color: const Color(0xff262626),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Spacer(),
          InkWell(
              onTap: () {
                controller.drawerController.toggle!();
              },
              child: Image.asset(
                MyImages.burgerMenu,
                color: MyColor.buttonColor,
                height: Dimensions.space20,
              )),
        ]),
      ),
    );
  }
}
