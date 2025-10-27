import 'package:flutter/material.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/dimensions.dart';

class LocationPermissionIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool isAnimated;

  const LocationPermissionIcon({
    super.key,
    this.size = Dimensions.locationIconSize,
    this.color,
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? MyColor.locationIconColor;

    Widget icon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: iconColor.withOpacity(0.1),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.location_on,
        size: size * 0.5,
        color: iconColor,
      ),
    );

    if (isAnimated) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: icon,
          );
        },
      );
    }

    return icon;
  }
}
