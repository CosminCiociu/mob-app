import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class PaybillHistoryCardShimmer extends StatelessWidget {
  bool isPdfShow = false;
  PaybillHistoryCardShimmer({super.key, this.isPdfShow = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Shimmer.fromColors(
              baseColor: MyColor.getGreyColor().withOpacity(0.2),
              highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(5)),
                height: isPdfShow ? 30 : 50,
                width: isPdfShow ? 30 : 50,
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
                    height: 15,
                    width: context.width / 4,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Shimmer.fromColors(
                  baseColor: MyColor.getGreyColor().withOpacity(0.2),
                  highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
                  child: Container(
                    decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(1)),
                    height: 15,
                    width: context.width / 3,
                  ),
                ),
              ],
            ),
          ],
        ),
        isPdfShow
            ? Shimmer.fromColors(
                baseColor: MyColor.getGreyColor().withOpacity(0.2),
                highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
                child: Container(
                  decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(1)),
                  height: 24,
                  width: 24,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Shimmer.fromColors(
                    baseColor: MyColor.getGreyColor().withOpacity(0.2),
                    highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
                    child: Container(
                      decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(1)),
                      height: 15,
                      width: context.width / 6,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Shimmer.fromColors(
                    baseColor: MyColor.getGreyColor().withOpacity(0.2),
                    highlightColor: MyColor.getPrimaryColor().withOpacity(0.7),
                    child: Container(
                      decoration: BoxDecoration(color: MyColor.getGreyColor().withOpacity(0.2), borderRadius: BorderRadius.circular(1)),
                      height: 15,
                      width: context.width / 5,
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
