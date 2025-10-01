import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/account/change_password_controller.dart';

import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/screens/account/change-password/widget/change_password_form.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  @override
  void initState() {
    Get.put(ChangePasswordController());
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ChangePasswordController>().clearData();
    });
  }

  @override
  void dispose() {
    Get.find<ChangePasswordController>().clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          isShowBackBtn: true,
          title: MyStrings.changePassword.tr,
          isTitleCenter: true),
      body: GetBuilder<ChangePasswordController>(
        builder: (controller) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.defaultScreenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MyStrings.createNewPassword.tr,
                  style: regularExtraLarge.copyWith(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 50),
                  child: Text(
                    MyStrings.createPasswordSubText.tr,
                    style: regularDefault.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.color
                            ?.withAlpha((0.8 * 255).toInt())),
                  ),
                ),
                const SizedBox(height: 50),
                const ChangePasswordForm()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
