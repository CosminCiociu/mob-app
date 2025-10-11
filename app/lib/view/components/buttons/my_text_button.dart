import 'package:flutter/material.dart';

import '../../../core/utils/my_color.dart';
import '../../../core/utils/style.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback press;
  final TextStyle? style;
  final double padding;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.press,
    this.style,
    this.padding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        elevation: 0,
        splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
        surfaceTintColor: MyColor.getPrimaryColor(),
        shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
        padding: EdgeInsets.all(padding),
        enableFeedback: false,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
      ),
      onPressed: press,
      child: Text(text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style:
              style ?? regularLarge.copyWith(color: MyColor.getPrimaryColor())),
    );
  }
}
