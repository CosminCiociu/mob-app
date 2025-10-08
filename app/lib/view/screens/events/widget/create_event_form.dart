import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/data/controller/events/events_controller.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:ovo_meet/view/components/buttons/custom_gradiant_button.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/view/components/date_time/date_time_picker.dart';
import 'package:ovo_meet/view/components/drop_down/categories_drop_down.dart';

class CreateEventForm extends StatefulWidget {
  const CreateEventForm({super.key});

  @override
  State<CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EventsController>(
      builder: (controller) => Scaffold(
        // <-- Wrap with Scaffold for Material context
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
                    // Top image & GIF/Gallery/Upload buttons
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
                    // Replaced LabelTextField with DateTimePicker
                    CustomDateTimePicker(
                      title: MyStrings.eventDateTime,
                      onDateTimeChanged: (dateTime) {
                        controller.dateTimeController.text =
                            dateTime.toIso8601String();
                        controller.update();
                      },
                      initialDateTime:
                          controller.dateTimeController.text.isNotEmpty
                              ? DateTime.tryParse(
                                  controller.dateTimeController.text)
                              : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: controller.onTimezonePressed,
                          icon:
                              const Icon(Icons.language, color: Colors.white70),
                          label: Text(controller.timezoneLabel),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CategoriesDropDown(
                      initialCategory: controller.selectedCategoryId,
                      initialSubcategory: controller.selectedSubcategoryId,
                      onSelectionChanged: (categoryId, subcategoryId) {
                        controller.updateCategorySelection(
                            categoryId, subcategoryId);
                      },
                    ),

                    const SizedBox(height: 12),
                    LabelTextField(
                      labelText: 'Care sunt detaliile?',
                      hintText: '',
                      maxLines: 3,
                      controller: controller.detailsController,
                      onChanged: (value) => controller.update(),
                    ),
                    const SizedBox(height: 24),
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
  const _EventImageButton(
      {required this.icon, required this.label, this.onTap});

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
