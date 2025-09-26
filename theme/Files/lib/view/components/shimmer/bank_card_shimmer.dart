import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class BankCardShimmer extends StatelessWidget {
  const BankCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Shimmer.fromColors(
          baseColor: MyColor.getGreyColor().withOpacity(0.2),
          highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(50)),
            height: 40,
            width: 40,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Shimmer.fromColors(
          baseColor: MyColor.getGreyColor().withOpacity(0.2),
          highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
          child: Container(
            decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
            height: 20,
            width: context.width / 3 + 20,
          ),
        ),
      ],
    );
  }
}
