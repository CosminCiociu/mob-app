import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ShpinSectiionShimmer extends StatelessWidget {
  const ShpinSectiionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: MyColor.getGreyColor().withOpacity(0.2),
      highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
      child: Container(
        decoration: BoxDecoration(
            color: MyColor.getGreyColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(2)),
        height: 150,
        width: context.width,
      ),
    );
  }
}
