import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/core/utils/url_container.dart';
import 'package:ovo_meet/core/utils/util.dart';
import 'package:ovo_meet/data/controller/account/profile_complete_controller.dart';
import 'package:ovo_meet/view/components/card/bottom_sheet_card.dart';
import 'package:ovo_meet/view/components/image/my_image_widget.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:get/get.dart';
import '../../../../../data/model/country_model/country_model.dart';
import '../../../../components/bottom-sheet/bottom_sheet_bar.dart';
import '../../../../components/bottom-sheet/custom_bottom_sheet_plus.dart';

class CountryBottomSheet {
  static void  profileCompleteCountryBottomSheet(BuildContext context, ProfileCompleteController controller) {
    CustomBottomSheetPlus(
        bgColor: MyColor.getGreyColor().withOpacity(.2),
        isNeedPadding: false,
        child: StatefulBuilder(builder: (context, setState) {
          if (controller.filteredCountries.isEmpty) {
            controller.filteredCountries = controller.countryList;
          }
          void filterCountries(String query) {
            if (query.isEmpty) {
              controller.filteredCountries = controller.countryList;
            } else {
              List<Countries> filterData = controller.filteredCountries.where((country) => country.country!.toLowerCase().contains(query.toLowerCase())).toList();
              setState(() {
                controller.filteredCountries = filterData;
              });
            }
          }
          return Container(
            height: MediaQuery.of(context).size.height * .9,
            padding: const EdgeInsets.symmetric(vertical: Dimensions.space20, horizontal: Dimensions.space30),
            decoration: BoxDecoration(
              color: MyColor.getCardBgColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.space20),
                topRight: Radius.circular(Dimensions.space20),
              ),
              boxShadow: MyUtils.getShadow(),
            ),
            child: Column(
              children: [
                const BottomSheetBar(),
                const SizedBox(height:Dimensions.space10),
                LabelTextField(
                  labelText: '',
                  hintText: '${MyStrings.searchCountry.tr}${controller.countryList.length}',
                  controller: controller.countryController,
                  textInputType: TextInputType.text,
                  onChanged: filterCountries,
                  prefixIcon:  Icon(
                    Icons.search,
                    color: MyColor.getGreyColor(),
                  ),
                  labelTextStyle: boldDefault.copyWith(),
                  fillColor: MyColor.getGreyColor().withOpacity(0.01),
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
                                    width: Dimensions.space40 + Dimensions.space2,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${controller.filteredCountries[index].dialCode}  ${controller.filteredCountries[index].country?.tr ?? ''}',
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
}
