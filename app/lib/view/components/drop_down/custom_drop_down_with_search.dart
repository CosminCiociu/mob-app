import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/view/components/text-field/animated_text_field.dart';
import 'package:get/get.dart';

class CustomDropDownWithSearchField extends StatefulWidget {
  final String? title, selectedValue;
  final List<String>? list;
  final ValueChanged? onChanged;
  final ValueChanged? displayStringForOption;
  TextStyle? selectedTextStyle;
  TextStyle? itemTextStyle;

  CustomDropDownWithSearchField({
    super.key,
    this.title,
    this.selectedValue,
    this.list,
    this.onChanged,
    this.displayStringForOption,
    this.itemTextStyle,
    this.selectedTextStyle,
  }) : assert(list != null && list.contains(selectedValue), "Selected value must be from the list & list can't be empty");

  @override
  State<CustomDropDownWithSearchField> createState() => _CustomDropDownWithSearchFieldState();
}

class _CustomDropDownWithSearchFieldState extends State<CustomDropDownWithSearchField> {
  late String selectedOption;
  late TextEditingController searchController;
  late List<String> filteredOptions;
  @override
  void initState() {
    super.initState();

    selectedOption = widget.selectedValue ?? '';
    searchController = TextEditingController();
    filteredOptions = widget.list ?? [];
    filteredOptions.insert(0, "-1");
  }

  @override
  Widget build(BuildContext context) {
    widget.list?.removeWhere((element) => element.isEmpty);
    return StatefulBuilder(builder: (context, fn) {
      void filter(String query) {
        print(query);
        if (query.isEmpty) {
          filteredOptions = widget.list ?? [];
        } else {
          filteredOptions.clear();
          final newItems = (widget.list ?? []).where((text) => text.toLowerCase().contains(query.toLowerCase())).toList();
          if (newItems.isNotEmpty && newItems.contains(selectedOption)) {}
          setState(() {
            filteredOptions.addAll(newItems);
          });
        }
        print("options: $filteredOptions");
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(color: MyColor.getTransparentColor(), borderRadius: const BorderRadius.all(Radius.circular(5)), border: Border.all(color: MyColor.getTextFieldDisableBorder())),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
              child: DropdownButton(
                isExpanded: true,
                underline: Container(),
                hint: Text(
                  widget.selectedValue?.tr ?? '',
                  style: widget.selectedTextStyle ?? regularDefault.copyWith(color: MyColor.getBlackColor()),
                ), // Not necessary for Option 1
                value: widget.selectedValue,
                dropdownColor: MyColor.getWhiteColor(),
                onChanged: widget.onChanged,
                items: filteredOptions.map(
                  (value) {
                    return DropdownMenuItem(
                      value: value,
                      child: value == "-1"
                          ? AnimatedTextField(
                              onChanged: (v) {
                                filter(v);
                              },
                              hintText: "Search value",
                            )
                          : Row(
                              children: [
                                Text(
                                  value.tr,
                                  style: widget.itemTextStyle ?? regularDefault.copyWith(color: MyColor.getBlackColor()),
                                ),
                              ],
                            ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }
}
