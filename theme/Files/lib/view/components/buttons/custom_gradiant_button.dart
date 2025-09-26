import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';

class CustomGradiantButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final bool hasBorder;
  final double padding;
  const CustomGradiantButton({super.key, required this.text, this.hasBorder = false, this.textColor = MyColor.colorWhite,this.padding=Dimensions.space15});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: padding),
        width: double.infinity,
        decoration: BoxDecoration(
          border: hasBorder ? Border.all(color: MyColor.buttonColor) : null,
          borderRadius: BorderRadius.circular(Dimensions.space12),
          gradient: hasBorder
              ? null
              : const LinearGradient(
                  colors: [
                    Color(0xFFF76F96),
                    Color(0xFFF66D95),
                    Color(0xFFEB507E),
                    Color(0xFFE64375),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: Center(
            child: Text(
          text,
          style: regularLarge.copyWith(color: textColor),
        )));
  }
}
