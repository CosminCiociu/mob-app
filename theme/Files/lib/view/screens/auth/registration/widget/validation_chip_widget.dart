import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';


class ChipWidget extends StatelessWidget {

  final String name;
  final bool hasError;

  const ChipWidget({
       super.key,
       required this.name,
       required this.hasError
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          avatar: Icon(hasError?Icons.cancel:Icons.check_circle,color: hasError?MyColor.getRedColor():MyColor.getGreenColor(),size: 15,),
          shape: StadiumBorder(side: BorderSide(color: hasError?MyColor.getRedColor():MyColor.getGreenColor(),width: 1)),
          label: Text(
            name.tr,
            style: regularSmall.copyWith(
              fontSize: Dimensions.fontExtraSmall,
              color: hasError?MyColor.getRedColor():MyColor.getGreenColor(),
            ),
          ),
          backgroundColor: MyColor.getCardBgColor(),
        ),
        const SizedBox(width: 5,),
      ],
    );
  }
}