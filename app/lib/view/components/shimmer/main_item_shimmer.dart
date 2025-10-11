import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class MainItemShimmer extends StatelessWidget {
  const MainItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: MyColor.getGreyColor().withOpacity(0.2),
          highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
          child: Container(
            decoration: BoxDecoration(
                color: MyColor.getGreyColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(6)),
            height: 100,
            width: 100,
          ),
        ),
      ],
    );
  }
}
