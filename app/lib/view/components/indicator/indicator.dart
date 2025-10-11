import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/util.dart';

class LoadingIndicator extends StatelessWidget {
  final double strokeWidth;

  const LoadingIndicator({super.key, this.strokeWidth = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MyColor.getWhiteColor(),
          boxShadow: MyUtils.getCardShadow()),
      child: CircularProgressIndicator(
        color: MyColor.getPrimaryColor(),
        strokeWidth: 3,
      ),
    );
  }
}
