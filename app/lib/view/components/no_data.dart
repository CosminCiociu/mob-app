import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';

class NoDataWidget extends StatelessWidget {
  final double margin;
  String? text;
  NoDataWidget({
    super.key,
    this.margin = 4,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height / margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(MyImages.noDataFound, height: 120, width: 120),
          const SizedBox(height: Dimensions.space3),
          Text(
            MyStrings.noDataToShow.tr,
            style: regularLarge.copyWith(color: MyColor.getTextColor()),
          )
        ],
      ),
    );
  }
}
