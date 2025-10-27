import 'package:flutter/material.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/style.dart';

class LocationPermissionCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool isClickable;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const LocationPermissionCard({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.onTap,
    this.isClickable = false,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(Dimensions.locationCardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? MyColor.locationCardBackground,
        borderRadius: BorderRadius.circular(Dimensions.modernRadius),
        border: Border.all(
          color: MyColor.getBorderColor().withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.getShadowColor().withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(height: Dimensions.space20),
          ],
          Text(
            title,
            style: boldLarge.copyWith(
              color: MyColor.getTextColor(),
              fontSize: Dimensions.fontHeader,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.space12),
          Text(
            description,
            style: regularDefault.copyWith(
              color: MyColor.getSecondaryTextColor(),
              fontSize: Dimensions.fontLarge,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (isClickable && onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.modernRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}
