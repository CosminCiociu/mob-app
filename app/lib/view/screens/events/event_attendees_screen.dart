import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../services/user_service.dart';
import '../../../domain/repositories/event_repository.dart';
import '../../../data/repositories/firebase_event_repository.dart';
import '../../../data/repositories/firebase_users_repository.dart';
import '../../components/app-bar/custom_appbar.dart';
import '../../components/card/event_attendee_card.dart';
import '../../components/empty_state/empty_attendees_state.dart';

class EventAttendeesScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final List<Map<String, dynamic>>? attendees;

  const EventAttendeesScreen({
    Key? key,
    required this.eventId,
    required this.eventName,
    this.attendees,
  }) : super(key: key);

  @override
  State<EventAttendeesScreen> createState() => _EventAttendeesScreenState();
}

class _EventAttendeesScreenState extends State<EventAttendeesScreen> {
  late List<Map<String, dynamic>> _attendees;
  bool _isLoading = false;
  final EventRepository _eventRepository = FirebaseEventRepository();
  final FirebaseUsersRepository _usersRepository = FirebaseUsersRepository();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _attendees = widget.attendees ?? [];

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

      // Get attendees map from event data
      final Map<String, dynamic> attendeesMap = eventData['attendees'] ?? {};

      // Fetch user details for each attendee
      final List<Map<String, dynamic>> attendeesList = [];

      for (String attendeeId in attendeesMap.keys) {
        try {
          // Get user document from Firebase
          final userDoc = await _usersRepository.getUserById(attendeeId);

          if (userDoc != null && userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>?;

            // Check if userData is null
            if (userData == null) {
              print('User data is null for user $attendeeId');
              final attendeeData = {
                'id': attendeeId,
                'name': 'Unknown Userr',
                'displayName': 'Unknown Userr',
                'profileImage': null,
                'age': null,
                'location': 'Location not set',
                'joinedAt': DateTime.now().toIso8601String(),
              };
              attendeesList.add(attendeeData);
              continue;
            }

            // Get display name using UserService
            final displayName =
                await _userService.getUserDisplayName(attendeeId);

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
              print('Error parsing location for user $attendeeId: $e');
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
                print('Error calculating age for user $attendeeId: $e');
                // Ignore age calculation errors
              }
            }

            // Handle joinedAt timestamp from attendees map
            String joinedAtString;
            try {
              final attendeeData = attendeesMap[attendeeId];
              if (attendeeData != null &&
                  attendeeData is Map<String, dynamic>) {
                final joinedAt = attendeeData['joinedAt'];
                if (joinedAt is Timestamp) {
                  joinedAtString = joinedAt.toDate().toIso8601String();
                } else if (joinedAt is String) {
                  joinedAtString = joinedAt;
                } else {
                  joinedAtString = DateTime.now().toIso8601String();
                }
              } else {
                joinedAtString = DateTime.now().toIso8601String();
              }
            } catch (e) {
              joinedAtString = DateTime.now().toIso8601String();
            }

            // Build attendee data structure
            final attendeeData = {
              'id': attendeeId,
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

            attendeesList.add(attendeeData);
          } else {
            // Handle case where user document doesn't exist
            print('User document not found for ID: $attendeeId');
            final attendeeData = {
              'id': attendeeId,
              'name': 'Unknown Userr',
              'displayName': 'Unknown Userr',
              'profileImage': null,
              'age': null,
              'location': 'Location not set',
              'joinedAt': DateTime.now().toIso8601String(),
            };
            attendeesList.add(attendeeData);
          }
        } catch (e) {
          print('Error fetching data for attendee $attendeeId: $e');
          // Add a fallback entry for this attendee
          final attendeeData = {
            'id': attendeeId,
            'name': 'Unknown Userr',
            'displayName': 'Unknown Userr',
            'profileImage': null,
            'age': null,
            'location': 'Location not set',
            'joinedAt': DateTime.now().toIso8601String(),
          };
          attendeesList.add(attendeeData);
        }
      }

      if (mounted) {
        setState(() {
          _attendees = attendeesList;
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
        title: MyStrings.eventAttendees,
        isTitleCenter: true,
        isShowBackBtn: true,
        backButtonOnPress: () => Get.back(),
      ),
      body: Column(
        children: [
          // Event Info Header
          _buildEventInfoHeader(),

          // Attendees List
          Expanded(
            child: _buildAttendeesList(),
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
                  '${_attendees.length} ${_attendees.length == 1 ? 'attendee' : MyStrings.attendeesCountText}',
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

  Widget _buildAttendeesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_attendees.isEmpty) {
      return const EmptyAttendeesState();
    }

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
}
