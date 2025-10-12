import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/route/route.dart';

import 'widgets/event_image_header.dart';
import 'widgets/event_info_section.dart';
import 'widgets/event_action_buttons.dart';
import 'widgets/event_back_button.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late Map<String, dynamic> eventData;

  @override
  void initState() {
    super.initState();
    // Get event data passed as arguments
    eventData = Get.arguments as Map<String, dynamic>? ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image header with overlay
                EventImageHeader(eventData: eventData),

                // Event details content
                _buildEventContent(),
              ],
            ),
          ),

          // Back button
          const EventBackButton(),

          // Action buttons at bottom (above bottom navigation bar)
          Positioned(
            bottom: 80, // Add space for bottom navigation bar
            left: 0,
            right: 0,
            child: EventActionButtons(eventData: eventData),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildEventContent() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Looking for section
          EventInfoSection(
            eventData: eventData,
            sectionType: EventInfoSectionType.lookingFor,
          ),
          const SizedBox(height: Dimensions.space20),

          // Event details
          EventInfoSection(
            eventData: eventData,
            sectionType: EventInfoSectionType.eventDetails,
          ),
          const SizedBox(height: Dimensions.space20),

          // Time and location
          EventInfoSection(
            eventData: eventData,
            sectionType: EventInfoSectionType.timeLocation,
          ),
          const SizedBox(height: Dimensions.space20),

          // Attendees and constraints
          EventInfoSection(
            eventData: eventData,
            sectionType: EventInfoSectionType.attendees,
          ),
          const SizedBox(height: Dimensions.space20),

          // Description
          EventInfoSection(
            eventData: eventData,
            sectionType: EventInfoSectionType.description,
          ),

          // Add space for bottom action buttons
          const SizedBox(height: Dimensions.space100),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    // Use a simple container to maintain space, actual navigation handled by persistent nav
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Dimensions.space10)),
        boxShadow: [
          BoxShadow(
            color: MyColor.colorBlack.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            // Navigate back to the events tab in the main navigation
            Get.offNamedUntil(RouteHelper.bottomNavBar, (route) => false,
                arguments: 1);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space20,
              vertical: Dimensions.space10,
            ),
            decoration: BoxDecoration(
              color: MyColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.space20),
              border: Border.all(
                color: MyColor.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Back to Events',
              style: TextStyle(
                color: MyColor.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.fontDefault,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
