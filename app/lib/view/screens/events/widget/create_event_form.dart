import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/data/controller/events/my_events_controller.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/view/components/date_time/event_date_time_picker.dart';
import 'package:ovo_meet/view/components/form/category_selector.dart';
import 'package:ovo_meet/view/components/location/event_location_picker.dart';

class CreateEventForm extends StatefulWidget {
  const CreateEventForm({super.key});

  @override
  State<CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final formKey = GlobalKey<FormState>();

  void _showLocationSelector(
      BuildContext context, MyEventsController controller) {
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyEventsController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: CustomAppBar(
          title: MyStrings.createEvent,
          isTitleCenter: true,
          isShowBackBtn: true,
        ),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.space15, horizontal: Dimensions.space15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10)),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top image & upload buttons
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            image: controller.eventImagePath.isNotEmpty
                                ? DecorationImage(
                                    image: controller.imageFile != null
                                        ? FileImage(controller.imageFile!)
                                        : AssetImage(controller.eventImagePath)
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(height: 10),
                              _EventImageButton(
                                icon: Icons.upload,
                                label: MyStrings.uploadImage,
                                onTap: controller.showImagePickerOptions,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.space15),

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
                    const SizedBox(height: 12),

                    // Category Selector
                    CategorySelector(
                      selectedCategoryId: controller.selectedCategoryId,
                      selectedSubcategoryId: controller.selectedSubcategoryId,
                      onSelectionChanged: (categoryId, subcategoryId) {
                        controller.updateCategorySelection(
                            categoryId, subcategoryId);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Event Location Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MyStrings.eventLocation,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: MyColor.getTextColor(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            _showLocationSelector(context, controller);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(Dimensions.space15),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: MyColor.getBorderColor()),
                              borderRadius: BorderRadius.circular(8),
                              color: MyColor.getCardBgColor(),
                            ),
                            child: Row(
                              children: [
                                // Location indicator
                                Container(
                                  width: 12,
                                  height: 12,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.eventLocationName ??
                                            MyStrings.selectLocation,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: controller.eventLocationName !=
                                                  null
                                              ? MyColor.getTextColor()
                                              : MyColor.getSecondaryTextColor(),
                                        ),
                                      ),
                                      if (controller.eventLocationName !=
                                          null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          MyStrings.tapToChangeLocation,
                                          style: TextStyle(
                                            fontSize: 14,
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
                    ),
                    const SizedBox(height: 12),

                    // Event Time Toggle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MyStrings.eventDateTime,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: MyColor.getTextColor(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            controller.setHasSpecificTime(
                                !controller.hasSpecificTime);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(Dimensions.space15),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: controller.hasSpecificTime
                                    ? MyColor.getPrimaryColor()
                                    : MyColor.getBorderColor(),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: controller.hasSpecificTime
                                  ? MyColor.getPrimaryColor().withOpacity(0.05)
                                  : MyColor.getCardBgColor(),
                            ),
                            child: Row(
                              children: [
                                // Status indicator
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: controller.hasSpecificTime
                                        ? MyColor.getPrimaryColor()
                                        : MyColor.getGreyColor(),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.space12),
                                // Text
                                Expanded(
                                  child: Text(
                                    MyStrings.eventHasSpecificTime,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: controller.hasSpecificTime
                                          ? MyColor.getTextColor()
                                          : MyColor.getSecondaryTextColor(),
                                    ),
                                  ),
                                ),
                                // Arrow indicator
                                Icon(
                                  controller.hasSpecificTime
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: MyColor.getSecondaryTextColor(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Show date/time picker if hasSpecificTime is true
                    if (controller.hasSpecificTime) ...[
                      const SizedBox(height: 12),
                      EventDateTimePicker(
                        title: MyStrings.eventDateTime,
                        showTitle: false,
                        onDateTimeRangeChanged: (startDateTime, endDateTime) {
                          controller.setDateTimeRange(
                              startDateTime, endDateTime);
                        },
                        initialStartDateTime: controller.dateTimeStart,
                        initialEndDateTime: controller.dateTimeEnd,
                      ),
                    ],

                    // Show timezone selector if hasSpecificTime is true
                    if (controller.hasSpecificTime) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: controller.onTimezonePressed,
                            icon: const Icon(Icons.language,
                                color: Colors.white70),
                            label: Text(controller.timezoneLabel),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Event Details
                    LabelTextField(
                      labelText: 'Care sunt detaliile?',
                      hintText: '',
                      maxLines: 3,
                      controller: controller.detailsController,
                      onChanged: (value) => controller.update(),
                    ),
                    const SizedBox(height: 24),

                    // Create Event Button
                    GestureDetector(
                      onTap:
                          controller.isSubmitLoading || !controller.isFormValid
                              ? null
                              : () {
                                  if (formKey.currentState!.validate()) {
                                    controller.createEvent();
                                  }
                                },
                      child: CustomGradiantButton(
                        text: controller.isSubmitLoading
                            ? 'Creating...'
                            : 'Creează un eveniment',
                        isEnable: controller.isFormValid &&
                            !controller.isSubmitLoading,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventImageButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _EventImageButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
