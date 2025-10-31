import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'widgets/event_image_header.dart';
import 'widgets/event_info_section.dart';
import 'widgets/action_buttons_widget.dart';
import 'widgets/event_back_button.dart';
import '../../../data/managers/event_manager.dart';
import '../../../domain/services/matching_service.dart';
import '../../../core/utils/home_controller_provider.dart';
import '../../../core/utils/my_strings.dart';
import '../../../data/controller/event_members_controller.dart';
import '../event/event_members_screen_v2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late Map<String, dynamic> eventData;
  late EventManager eventManager;

  @override
  void initState() {
    super.initState();
    // Get event data passed as arguments
    final args = Get.arguments;
    if (args is DocumentSnapshot) {
      eventData = (args.data() as Map<String, dynamic>?) ?? {};
      eventData['id'] = args.id;
    } else if (args is Map<String, dynamic>) {
      eventData = Map<String, dynamic>.from(args);
      // Try to get id from args or fallback
      if (!eventData.containsKey('id') || eventData['id'] == null) {
        if (args['id'] != null) {
          eventData['id'] = args['id'];
        }
      }
    } else {
      eventData = {};
    }
    eventManager = EventManager(Get.find<MatchingService>());
    // Set the single event for the details screen
    final eventId = eventData['id']?.toString();
    if (eventId != null && eventId.isNotEmpty) {
      eventManager.setSingleEvent(eventData, eventId);
    } else {
      // Optionally show error or pop
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid event data: missing id')),
        );
        Navigator.of(context).pop();
      });
    }
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
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: Dimensions.space10),
              height: MediaQuery.of(context).size.height * 0.7,
              alignment: Alignment.bottomCenter,
              child: EventActionButtonsWidget(
                onDecline: () {
                  // Only trigger swipe left on the main card stack
                  final homeController = HomeControllerProvider.instance;
                  homeController?.cardController?.triggerLeft();
                  Navigator.of(context).pop();
                },
                onJoin: () {
                  // Only trigger swipe right on the main card stack
                  final homeController = HomeControllerProvider.instance;
                  homeController?.cardController?.triggerRight();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
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

          // Members management section (only for event creators)
          _buildMembersSection(),

          // Add space for bottom action buttons
          const SizedBox(height: Dimensions.space100),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    // Check if current user is the event creator
    final currentUser = FirebaseAuth.instance.currentUser;
    final eventCreatorId = eventData['createdBy']?.toString();
    final isEventCreator = currentUser?.uid == eventCreatorId;

    if (!isEventCreator) {
      return const SizedBox.shrink(); // Don't show for non-creators
    }

    return Container(
      margin: const EdgeInsets.only(top: Dimensions.space20),
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.getCardColor(),
        borderRadius: BorderRadius.circular(Dimensions.space12),
        border: Border.all(
          color: MyColor.cardBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group,
                color: MyColor.primaryColor,
                size: 24,
              ),
              const SizedBox(width: Dimensions.space10),
              Text(
                MyStrings.eventMembers,
                style: TextStyle(
                  fontSize: Dimensions.fontLarge,
                  fontWeight: FontWeight.w600,
                  color: MyColor.getPrimaryTextColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space10),
          Text(
            'Manage who can join your event',
            style: TextStyle(
              fontSize: Dimensions.fontDefault,
              color: MyColor.getSecondaryTextColor(),
            ),
          ),
          const SizedBox(height: Dimensions.space15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openEventMembersScreen(),
              icon: const Icon(Icons.people_outline),
              label: Text(MyStrings.viewMembers),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.space12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.space8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEventMembersScreen() {
    final eventId = eventData['id']?.toString();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (eventId == null || currentUserId == null) {
      Get.snackbar(
        'Error',
        'Unable to load event members',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Initialize the controller with event data
    final controller = Get.put(EventMembersController());
    controller.eventId.value = eventId;
    controller.currentUserId.value = currentUserId;

    // Navigate to members screen
    Get.to(() => const EventMembersScreen());
  }
}
