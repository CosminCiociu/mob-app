import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/controller/events/my_events_controller.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/view/components/app-bar/action_button_icon_widget.dart';
import 'package:ovo_meet/view/components/dialog/confirmation_dialog.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    print("🎯 EventsScreen: initState called");

    // Use Get.find() to avoid creating multiple instances
    // Only create if it doesn't exist
    if (!Get.isRegistered<MyEventsController>()) {
      print("📝 EventsScreen: Creating new MyEventsController");
      Get.put(MyEventsController());
    } else {
      print("♻️ EventsScreen: Using existing MyEventsController");
    }
  }

  void _showDeleteConfirmation(BuildContext context, String eventId,
      String eventName, MyEventsController controller) {
    ConfirmationDialog.show(
      context: context,
      title: 'Delete Event', // Keep as is since no specific constant exists
      message:
          'Are you sure you want to delete "$eventName"?\n\nThis action cannot be undone.',
      confirmText: 'Delete', // Keep as is since no specific constant exists
      cancelText: MyStrings.cancel,
      icon: Icons.warning_amber_rounded,
      onConfirm: () {
        controller.deleteEvent(eventId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyEventsController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: CustomAppBar(
          title: MyStrings.myEvents,
          isTitleCenter: true,
          isShowBackBtn: false,
          // Add icon button
          action: [
            ActionButtonIconWidget(
              icon: Icons.add,
              iconColor: MyColor.colorBlack,
              backgroundColor: MyColor.colorWhite,
              size: 60,
              pressed: () {
                Get.toNamed(RouteHelper.createEventForm);
              },
            ),
          ],
        ),
        body: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : controller.userEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: MyColor.colorGrey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events yet',
                          style: boldLarge.copyWith(
                            color: MyColor.colorGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first event by tapping the + button',
                          style: regularDefault.copyWith(
                            color: MyColor.colorGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: Dimensions.screenPadding,
                    child: Column(
                      children: [
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.userEvents.length,
                          itemBuilder: (context, index) {
                            final event = controller.userEvents[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Event Image
                                  if (event['imageUrl'] != null &&
                                      event['imageUrl'].toString().isNotEmpty)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: event['imageUrl']
                                              .toString()
                                              .startsWith('/')
                                          ? Image.file(
                                              File(event['imageUrl']),
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 200,
                                                  color: MyColor.colorGrey
                                                      .withOpacity(0.3),
                                                  child: const Icon(Icons
                                                      .image_not_supported),
                                                );
                                              },
                                            )
                                          : Image.asset(
                                              event['imageUrl'],
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 200,
                                                  color: MyColor.colorGrey
                                                      .withOpacity(0.3),
                                                  child: const Icon(Icons
                                                      .image_not_supported),
                                                );
                                              },
                                            ),
                                    ),

                                  // Event Details
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                event['eventName'] ??
                                                    'Untitled Event',
                                                style: boldLarge.copyWith(
                                                  color: MyColor.getTextColor(),
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            PopupMenuButton(
                                              onSelected: (value) {
                                                if (value == 'delete') {
                                                  _showDeleteConfirmation(
                                                      context,
                                                      event['id'],
                                                      event['eventName']
                                                              ?.toString() ??
                                                          'this event',
                                                      controller);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete,
                                                          color: Colors.red),
                                                      SizedBox(width: 8),
                                                      Text('Delete'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Date and Time
                                        if (event['dateTime'] != null)
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  size: 16, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Text(
                                                event['dateTime'],
                                                style: regularDefault.copyWith(
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 8),

                                        // Location/Type
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                size: 16, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text(
                                              event['inPersonOrVirtual'] ??
                                                  'Location TBD',
                                              style: regularDefault.copyWith(
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Description
                                        if (event['details'] != null &&
                                            event['details']
                                                .toString()
                                                .isNotEmpty)
                                          Text(
                                            event['details'],
                                            style: regularDefault.copyWith(
                                              color: MyColor.getTextColor(),
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                        const SizedBox(height: 12),

                                        // Status and Category
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: MyColor.primaryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                event['status'] ?? 'active',
                                                style: regularSmall.copyWith(
                                                  color: MyColor.primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            if (event['categoryId'] != null)
                                              Text(
                                                event['categoryId']
                                                    .toString()
                                                    .toUpperCase(),
                                                style: regularSmall.copyWith(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: Dimensions.space100),
                      ],
                    ),
                  ),
      ),
    );
  }
}
