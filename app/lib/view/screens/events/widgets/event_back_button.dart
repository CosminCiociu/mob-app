import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';

class EventBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const EventBackButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + Dimensions.space10,
      left: Dimensions.space15,
      child: GestureDetector(
        onTap: onPressed ?? () => Get.back(),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.space8),
          decoration: BoxDecoration(
            color: MyColor.colorBlack.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back,
            color: MyColor.colorWhite,
            size: Dimensions.fontHeader,
          ),
        ),
      ),
    );
  }
}
