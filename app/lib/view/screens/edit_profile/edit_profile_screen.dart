import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/data/controller/account/profile_controller.dart';
import 'package:ovo_meet/view/components/custom_loader/custom_loader.dart';
import 'package:ovo_meet/view/screens/edit_profile/widget/edit_profile_form.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    final controller = Get.put(ProfileController());

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) => Scaffold(
        appBar: CustomAppBar(
            isShowBackBtn: true,
            title: MyStrings.editProfile.tr,
            isTitleCenter: true),
        body: controller.isLoading
            ? const CustomLoader()
            : Stack(
                children: [
                  const Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                          left: Dimensions.space15,
                          right: Dimensions.space15,
                          top: Dimensions.space80,
                          bottom: Dimensions.space20),
                      child: Column(
                        children: [EditProfileForm()],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
