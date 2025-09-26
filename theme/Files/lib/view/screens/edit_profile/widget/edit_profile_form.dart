import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/data/controller/account/profile_controller.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:ovo_meet/view/components/buttons/rounded_loading_button.dart';
import 'package:ovo_meet/view/screens/edit_profile/widget/profile_image.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) => Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space15),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
        child: Form(
          child: Column(
            children: [
              ProfileWidget(isEdit: true, imagePath: controller.imageUrl, onClicked: () async {}),
              const SizedBox(height: Dimensions.space15),
              Align(alignment: Alignment.center, child: Text(MyStrings.demoName, style: boldMediumLarge)),
              Align(alignment: Alignment.center, child: Text(MyStrings.demoMail, style: regularDefault.copyWith(color: MyColor.getGreyText1()))),
              const SizedBox(height: Dimensions.space15),
              const SizedBox(height: Dimensions.space20),
              LabelTextField(
                labelText: MyStrings.firstName.tr,
                hintText: MyStrings.enterYourFirstName,
                textInputType: TextInputType.text,
                inputAction: TextInputAction.next,
                controller: controller.firstNameController,
                nextFocus: controller.zipCodeFocusNode,
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space5),
              LabelTextField(
                labelText: MyStrings.lastName.tr,
                hintText: MyStrings.enterYourLastName,
                textInputType: TextInputType.text,
                inputAction: TextInputAction.next,
                controller: controller.lastNameController,
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space5),
              LabelTextField(
                labelText: MyStrings.address.tr,
                hintText: MyStrings.enterAddress,
                textInputType: TextInputType.text,
                inputAction: TextInputAction.next,
                controller: controller.addressController,
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space5),
              LabelTextField(
                labelText: MyStrings.state.tr,
                hintText: MyStrings.enterYour,
                textInputType: TextInputType.text,
                inputAction: TextInputAction.next,
                controller: controller.stateController,
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space30),
              controller.isSubmitLoading
                  ? const RoundedLoadingBtn()
                  : InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: CustomGradiantButton(text: MyStrings.updateProfile.tr))
            ],
          ),
        ),
      ),
    );
  }
}
