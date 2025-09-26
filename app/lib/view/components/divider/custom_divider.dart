import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class CustomDivider extends StatelessWidget {
  final double space;
  final double? thickness;
  final double? height;
  final Color color;

  const CustomDivider({
    super.key,
    this.space = Dimensions.space20,
    this.color = MyColor.colorBlack,
    this.thickness,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: space),
        Divider(
          color: color.withOpacity(0.2),
          height: height ?? 0.5,
          thickness: thickness ?? 0.5,
        ),
        SizedBox(height: space),
      ],
    );
  }
}
