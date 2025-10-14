import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/data/controller/events/my_events_controller.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:ovo_meet/view/components/form/category_selector.dart';
import 'package:ovo_meet/view/components/location/event_location_picker.dart';
import 'package:ovo_meet/view/components/form/date_time_selector.dart';
import 'package:ovo_meet/view/components/form/max_persons_selector.dart';
import 'package:ovo_meet/view/components/form/age_range_selector.dart';
import 'package:ovo_meet/view/components/form/invite_approval_selector.dart';

class EventFormFields extends StatelessWidget {
  final MyEventsController controller;

  const EventFormFields({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Name
        LabelTextField(
          labelText: MyStrings.eventName,
          hintText: MyStrings.eventNameHint,
          textInputType: TextInputType.text,
          inputAction: TextInputAction.next,
          controller: controller.eventNameController,
          validator: (value) {
            if (value != null && value.isEmpty) {
              return MyStrings.eventNameHint.tr;
            } else {
              return null;
            }
          },
          onChanged: (value) => controller.update(),
        ),
        const SizedBox(height: Dimensions.space12),

        // Category Selector
        CategorySelector(
          selectedCategoryId: controller.selectedCategoryId,
          selectedSubcategoryId: controller.selectedSubcategoryId,
          onSelectionChanged: (categoryId, subcategoryId) {
            controller.updateCategorySelection(categoryId, subcategoryId);
          },
        ),
        const SizedBox(height: Dimensions.space12),

        // Event Location Selector
        _buildLocationSelector(context),
        const SizedBox(height: Dimensions.space12),

        // Event Date Time Selector
        DateTimeSelector(
          initialStartDateTime: controller.dateTimeStart,
          initialEndDateTime: controller.dateTimeEnd,
          onSelectionChanged: (startDateTime, endDateTime) {
            // Automatically set hasSpecificTime to true when times are selected
            if (startDateTime != null) {
              controller.setHasSpecificTime(true);
            }
            controller.setDateTimeRange(startDateTime, endDateTime);
          },
        ),

        // Show timezone selector if hasSpecificTime is true
        if (controller.hasSpecificTime) ...[
          const SizedBox(height: Dimensions.space12),
          _buildTimezoneSelector(),
        ],
        const SizedBox(height: Dimensions.space12),

        // Max Persons Selector
        MaxPersonsSelector(
          initialValue: controller.maxPersons,
          onChanged: (maxPersons) {
            controller.setMaxPersons(maxPersons);
          },
          label: 'Maximum Participants',
          hint: MyStrings.noLimit,
        ),
        const SizedBox(height: Dimensions.space12),

        // Age Range Selector
        AgeRangeSelector(
          initialMinAge: controller.minAge,
          initialMaxAge: controller.maxAge,
          onChanged: (minAge, maxAge) {
            controller.setAgeRange(minAge, maxAge);
          },
          label: MyStrings.ageRangeText,
          hint: MyStrings.noAgeLimit,
        ),
        const SizedBox(height: Dimensions.space12),

        // Invite Approval Selector
        InviteApprovalSelector(
          requiresApproval: controller.requiresApproval,
          onChanged: (requiresApproval) {
            controller.setRequiresApproval(requiresApproval);
          },
          label: MyStrings.inviteApproval,
        ),
        const SizedBox(height: Dimensions.space12),

        // Event Details
        LabelTextField(
          labelText: MyStrings.eventDetailsLabel,
          hintText: MyStrings.eventDetailsHint,
          maxLines: 3,
          controller: controller.detailsController,
          onChanged: (value) => controller.update(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLocationSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MyStrings.eventLocation,
          style: TextStyle(
            fontSize: Dimensions.fontDefault,
            fontWeight: FontWeight.w500,
            color: MyColor.getTextColor(),
          ),
        ),
        const SizedBox(height: Dimensions.space8),
        InkWell(
          onTap: () => _showLocationSelector(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: BoxDecoration(
              border: Border.all(color: MyColor.getBorderColor()),
              borderRadius: BorderRadius.circular(Dimensions.space8),
              color: MyColor.getCardBgColor(),
            ),
            child: Row(
              children: [
                // Location indicator
                Container(
                  width: Dimensions.space12,
                  height: Dimensions.space12,
                  decoration: BoxDecoration(
                    color: controller.eventLocationName != null
                        ? MyColor.getPrimaryColor()
                        : MyColor.getGreyColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: Dimensions.space12),
                // Location text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.eventLocationName ??
                            MyStrings.selectLocation,
                        style: TextStyle(
                          fontSize: Dimensions.fontDefault + 2,
                          fontWeight: FontWeight.w500,
                          color: controller.eventLocationName != null
                              ? MyColor.getTextColor()
                              : MyColor.getSecondaryTextColor(),
                        ),
                      ),
                      if (controller.eventLocationName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          MyStrings.tapToChangeLocation,
                          style: TextStyle(
                            fontSize: Dimensions.fontDefault,
                            color: MyColor.getPrimaryColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Dropdown arrow
                Icon(
                  Icons.keyboard_arrow_down,
                  color: MyColor.getSecondaryTextColor(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimezoneSelector() {
    return Row(
      children: [
        const SizedBox(width: Dimensions.space8),
        OutlinedButton.icon(
          onPressed: controller.onTimezonePressed,
          icon: Icon(
            Icons.language,
            color: MyColor.getWhiteColor().withOpacity(0.7),
          ),
          label: Text(controller.timezoneLabel),
          style: OutlinedButton.styleFrom(
            foregroundColor: MyColor.getWhiteColor(),
            side: BorderSide(color: MyColor.getWhiteColor().withOpacity(0.24)),
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }

  void _showLocationSelector(BuildContext context) {
    // Use the EventLocationPicker static method
    EventLocationPicker.showLocationPicker(
      context: context,
      onLocationSelected: (location, locationName) {
        controller.setEventLocation(location, locationName);
      },
      initialLocation: controller.eventLocation,
      initialLocationName: controller.eventLocationName,
    );
  }
}
