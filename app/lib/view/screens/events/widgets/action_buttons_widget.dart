import 'package:flutter/material.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_images.dart';
import '../../../components/image/custom_svg_picture.dart';

class EventActionButtonsWidget extends StatelessWidget {
  final VoidCallback? onDecline;
  final VoidCallback? onJoin;

  const EventActionButtonsWidget({
    Key? key,
    this.onDecline,
    this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onDecline,
          child: Container(
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: const BoxDecoration(
              color: MyColor.lBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: const CustomSvgPicture(
              image: MyImages.cancel,
              color: MyColor.colorRed,
              height: Dimensions.space12,
            ),
          ),
        ),
        const SizedBox(width: 40),
        InkWell(
          onTap: onJoin,
          child: Container(
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: const BoxDecoration(
              color: MyColor.lBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: const CustomSvgPicture(
              image: MyImages.like,
              color: MyColor.travelColor,
              height: Dimensions.space20,
            ),
          ),
        ),
      ],
    );
  }
}
