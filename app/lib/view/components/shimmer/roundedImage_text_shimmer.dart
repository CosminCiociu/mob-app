import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class RoundedWidgetTextShimmer extends StatelessWidget {
  const RoundedWidgetTextShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: MyColor.getGreyColor().withOpacity(0.2),
          highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            width: 65,
            height: 60,
          ),
        ),
        const SizedBox(height: Dimensions.space5),
        Shimmer.fromColors(
          baseColor: MyColor.getGreyColor().withOpacity(0.2),
          highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(1)),
            width: 60,
            height: 10,
          ),
        ),
      ],
    );
  }
}
