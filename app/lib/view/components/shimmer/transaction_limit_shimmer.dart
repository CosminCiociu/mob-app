import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class TransactionLimitShimmer extends StatelessWidget {
  const TransactionLimitShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MyColor.getGreyColor().withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: MyColor.getGreyColor().withOpacity(0.2),
                highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(0)),
                  height: 5,
                  width: context.width / 6,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: MyColor.getGreyColor().withOpacity(0.2),
                    highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
                    child: Container(
                      decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(1)),
                      height: 5,
                      width: context.width / 6,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Shimmer.fromColors(
                    baseColor: MyColor.getGreyColor().withOpacity(0.2),
                    highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
                    child: Container(
                      decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(1)),
                      height: 5,
                      width: context.width / 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Shimmer.fromColors(
                baseColor: MyColor.getGreyColor().withOpacity(0.2),
                highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
                child: Container(
                  decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(1)),
                  height: 5,
                  width: context.width / 6,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Shimmer.fromColors(
                baseColor: MyColor.getGreyColor().withOpacity(0.2),
                highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
                child: Container(
                  decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(1)),
                  height: 5,
                  width: context.width / 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
