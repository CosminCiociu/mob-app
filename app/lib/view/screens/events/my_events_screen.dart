import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/data/controller/events/my_events_controller.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/view/components/app-bar/action_button_icon_widget.dart';
import 'widgets/empty_events_state.dart';
import 'widgets/events_list.dart';
import 'widgets/event_context_menu.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  @override
  void initState() {
    super.initState();
    print("🎯 MyEventsScreen: initState called");

    // Use Get.find() to avoid creating multiple instances
    // Only create if it doesn't exist
    if (!Get.isRegistered<MyEventsController>()) {
      print("📝 MyEventsScreen: Creating new MyEventsController");
      Get.put(MyEventsController());
    } else {
      print("♻️ MyEventsScreen: Using existing MyEventsController");
      // Refresh events data when reusing existing controller
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.find<MyEventsController>().fetchMyEvents();
      });
    }
  }

  Future<void> _handleCreateEventPress(MyEventsController controller) async {
    final currentEventCount = await controller.getUserEventCount();
    if (currentEventCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'You can only create up to 3 events. Please delete an existing event to create a new one.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    Get.toNamed(RouteHelper.createEventForm);
  }

  void _showDeleteConfirmationDialog(BuildContext context,
      MyEventsController controller, Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: Text(
              'Are you sure you want to delete "${event['eventName'] ?? 'this event'}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteEvent(event['id']);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
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
          // Add icon button with event counter
          action: [
            Stack(
              children: [
                ActionButtonIconWidget(
                  icon: Icons.add,
                  iconColor: MyColor.colorBlack,
                  backgroundColor: MyColor.colorWhite,
                  size: 60,
                  pressed: () => _handleCreateEventPress(controller),
                ),
                // Event counter badge
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: controller.userEvents.length >= 3
                          ? Colors.red
                          : MyColor.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${controller.userEvents.length}/3',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : controller.userEvents.isEmpty
                ? const EmptyEventsState()
                : EventsList(
                    controller: controller,
                    onEventLongPress: (event) {
                      // Show event context menu on long press
                      EventContextMenu.show(
                        context,
                        event,
                        controller,
                        () => _showDeleteConfirmationDialog(
                            context, controller, event),
                      );
                    },
                    onEventTap: (event) {
                      // Navigate to edit event form on tap
                      Get.toNamed(RouteHelper.editEventForm, arguments: event);
                    },
                  ),
      ),
    );
  }
}
