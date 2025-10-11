import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/data/controller/localization/localization_controller.dart';
import 'package:ovo_meet/data/controller/my_language_controller/my_language_controller.dart';

import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/buttons/custom_elevated_button.dart';
import 'package:ovo_meet/view/components/custom_loader/custom_loader.dart';
import 'package:ovo_meet/view/components/no_data.dart';
import 'package:ovo_meet/view/screens/language/widget/language_card.dart';
import 'package:get/get.dart';

class SettingsAndPreferenceScreen extends StatefulWidget {
  const SettingsAndPreferenceScreen({super.key});

  @override
  State<SettingsAndPreferenceScreen> createState() =>
      _SettingsAndPreferenceScreenState();
}

class _SettingsAndPreferenceScreenState
    extends State<SettingsAndPreferenceScreen> {
  String comeFrom = '';

  @override
  void initState() {
    Get.put(LocalizationController(sharedPreferences: Get.find()));
    final controller = Get.put(MyLanguageController());

    comeFrom = Get.arguments ?? '';

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyLanguageController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: CustomAppBar(
          isShowBackBtn: true,
          title: MyStrings.language.tr,
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : controller.langList.isEmpty
                ? NoDataWidget()
                : SingleChildScrollView(
                    padding: Dimensions.screenPadding,
                    child: GridView.builder(
                      shrinkWrap: true,
                      addAutomaticKeepAlives: true,
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      itemCount: controller.langList.length,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio:
                              MediaQuery.of(context).size.width > 200 ? 2 : 1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 150),
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          controller.changeSelectedIndex(index);
                        },
                        child: LanguageCard(
                          index: index,
                          selectedIndex: controller.selectedIndex,
                          langeName: controller.langList[index].languageName,
                          isShowTopRight: true,
                          imagePath: '',
                        ),
                      ),
                    ),
                  ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              vertical: Dimensions.space15, horizontal: Dimensions.space15),
          child: CustomElevatedBtn(
            text: MyStrings.confirm.tr,
            isLoading: controller.isChangeLangLoading,
            press: () {},
          ),
        ),
      ),
    );
  }
}
