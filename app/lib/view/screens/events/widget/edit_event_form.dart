import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/data/controller/events/my_events_controller.dart';
import 'package:ovo_meet/view/components/text-field/label_text_field.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/domain/services/events_service.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/view/components/form/category_selector.dart';
import 'package:ovo_meet/view/components/location/event_location_picker.dart';
import 'package:ovo_meet/view/components/form/date_time_selector.dart';
import 'package:ovo_meet/view/components/form/max_persons_selector.dart';
import 'package:ovo_meet/view/components/form/age_range_selector.dart';
import 'package:ovo_meet/view/components/form/invite_approval_selector.dart';
import 'package:ovo_meet/core/utils/my_images.dart';

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

  /// Build event image widget with proper error handling
  Widget _buildEventImage(MyEventsController controller) {
    try {
      // If there's a locally picked image file, use it first
      if (controller.imageFile != null) {
        return Image.file(
          controller.imageFile!,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading local image file: $error');
            return _buildPlaceholderImage();
          },
        );
      }

      // If there's an event image path
      if (controller.eventImagePath.isNotEmpty) {
        if (controller.eventImagePath.startsWith('http')) {
          // Network image with error handling
          return Image.network(
            controller.eventImagePath,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading network image: $error');
              return _buildPlaceholderImage();
            },
          );
        } else if (controller.eventImagePath.startsWith('assets/')) {
          // Asset image
          return Image.asset(
            controller.eventImagePath,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading asset image: $error');
              return _buildPlaceholderImage();
            },
          );
        } else {
          // Try as local file first, then as asset
          return Image.file(
            File(controller.eventImagePath),
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading local file, trying as asset: $error');
              return Image.asset(
                controller.eventImagePath,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, assetError, assetStackTrace) {
                  debugPrint('Error loading as asset too: $assetError');
                  return _buildPlaceholderImage();
                },
              );
            },
          );
        }
      }

      // No image path, use placeholder
      return _buildPlaceholderImage();
    } catch (e) {
      // If any error occurs, use placeholder
      debugPrint('Error in _buildEventImage: $e');
      return _buildPlaceholderImage();
    }
  }

  /// Build placeholder image widget
  Widget _buildPlaceholderImage() {
    return Image.asset(
      MyImages.placeHolderImage,
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // If even the placeholder fails, show a simple container
        debugPrint('Error loading placeholder image: $error');
        return Container(
          width: double.infinity,
          height: 180,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 48,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
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
            title: 'Edit Event',
            isTitleCenter: true,
            isShowBackBtn: true,
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
                    borderRadius: BorderRadius.circular(10)),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    physics:
                        const ClampingScrollPhysics(), // Disable bounce/overscroll to prevent swipe gestures
                    padding: const EdgeInsets.only(
                        bottom: 80), // Add padding for floating button
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top image & upload buttons
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: double.infinity,
                                height: 180,
                                color: Colors.grey[300],
                                child: _buildEventImage(controller),
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
                          selectedSubcategoryId:
                              controller.selectedSubcategoryId,
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
                                padding:
                                    const EdgeInsets.all(Dimensions.space15),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: MyColor.getBorderColor()),
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
                                        color:
                                            controller.eventLocationName != null
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
                                              color: controller
                                                          .eventLocationName !=
                                                      null
                                                  ? MyColor.getTextColor()
                                                  : MyColor
                                                      .getSecondaryTextColor(),
                                            ),
                                          ),
                                          if (controller.eventLocationName !=
                                              null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              MyStrings.tapToChangeLocation,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    MyColor.getPrimaryColor(),
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

                        // Event Date Time Selector
                        DateTimeSelector(
                          initialStartDateTime: controller.dateTimeStart,
                          initialEndDateTime: controller.dateTimeEnd,
                          onSelectionChanged: (startDateTime, endDateTime) {
                            // Automatically set hasSpecificTime to true when times are selected
                            if (startDateTime != null) {
                              controller.setHasSpecificTime(true);
                            }
                            controller.setDateTimeRange(
                                startDateTime, endDateTime);
                          },
                        ),

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

                        // Max Persons Selector
                        MaxPersonsSelector(
                          initialValue: controller.maxPersons,
                          onChanged: (maxPersons) {
                            controller.setMaxPersons(maxPersons);
                          },
                          label: 'Maximum Participants',
                          hint: 'No limit',
                        ),
                        const SizedBox(height: 12),

                        // Age Range Selector
                        AgeRangeSelector(
                          initialMinAge: controller.minAge,
                          initialMaxAge: controller.maxAge,
                          onChanged: (minAge, maxAge) {
                            controller.setAgeRange(minAge, maxAge);
                          },
                          label: MyStrings.age_between,
                          hint: 'No age limit',
                        ),
                        const SizedBox(height: 12),

                        // Invite Approval Selector
                        InviteApprovalSelector(
                          requiresApproval: controller.requiresApproval,
                          onChanged: (requiresApproval) {
                            controller.setRequiresApproval(requiresApproval);
                          },
                          label: 'Invite Approval',
                        ),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ), // Close GestureDetector
          floatingActionButton: Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            child: FloatingActionButton.extended(
              onPressed: controller.isSubmitLoading || !controller.isFormValid
                  ? null
                  : () {
                      _updateEvent();
                    },
              backgroundColor:
                  controller.isFormValid && !controller.isSubmitLoading
                      ? MyColor.getPrimaryColor()
                      : MyColor.getGreyColor(),
              foregroundColor: Colors.white,
              label: Text(
                controller.isSubmitLoading ? 'Updating...' : 'Update Event',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: controller.isSubmitLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
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
