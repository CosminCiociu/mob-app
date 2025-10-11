import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class MatchCardShimmer extends StatelessWidget {
  const MatchCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: MyColor.getGreyColor().withOpacity(0.2),
      highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            color: MyColor.getGreyColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(Dimensions.mediumRadius)),
        height: 150,
        width: context.width,
      ),
    );
  }
}
