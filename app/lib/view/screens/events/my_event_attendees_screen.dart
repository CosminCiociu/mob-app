import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/style.dart';
import '../../../services/user_service.dart';
import '../../../domain/repositories/event_repository.dart';
import '../../../data/repositories/firebase_event_repository.dart';
import '../../../data/repositories/firebase_users_repository.dart';
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
  final EventRepository _eventRepository = FirebaseEventRepository();
  final FirebaseEventsRepository _eventsRepository = FirebaseEventsRepository();
  final FirebaseUsersRepository _usersRepository = FirebaseUsersRepository();
  final UserService _userService = UserService();

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
      // Get event data from Firebase
      final eventData = await _eventRepository.getEvent(widget.eventId);

      if (eventData == null) {
        throw Exception('Event not found');
      }

      // Load both confirmed and pending attendees
      await Future.wait([
        _loadConfirmedAttendees(eventData),
        _loadPendingAttendees(eventData),
      ]);

      if (mounted) {
        setState(() {
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

  Future<void> _loadConfirmedAttendees(Map<String, dynamic> eventData) async {
    // Get attendees array from event data
    final List<dynamic> attendeeIds = eventData['attendees'] ?? [];
    final List<Map<String, dynamic>> attendeesList = [];

    for (String attendeeId in attendeeIds.cast<String>()) {
      final attendeeData = await _fetchUserData(attendeeId, eventData);
      if (attendeeData != null) {
        attendeesList.add(attendeeData);
      }
    }

    if (mounted) {
      setState(() {
        _attendees = attendeesList;
      });
    }
  }

  Future<void> _loadPendingAttendees(Map<String, dynamic> eventData) async {
    // Get users_pending map from event data
    final Map<String, dynamic> usersPending = eventData['users_pending'] ?? {};
    final List<Map<String, dynamic>> pendingList = [];

    for (String userId in usersPending.keys) {
      final attendeeData = await _fetchUserData(userId, eventData);
      if (attendeeData != null) {
        // Add pending timestamp
        attendeeData['pendingTimestamp'] = usersPending[userId];
        pendingList.add(attendeeData);
      }
    }

    if (mounted) {
      setState(() {
        _pendingAttendees = pendingList;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchUserData(
      String userId, Map<String, dynamic> eventData) async {
    try {
      // Get user document from Firebase
      final userDoc = await _usersRepository.getUserById(userId);

      if (userDoc != null && userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;

        // Check if userData is null
        if (userData == null) {
          print('User data is null for user $userId');
          return {
            'id': userId,
            'name': 'Unknown User',
            'displayName': 'Unknown User',
            'profileImage': null,
            'age': null,
            'location': 'Location not set',
            'joinedAt': DateTime.now().toIso8601String(),
          };
        }

        // Get display name using UserService
        final displayName = await _userService.getUserDisplayName(userId);

        // Extract location information with robust null safety
        String locationText = 'Location not set';
        try {
          final location = userData['location'];
          if (location != null && location is Map<String, dynamic>) {
            // Try to get nested address structure first
            final address = location['address'];
            if (address != null && address is Map<String, dynamic>) {
              final locality = address['locality']?.toString() ?? '';
              final country = address['country']?.toString() ?? '';
              final fullAddress = address['fullAddress']?.toString() ?? '';

              if (locality.isNotEmpty && country.isNotEmpty) {
                locationText = '$locality, $country';
              } else if (fullAddress.isNotEmpty) {
                locationText = fullAddress;
              }
            }
            // Fallback to direct location fields
            else {
              final displayAddress =
                  location['displayAddress']?.toString() ?? '';
              final name = location['name']?.toString() ?? '';

              if (displayAddress.isNotEmpty) {
                locationText = displayAddress;
              } else if (name.isNotEmpty) {
                locationText = name;
              }
            }
          }
        } catch (e) {
          print('Error parsing location for user $userId: $e');
          locationText = 'Location not set';
        }

        // Calculate age if birthDate is available
        int? age;
        if (userData['birthDate'] != null) {
          try {
            DateTime birthDate;

            // Handle different birthDate formats
            if (userData['birthDate'] is Timestamp) {
              // Firestore Timestamp
              birthDate = (userData['birthDate'] as Timestamp).toDate();
            } else if (userData['birthDate'] is String) {
              // String format
              birthDate = DateTime.parse(userData['birthDate']);
            } else {
              // Unknown format, skip age calculation
              birthDate = DateTime.now();
            }

            final now = DateTime.now();
            age = now.year - birthDate.year;
            if (now.month < birthDate.month ||
                (now.month == birthDate.month && now.day < birthDate.day)) {
              age--;
            }
          } catch (e) {
            print('Error calculating age for user $userId: $e');
            // Ignore age calculation errors
          }
        }

        // Handle joinedAt timestamp properly
        String joinedAtString;
        try {
          if (eventData['createdAt'] is Timestamp) {
            joinedAtString = (eventData['createdAt'] as Timestamp)
                .toDate()
                .toIso8601String();
          } else if (eventData['createdAt'] is String) {
            joinedAtString = eventData['createdAt'];
          } else {
            joinedAtString = DateTime.now().toIso8601String();
          }
        } catch (e) {
          joinedAtString = DateTime.now().toIso8601String();
        }

        // Build attendee data structure
        return {
          'id': userId,
          'name': displayName,
          'displayName': displayName,
          'profileImage':
              userData['profileImageUrl'], // Use null if not available
          'age': age,
          'location': locationText,
          'joinedAt': joinedAtString,
          // Additional user data that might be useful
          'email': userData['email'],
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
        };
      } else {
        // Handle case where user document doesn't exist
        print('User document not found for ID: $userId');
        return {
          'id': userId,
          'name': 'Unknown User',
          'displayName': 'Unknown User',
          'profileImage': null,
          'age': null,
          'location': 'Location not set',
          'joinedAt': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      print('Error fetching data for user $userId: $e');
      // Return a fallback entry
      return {
        'id': userId,
        'name': 'Unknown User',
        'displayName': 'Unknown User',
        'profileImage': null,
        'age': null,
        'location': 'Location not set',
        'joinedAt': DateTime.now().toIso8601String(),
      };
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
