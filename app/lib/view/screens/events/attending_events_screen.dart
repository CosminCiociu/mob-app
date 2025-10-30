import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/data/controller/events/attending_events_controller.dart';
import 'package:ovo_meet/domain/services/attending_events_service.dart';
import 'package:ovo_meet/view/components/app-bar/custom_appbar.dart';
import 'package:ovo_meet/view/components/empty_state/empty_attending_events_state.dart';
import 'package:ovo_meet/view/components/card/attending_event_card.dart';
import 'package:url_launcher/url_launcher.dart';

class AttendingEventsScreen extends StatefulWidget {
  const AttendingEventsScreen({super.key});

  @override
  State<AttendingEventsScreen> createState() => _AttendingEventsScreenState();
}

class _AttendingEventsScreenState extends State<AttendingEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize controller
    if (!Get.isRegistered<AttendingEventsController>()) {
      Get.put(AttendingEventsController());
    } else {
      // Refresh data when screen is reopened
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.find<AttendingEventsController>().fetchAttendingEvents();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttendingEventsController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: CustomAppBar(
          title: MyStrings.attendingEvents,
          isTitleCenter: true,
          isShowBackBtn: true,
          backButtonOnPress: () {
            Get.offAllNamed(RouteHelper.bottomNavBar);
          },
        ),
        body: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : !controller.hasAnyEvents
                ? const EmptyAttendingEventsState()
                : Column(
                    children: [
                      // Tab Bar
                      _buildTabBar(controller),

                      // Tab Content
                      Expanded(
                        child: _buildTabContent(controller),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTabBar(AttendingEventsController controller) {
    return Container(
      margin: const EdgeInsets.all(Dimensions.space20),
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        borderRadius: BorderRadius.circular(Dimensions.space15),
        boxShadow: [
          BoxShadow(
            color: MyColor.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          controller.switchTab(AttendingEventTab.values[index]);
        },
        indicator: BoxDecoration(
          color: MyColor.primaryColor,
          borderRadius: BorderRadius.circular(Dimensions.space15),
        ),
        labelColor: MyColor.colorWhite,
        unselectedLabelColor: MyColor.getTextColor().withOpacity(0.6),
        labelStyle: boldSmall.copyWith(fontSize: 12),
        unselectedLabelStyle: regularSmall.copyWith(fontSize: 12),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          _buildTab(
            MyStrings.upcoming,
            controller.upcomingEvents.length,
            Icons.schedule,
          ),
          _buildTab(
            MyStrings.active,
            controller.activeEvents.length,
            Icons.play_circle_filled,
          ),
          _buildTab(
            MyStrings.past,
            controller.pastEvents.length,
            Icons.history,
          ),
          _buildTab(
            MyStrings.pendingApproval,
            controller.pendingEvents.length,
            Icons.hourglass_empty,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int count, IconData icon) {
    return Tab(
      height: 60,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 4),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(AttendingEventsController controller) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildEventsList(controller.upcomingEvents, controller, false),
        _buildEventsList(controller.activeEvents, controller, false),
        _buildEventsList(controller.pastEvents, controller, false),
        _buildEventsList(controller.pendingEvents, controller, true),
      ],
    );
  }

  Widget _buildEventsList(
    List<Map<String, dynamic>> events,
    AttendingEventsController controller,
    bool isPending,
  ) {
    if (events.isEmpty) {
      return _buildEmptyTabState(isPending);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.space20),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return AttendingEventCard(
            event: event,
            isPending: isPending,
            onTap: () => _navigateToEventDetails(event),
            onLeave: () => _showLeaveEventDialog(controller, event),
            onToggleReminder: () => _toggleReminder(controller, event),
            onChatWithHost: () => _chatWithHost(event),
            onViewMap: () => _viewOnMap(event),
          );
        },
      ),
    );
  }

  Widget _buildEmptyTabState(bool isPending) {
    String emptyMessage;
    IconData emptyIcon;

    if (isPending) {
      emptyMessage = "No pending events";
      emptyIcon = Icons.hourglass_empty;
    } else {
      emptyMessage = "No events in this category";
      emptyIcon = Icons.event_busy;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            emptyIcon,
            size: 60,
            color: MyColor.getTextColor().withOpacity(0.3),
          ),
          const SizedBox(height: Dimensions.space20),
          Text(
            emptyMessage,
            style: regularLarge.copyWith(
              color: MyColor.getTextColor().withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEventDetails(Map<String, dynamic> event) {
    Get.toNamed(RouteHelper.eventDetailsScreen, arguments: event);
  }

  void _showLeaveEventDialog(
    AttendingEventsController controller,
    Map<String, dynamic> event,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leave Event'),
          content: Text(
              'Are you sure you want to leave "${event['eventName'] ?? 'this event'}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.leaveEvent(event['id']);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  void _toggleReminder(
    AttendingEventsController controller,
    Map<String, dynamic> event,
  ) {
    final currentStatus = event['hasReminder'] ?? false;
    controller.toggleReminder(event['id'], currentStatus);
  }

  void _chatWithHost(Map<String, dynamic> event) {
    // TODO: Implement chat functionality
    Get.snackbar(
      'Coming Soon',
      'Chat with host feature will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _viewOnMap(Map<String, dynamic> event) async {
    // Extract location data
    final locationData = event['locationData'];

    if (locationData != null &&
        locationData['latitude'] != null &&
        locationData['longitude'] != null) {
      final lat = locationData['latitude'];
      final lng = locationData['longitude'];

      // Create Google Maps URL
      final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch maps';
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Could not open maps. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        'Location Not Available',
        'Location information is not available for this event.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
