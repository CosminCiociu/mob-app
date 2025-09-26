import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ovo_meet/core/utils/style.dart';
import '../../../core/utils/my_color.dart';

class OTPFieldWidget extends StatelessWidget {
  const OTPFieldWidget({super.key,required this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height:Dimensions.space50,
      child: PinCodeTextField(
        appContext: context,
        pastedTextStyle: regularDefault.copyWith(color: MyColor.getTextColor()),
        length: 6,
        textStyle: regularDefault.copyWith(color: MyColor.getTextColor()),
        obscureText: false,
        obscuringCharacter: '*',
        blinkWhenObscuring: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.circle,
          borderWidth: 1,
          borderRadius: BorderRadius.circular(Dimensions.space5),
          fieldHeight: Dimensions.space50,
          fieldWidth: Dimensions.space45,
          inactiveColor:  MyColor.getTextFieldDisableBorder(),
          inactiveFillColor: MyColor.getScreenBgColor(),
          activeFillColor: MyColor.getScreenBgColor(),
          activeColor: MyColor.getPrimaryColor(),
          selectedFillColor: MyColor.getScreenBgColor(),
          selectedColor: MyColor.getPrimaryColor()
        ),
        cursorColor: MyColor.getBlackColor(),
        animationDuration:
        const Duration(milliseconds: 100),
        enableActiveFill: true,
        keyboardType: TextInputType.number,
        beforeTextPaste: (text) {
          return true;
        },
        onChanged: (value) => onChanged!(value),
      ),
    );
  }
}
