import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/style.dart';
import '../../../data/repositories/firebase_events_repository.dart';
import '../../components/app-bar/custom_appbar.dart';
import '../../components/card/event_attendee_card.dart';
import '../../components/card/pending_attendee_card.dart';
import '../../components/empty_state/empty_attendees_state.dart';

class MyEventAttendeesScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final List<Map<String, dynamic>>? attendees;

  const MyEventAttendeesScreen({
    Key? key,
    required this.eventId,
    required this.eventName,
    this.attendees,
  }) : super(key: key);

  @override
  State<MyEventAttendeesScreen> createState() => _MyEventAttendeesScreenState();
}

class _MyEventAttendeesScreenState extends State<MyEventAttendeesScreen> {
  late List<Map<String, dynamic>> _attendees;
  late List<Map<String, dynamic>> _pendingAttendees;
  bool _isLoading = false;
  final FirebaseEventsRepository _eventsRepository = FirebaseEventsRepository();

  @override
  void initState() {
    super.initState();
    _attendees = widget.attendees ?? [];
    _pendingAttendees = [];

    // Always load attendees from Firebase to get latest data
    _loadAttendees();
  }

  Future<void> _loadAttendees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the repository method to get event members
      final eventMembers = await _eventsRepository.getEventMembers(
        eventId: widget.eventId,
      );

      if (mounted) {
        setState(() {
          _attendees = eventMembers['confirmed'] ?? [];
          _pendingAttendees = eventMembers['pending'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading attendees: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Get.snackbar(
          'Error',
          'Failed to load attendees: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: CustomAppBar(
        title: "Event Members",
        isTitleCenter: true,
        isShowBackBtn: true,
        backButtonOnPress: () => Get.back(),
      ),
      body: Column(
        children: [
          // Event Info Header
          _buildEventInfoHeader(),

          // Split view with tabs or sections
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildSplitView(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfoHeader() {
    return Container(
      margin: const EdgeInsets.all(Dimensions.space15),
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        borderRadius: BorderRadius.circular(Dimensions.space12),
        boxShadow: [
          BoxShadow(
            color: MyColor.primaryColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: MyColor.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Event Icon
          Container(
            padding: const EdgeInsets.all(Dimensions.space10),
            decoration: BoxDecoration(
              color: MyColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.space8),
            ),
            child: Icon(
              Icons.event,
              color: MyColor.primaryColor,
              size: 24,
            ),
          ),

          const SizedBox(width: Dimensions.space15),

          // Event Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.eventName,
                  style: boldLarge.copyWith(
                    color: MyColor.getTextColor(),
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_attendees.length} confirmed • ${_pendingAttendees.length} pending',
                  style: regularDefault.copyWith(
                    color: MyColor.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitView() {
    return Column(
      children: [
        // Pending Attendees Section
        if (_pendingAttendees.isNotEmpty) ...[
          _buildSectionHeader(
            'Pending Approval',
            _pendingAttendees.length,
            MyColor.memberPendingColor,
            icon: Icons.hourglass_empty,
          ),
          Expanded(
            child: _buildPendingAttendeesList(),
          ),
        ],

        // Divider if both sections have content
        if (_pendingAttendees.isNotEmpty && _attendees.isNotEmpty)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
            color: MyColor.getBorderColor(),
          ),

        // Confirmed Attendees Section
        if (_attendees.isNotEmpty) ...[
          _buildSectionHeader(
            'Confirmed Members',
            _attendees.length,
            MyColor.acceptColor,
            icon: Icons.check_circle,
          ),
          Expanded(
            child: _buildConfirmedAttendeesList(),
          ),
        ],

        // Empty state if no attendees at all
        if (_pendingAttendees.isEmpty && _attendees.isEmpty)
          const Expanded(child: EmptyAttendeesState()),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color,
      {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      margin: const EdgeInsets.only(
        left: Dimensions.space15,
        right: Dimensions.space15,
        top: Dimensions.space10,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.space8),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: Dimensions.space8),
          ],
          Text(
            title,
            style: boldDefault.copyWith(
              color: MyColor.getTextColor(),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space8,
              vertical: Dimensions.space5,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: boldDefault.copyWith(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAttendeesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space15,
        vertical: Dimensions.space10,
      ),
      itemCount: _pendingAttendees.length,
      itemBuilder: (context, index) {
        final attendee = _pendingAttendees[index];

        return PendingAttendeeCard(
          attendee: attendee,
          onAcceptTap: () => _acceptPendingAttendee(attendee),
          onDeclineTap: () => _declinePendingAttendee(attendee),
          onProfileTap: () => _onViewAttendeeProfile(attendee),
        );
      },
    );
  }

  Widget _buildConfirmedAttendeesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.space15,
        vertical: Dimensions.space10,
      ),
      itemCount: _attendees.length,
      itemBuilder: (context, index) {
        final attendee = _attendees[index];

        return EventAttendeeCard(
          attendee: attendee,
          onChatTap: () => _onChatWithAttendee(attendee),
          onProfileTap: () => _onViewAttendeeProfile(attendee),
        );
      },
    );
  }

  void _onChatWithAttendee(Map<String, dynamic> attendee) {
    // TODO: Implement chat functionality
    Get.snackbar(
      'Chat',
      'Opening chat with ${attendee['name'] ?? 'user'}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: MyColor.primaryColor.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Navigate to chat screen (implement when ready)
    // Get.toNamed(RouteHelper.chatScreen, arguments: {
    //   'userId': attendee['id'],
    //   'userName': attendee['name'],
    // });
  }

  void _onViewAttendeeProfile(Map<String, dynamic> attendee) {
    // TODO: Implement profile view functionality
    Get.snackbar(
      'Profile',
      'Viewing ${attendee['name'] ?? 'user'}\'s profile...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Navigate to profile screen (implement when ready)
    // Get.toNamed(RouteHelper.profileScreen, arguments: {
    //   'userId': attendee['id'],
    // });
  }

  Future<void> _acceptPendingAttendee(Map<String, dynamic> attendee) async {
    try {
      // Get current user ID (event organizer)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _eventsRepository.acceptMember(
        eventId: widget.eventId,
        userId: attendee['id'],
        currentUserId: currentUser.uid,
      );

      // Remove from pending list and add to confirmed list
      setState(() {
        _pendingAttendees
            .removeWhere((member) => member['id'] == attendee['id']);
        _attendees.add(attendee);
      });

      Get.snackbar(
        'Success',
        '${attendee['name'] ?? 'User'} has been accepted to the event',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: MyColor.acceptColor.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error accepting member: $e');
      Get.snackbar(
        'Error',
        'Failed to accept member: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _declinePendingAttendee(Map<String, dynamic> attendee) async {
    try {
      // Get current user ID (event organizer)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _eventsRepository.declineMember(
        eventId: widget.eventId,
        userId: attendee['id'],
        currentUserId: currentUser.uid,
      );

      // Remove from pending list
      setState(() {
        _pendingAttendees
            .removeWhere((member) => member['id'] == attendee['id']);
      });

      Get.snackbar(
        'Success',
        '${attendee['name'] ?? 'User'} has been declined',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: MyColor.declineColor.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error declining member: $e');
      Get.snackbar(
        'Error',
        'Failed to decline member: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}
