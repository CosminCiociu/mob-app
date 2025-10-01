import 'package:flutter/material.dart';
import 'package:ovo_meet/view/components/buttons/custom_elevated_button.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/auth/auth/registration_controller.dart';
import 'package:ovo_meet/view/screens/auth/registration/widget/validation_widget.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (controller) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelTextField(
                labelText: MyStrings.firstName.tr,
                hintText: "",
                controller: controller.fNameController,
                focusNode: controller.firstNameFocusNode,
                textInputType: TextInputType.text,
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return MyStrings.enterDisplayName.tr;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space20),
              LabelTextField(
                labelText: MyStrings.lastName.tr,
                hintText: "",
                controller: controller.lNameController,
                focusNode: controller.lastNameFocusNode,
                textInputType: TextInputType.text,
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return MyStrings.enterYourLastName.tr;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space20),
              LabelTextField(
                labelText: MyStrings.email.tr,
                hintText: '',
                controller: controller.emailController,
                focusNode: controller.emailFocusNode,
                textInputType: TextInputType.emailAddress,
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return MyStrings.enterYourEmail.tr;
                  } else if (!MyStrings.emailValidatorRegExp
                      .hasMatch(value ?? '')) {
                    return MyStrings.invalidEmailMsg.tr;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space20),
              Focus(
                onFocusChange: (hasFocus) {
                  controller.changePasswordFocus(hasFocus);
                },
                child: LabelTextField(
                  isPassword: true,
                  labelText: MyStrings.password.tr,
                  hintText: MyStrings.enterYourPassword_,
                  controller: controller.passwordController,
                  focusNode: controller.passwordFocusNode,
                  nextFocus: controller.confirmPasswordFocusNode,
                  textInputType: TextInputType.text,
                  onChanged: (value) {
                    if (controller.checkPasswordStrength) {
                      controller.updateValidationList(value);
                    }
                  },
                  validator: (value) {
                    return controller.validatePassword(value ?? '');
                  },
                  labelTextStyle: boldDefault.copyWith(),
                ),
              ),
              const SizedBox(height: Dimensions.textToTextSpace),
              Visibility(
                visible: controller.hasPasswordFocus &&
                    controller.checkPasswordStrength,
                child: ValidationWidget(
                  list: controller.passwordValidationRules,
                ),
              ),
              const SizedBox(height: Dimensions.space10),
              LabelTextField(
                labelText: MyStrings.confirmPassword.tr,
                hintText: MyStrings.confirmYourPassword,
                controller: controller.cPasswordController,
                focusNode: controller.confirmPasswordFocusNode,
                inputAction: TextInputAction.done,
                isPassword: true,
                onChanged: (value) {},
                validator: (value) {
                  if (controller.passwordController.text.toLowerCase() !=
                      controller.cPasswordController.text.toLowerCase()) {
                    return MyStrings.kMatchPassError.tr;
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: Dimensions.space25),
              Visibility(
                  visible: controller.needAgree,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 25,
                        height: 25,
                        child: Checkbox(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.defaultRadius)),
                          activeColor: MyColor.getPrimaryColor(),
                          checkColor: MyColor.getWhiteColor(),
                          value: controller.agreeTC,
                          side: WidgetStateBorderSide.resolveWith(
                            (states) => BorderSide(
                                width: 1.0,
                                color: controller.agreeTC
                                    ? MyColor.getTextFieldEnableBorder()
                                    : MyColor.getTextFieldDisableBorder()),
                          ),
                          onChanged: (bool? value) {
                            controller.updateAgreeTC();
                          },
                        ),
                      ),
                      const SizedBox(width: Dimensions.space8),
                      Row(
                        children: [
                          Text(MyStrings.iAgreeWith.tr,
                              style: regularDefault.copyWith(
                                  color: MyColor.getTextColor())),
                          const SizedBox(width: Dimensions.space3),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(RouteHelper.privacyScreen);
                            },
                            child: Text(MyStrings.policies.tr.toLowerCase(),
                                style: regularDefault.copyWith(
                                    color: MyColor.getPrimaryColor(),
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        MyColor.getPrimaryColor())),
                          ),
                          const SizedBox(width: Dimensions.space3),
                        ],
                      ),
                    ],
                  )),
              const SizedBox(height: Dimensions.space30),
              CustomElevatedBtn(
                isLoading: controller.submitLoading,
                text: MyStrings.signUp.tr,
                press: () {
                  if (formKey.currentState!.validate()) {}
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
