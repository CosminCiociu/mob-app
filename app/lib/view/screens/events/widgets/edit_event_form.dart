import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/data/controller/events/my_events_controller.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/domain/services/events_service.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/view/components/buttons/custom_elevated_button.dart';
import 'event_image_upload_section.dart';
import 'event_form_fields.dart';
import 'event_action_menu.dart';

class EditEventForm extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EditEventForm({
    super.key,
    required this.eventData,
  });

  @override
  State<EditEventForm> createState() => _EditEventFormState();
}

class _EditEventFormState extends State<EditEventForm> {
  final formKey = GlobalKey<FormState>();
  late MyEventsController controller;

  @override
  void initState() {
    super.initState();
    try {
      // Check if EventsService is available first
      if (!Get.isRegistered<EventsService>()) {
        throw Exception('EventsService not registered');
      }

      // Ensure controller is available, create it if not found
      if (Get.isRegistered<MyEventsController>()) {
        controller = Get.find<MyEventsController>();
      } else {
        controller = Get.put(MyEventsController());
      }

      // Defer form population until after the build phase is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateFormWithEventData();
      });
    } catch (e) {
      debugPrint('Error initializing EditEventForm: $e');
      // Fallback: navigate back if initialization fails
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
    }
  }

  void _populateFormWithEventData() {
    // Use the service method to populate form with existing event data
    if (widget.eventData.isNotEmpty) {
      controller.populateFormForEditing(widget.eventData);
    }
  }

  Future<void> _updateEvent() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final eventId = widget.eventData['id'];
    if (eventId == null || eventId.isEmpty) {
      debugPrint('Cannot update event: missing event ID');
      return;
    }

    // Call the update event method
    await controller.updateEvent(eventId);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyEventsController>(
      builder: (controller) => PopScope(
        canPop: false, // Completely disable gesture-based navigation
        onPopInvoked: (didPop) {
          // Prevent all swipe gestures and back navigation except explicit back button
          if (!didPop) {
            // Only allow navigation via back button in app bar
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: CustomAppBar(
            title: MyStrings.editEvent,
            isTitleCenter: true,
            isShowBackBtn: true,
            action: [
              EventActionMenu(
                eventData: widget.eventData,
                controller: controller,
              ),
            ],
          ),
          body: GestureDetector(
            // Prevent all swipe gestures, especially swipe up to home screen
            onPanUpdate: (details) {
              // Absorb pan gestures (swipe left/right/up/down) without action
            },
            onVerticalDragUpdate: (details) {
              // Specifically block vertical swipes (up/down) to prevent home navigation
            },
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.space15,
                    horizontal: Dimensions.space15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.space10)),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Image Upload Section
                        EventImageUploadSection(controller: controller),
                        const SizedBox(height: Dimensions.space15),

                        // Event Form Fields
                        EventFormFields(controller: controller),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(Dimensions.space15),
            child: CustomElevatedBtn(
              text: controller.isSubmitLoading
                  ? MyStrings.updating
                  : MyStrings.updateEvent,
              press: controller.isSubmitLoading || !controller.isFormValid
                  ? () {}
                  : () => _updateEvent(),
              bgColor: controller.isFormValid && !controller.isSubmitLoading
                  ? MyColor.getPrimaryColor()
                  : MyColor.getGreyColor(),
              isLoading: controller.isSubmitLoading,
            ),
          ),
        ),
      ),
    );
  }
}
