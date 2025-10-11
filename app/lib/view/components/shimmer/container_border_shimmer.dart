import 'package:flutter/material.dart';
import '../../../core/utils/my_color.dart';
import 'my_shimmer_widget.dart';

class ShimmerBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final BorderRadius borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerBorderContainer({
    super.key,
    required this.child,
    this.borderWidth = 2.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(10.0)),
    this.baseColor = Colors.grey,
    this.highlightColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: MyShimmerWidget(
            baseColor: MyColor.getTransparentColor(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                    width: borderWidth, color: MyColor.getPrimaryColor()),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
                width: borderWidth, color: MyColor.getTransparentColor()),
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: child,
          ),
        ),
      ],
    );
  }
}
