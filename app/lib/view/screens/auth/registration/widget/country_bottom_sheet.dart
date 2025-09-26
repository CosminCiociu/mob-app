/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/core/utils/url_container.dart';
import 'package:ovo_meet/core/utils/util.dart';
import 'package:ovo_meet/data/controller/auth/auth/registration_controller.dart';
import 'package:ovo_meet/view/components/bottom-sheet/bottom_sheet_header_row.dart';
import 'package:ovo_meet/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:ovo_meet/view/components/card/bottom_sheet_card.dart';
import 'package:ovo_meet/view/components/image/my_image_widget.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:get/get.dart';

import '../../../../components/bottom-sheet/bottom_sheet_bar.dart';
import '../../../../components/bottom-sheet/custom_bottom_sheet_plus.dart';

class CountryBottomSheet {
  static void registrationCountryBottomSheet(BuildContext context, RegistrationController controller) {
    CustomBottomSheetPlus(
        bgColor: Colors.transparent,
        isNeedPadding: false,
        child: StatefulBuilder(builder: (context, setState) {
          if (controller.filteredCountries.isEmpty) {
            controller.filteredCountries = controller.countryList;
          }
          // Function to filter countries based on the search input.
          void filterCountries(String query) {
            if (query.isEmpty) {
              controller.filteredCountries = controller.countryList;
            } else {
              setState(() {
                controller.filteredCountries = controller.countryList.where((country) => country.country!.toLowerCase().contains(query.toLowerCase())).toList();
              });
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            decoration: BoxDecoration(
              color: MyColor.getCardBgColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: MyUtils.getShadow(),
            ),
            child: Column(
              children: [
                const BottomSheetBar(),
                const SizedBox(height: 10),
                LabelTextField(
                  labelText: '',
                  hintText: MyStrings.searchCountry.tr,
                  controller: controller.userNameController,
                  focusNode: controller.userNameFocusNode,
                  textInputType: TextInputType.text,
                  nextFocus: controller.emailFocusNode,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return MyStrings.enterYourUsername.tr;
                    } else if (value.length < 6) {
                      return MyStrings.kShortUserNameError.tr;
                    } else {
                      return null;
                    }
                  },
                  onChanged: filterCountries,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  labelTextStyle: boldDefault.copyWith(),
                  fillColor: MyColor.colorGrey.withOpacity(0.01),
                ),
                const SizedBox(height: 15),
                Flexible(
                  child: ListView.builder(
                      itemCount: controller.filteredCountries.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        var countryItem = controller.filteredCountries[index];

                        return GestureDetector(
                          onTap: () {
                            controller.countryController.text = controller.filteredCountries[index].country ?? '';
                            controller.setCountryNameAndCode(controller.filteredCountries[index].country ?? '', controller.filteredCountries[index].countryCode ?? '', controller.filteredCountries[index].dialCode ?? '');

                            Navigator.pop(context);

                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                          child: BottomSheetCard(
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                                  child: MyImageWidget(
                                    imageUrl: UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", countryItem.countryCode.toString().toLowerCase()),
                                    height: Dimensions.space25,
                                    width: Dimensions.space40 + 2,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '+${controller.filteredCountries[index].dialCode}  ${controller.filteredCountries[index].country?.tr ?? ''}',
                                    style: regularDefault.copyWith(color: MyColor.getTextColor()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
        })).show(context);
  }
}*/
