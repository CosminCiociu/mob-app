import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';
import '../text/label_text_with_instructions.dart';

class CustomTextField extends StatefulWidget {
  final String? instructions;
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final Function? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final FormFieldValidator? validator;
  final TextInputType? textInputType;
  final bool isEnable;
  final bool isPassword;
  final bool isShowSuffixIcon;
  final bool isIcon;
  final VoidCallback? onSuffixTap;
  final VoidCallback? onTap;
  final bool isSearch;
  final bool isCountryPicker;
  final TextInputAction inputAction;
  final bool needOutlineBorder;
  final bool readOnly;
  final bool needRequiredSign;
  final int? maxLines;
  final bool animatedLabel;
  final Color? fillColor;
  final bool isRequired;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const CustomTextField({
    super.key,
    this.instructions,
    this.labelText,
    this.readOnly = false,
    this.fillColor ,
    required this.onChanged,
    this.hintText,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.validator,
    this.textInputType,
    this.isEnable = true,
    this.isPassword = false,
    this.isShowSuffixIcon = false,
    this.isIcon = false,
    this.onSuffixTap,
    this.isSearch = false,
    this.isCountryPicker = false,
    this.inputAction = TextInputAction.next,
    this.needOutlineBorder = false,
    this.needRequiredSign = false,
    this.maxLines,
    this.animatedLabel = false,
    this.isRequired = false,
    this.onTap,
    this.initialValue,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return widget.needOutlineBorder
        ? widget.animatedLabel
            ? TextFormField(
                maxLines: widget.maxLines ?? 1,
                readOnly: widget.readOnly,
                style: regularDefault.copyWith(color: Theme.of(context).textTheme.titleLarge?.color),
                cursorColor: Theme.of(context).textTheme.titleLarge?.color,
                controller: widget.controller,
                autofocus: false,
                textInputAction: widget.inputAction,
                enabled: widget.isEnable,
                focusNode: widget.focusNode,
                validator: widget.validator,
                keyboardType: widget.textInputType,
                obscureText: widget.isPassword ? obscureText : false,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 5),
                  labelText: widget.labelText?.tr ?? '',
                  labelStyle: regularDefault.copyWith(color: Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.8)),
                  fillColor: widget.fillColor??MyColor.getTransparentColor(),
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: MyColor.getTextFieldDisableBorder()), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: MyColor.getTextFieldEnableBorder()), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: MyColor.getTextFieldDisableBorder()), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                  suffixIcon: widget.isShowSuffixIcon
                      ? widget.isPassword
                          ? IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: MyColor.getHintTextColor(), size: 20), onPressed: _toggle)
                          : widget.isIcon
                              ? IconButton(
                                  onPressed: widget.onSuffixTap,
                                  icon: Icon(
                                    widget.isSearch
                                        ? Icons.search_outlined
                                        : widget.isCountryPicker
                                            ? Icons.arrow_drop_down_outlined
                                            : Icons.camera_alt_outlined,
                                    size: 25,
                                    color: MyColor.getPrimaryColor(),
                                  ),
                                )
                              : null
                      : null,
                ),
                onFieldSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus) : null,
                onChanged: (text) => widget.onChanged!(text),
                onTap: widget.onTap,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelTextInstruction(
                    text: widget.labelText.toString(),
                    isRequired: widget.isRequired,
                    instructions: widget.instructions,
                  ),
                  const SizedBox(height: Dimensions.textToTextSpace),
                  TextFormField(
                    maxLines: widget.maxLines ?? 1,
                    readOnly: widget.readOnly,
                    style: regularDefault.copyWith(color: MyColor.getTextColor()),
                    cursorColor: MyColor.getTextColor(),
                    controller: widget.controller,
                    autofocus: false,
                    textInputAction: widget.inputAction,
                    enabled: widget.isEnable,
                    focusNode: widget.focusNode,
                    validator: widget.validator,
                    keyboardType: widget.textInputType,
                    obscureText: widget.isPassword ? obscureText : false,
                    initialValue: widget.initialValue,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 5),
                      hintText: widget.hintText != null ? widget.hintText!.tr : '',
                      hintStyle: regularSmall.copyWith(color: MyColor.getHintTextColor().withOpacity(0.7)),
                      fillColor: MyColor.getTransparentColor(),
                      filled: true,
                      border: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: MyColor.getTextFieldDisableBorder()), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: MyColor.getTextFieldEnableBorder()), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: MyColor.getTextFieldDisableBorder()), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                      suffixIcon: widget.isShowSuffixIcon
                          ? widget.isPassword
                              ? IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: MyColor.getHintTextColor(), size: 20), onPressed: _toggle)
                              : widget.isIcon
                                  ? IconButton(
                                      onPressed: widget.onSuffixTap,
                                      icon: Icon(
                                        widget.isSearch
                                            ? Icons.search_outlined
                                            : widget.isCountryPicker
                                                ? Icons.arrow_drop_down_outlined
                                                : Icons.camera_alt_outlined,
                                        size: 25,
                                        color: MyColor.getPrimaryColor(),
                                      ),
                                    )
                                  : null
                          : null,
                    ),
                    onFieldSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus) : null,
                    onChanged: (text) => widget.onChanged!(text), onTap: widget.onTap,
                  )
                ],
              )
        : TextFormField(
            maxLines: widget.maxLines ?? 1,
            readOnly: widget.readOnly,
            style: regularDefault.copyWith(color: MyColor.getTextColor()),
            cursorColor: MyColor.getHintTextColor(),
            controller: widget.controller,
            autofocus: false,
            textInputAction: widget.inputAction,
            enabled: widget.isEnable,
            focusNode: widget.focusNode,
            validator: widget.validator,
            keyboardType: widget.textInputType,
            obscureText: widget.isPassword ? obscureText : false,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 5),
              labelText: widget.labelText?.tr,
              labelStyle: regularDefault.copyWith(color: MyColor.getLabelTextColor()),
              fillColor: MyColor.transparentColor,
              filled: true,
              border: UnderlineInputBorder(borderSide: BorderSide(width: 0.5, color: MyColor.getTextFieldDisableBorder())),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.5, color: MyColor.getTextFieldEnableBorder())),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.5, color: MyColor.getTextFieldDisableBorder())),
              suffixIcon: widget.isShowSuffixIcon
                  ? widget.isPassword
                      ? IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: MyColor.getHintTextColor(), size: 20), onPressed: _toggle)
                      : widget.isIcon
                          ? IconButton(
                              onPressed: widget.onSuffixTap,
                              icon: Icon(
                                widget.isSearch
                                    ? Icons.search_outlined
                                    : widget.isCountryPicker
                                        ? Icons.arrow_drop_down_outlined
                                        : Icons.camera_alt_outlined,
                                size: 25,
                                color: MyColor.getPrimaryColor(),
                              ),
                            )
                          : null
                  : null,
            ),
            onFieldSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus) : null,
            onChanged: (text) => widget.onChanged!(text), onTap: widget.onTap,
          );
  }

  void _toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }
}
