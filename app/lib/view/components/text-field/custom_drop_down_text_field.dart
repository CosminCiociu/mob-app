import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/view/components/text/label_text.dart';
import 'package:flutter_svg/svg.dart';

class CustomDropDownTextField extends StatefulWidget {
  final dynamic selectedValue;
  final String? labelText;
  final String? hintText;
  final Function(dynamic)? onChanged;
  final List<DropdownMenuItem<dynamic>>? items;
  final Color? fillColor;
  final Color? focusColor;
  final Color? dropDownColor;
  final Color? iconColor;
  final double radius;
  final bool needLabel;

  const CustomDropDownTextField(
      {super.key,
      this.labelText,
      this.hintText,
      required this.selectedValue,
      required this.onChanged,
      required this.items,
      this.fillColor = MyColor.transparentColor,
      this.focusColor = MyColor.colorWhite,
      this.dropDownColor = MyColor.colorWhite,
      this.iconColor = MyColor.colorGrey,
      this.radius = 3,
      this.needLabel = true});

  @override
  State<CustomDropDownTextField> createState() =>
      _CustomDropDownTextFieldState();
}

class _CustomDropDownTextFieldState extends State<CustomDropDownTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.needLabel
            ? LabelText(text: widget.labelText.toString())
            : const SizedBox(),
        widget.needLabel
            ? const SizedBox(height: Dimensions.textToTextSpace)
            : const SizedBox(),
        SizedBox(
          height: 50,
          child: DropdownButtonFormField(
            initialValue: widget.selectedValue,
            dropdownColor: widget.dropDownColor,
            focusColor: widget.focusColor,
            style: regularSmall,
            alignment: Alignment.centerLeft,
            decoration: InputDecoration(
              hintText: widget.hintText.toString(),
              filled: true,
              fillColor: widget.fillColor,
              hintStyle:
                  regularSmall.copyWith(color: MyColor.getContentTextColor()),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                borderSide: BorderSide(
                    color: MyColor.getTextFieldDisableBorder(), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                borderSide: BorderSide(
                    color: MyColor.getTextFieldDisableBorder(), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                borderSide:
                    BorderSide(color: MyColor.getPrimaryColor(), width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                borderSide: BorderSide(color: MyColor.getRedColor(), width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                borderSide: BorderSide(
                    color: MyColor.getTextFieldDisableBorder(), width: 1),
              ),
            ),
            isExpanded: false,
            onChanged: widget.onChanged,
            items: widget.items,
            icon: SvgPicture.asset(MyImages.arrowDown),
          ),
        )
      ],
    );
  }
}
