import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/core/utils/event_formatter.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/view/components/image/custom_svg_picture.dart';
import 'package:ovo_meet/core/route/route.dart';

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
                _buildImageHeader(),

                // Event details content
                _buildEventContent(),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: MyColor.colorWhite,
                  size: 24,
                ),
              ),
            ),
          ),

          // Action buttons at bottom (above bottom navigation bar)
          Positioned(
            bottom: 80, // Add space for bottom navigation bar
            left: 0,
            right: 0,
            child: _buildActionButtons(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildImageHeader() {
    final imageUrl = eventData['imageUrl'] as String?;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          if (imageUrl != null && imageUrl.isNotEmpty)
            Image.file(
              File(imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackImage();
              },
            )
          else
            _buildFallbackImage(),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // Event title and basic info overlay
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event name
                Text(
                  _getEventName(),
                  style: boldExtraLarge.copyWith(
                    color: MyColor.colorWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Quick info row
                Row(
                  children: [
                    // Date
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: MyColor.primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: MyColor.colorWhite,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(eventData['dateTime']),
                            style: boldSmall.copyWith(
                              color: MyColor.colorWhite,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Category
                    if (eventData['categoryId'] != null ||
                        eventData['category'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          (eventData['categoryId'] ?? eventData['category'])
                              .toString()
                              .toUpperCase(),
                          style: boldSmall.copyWith(
                            color: MyColor.primaryColor,
                            fontSize: 12,
                          ),
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
  }

  Widget _buildFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColor.primaryColor.withOpacity(0.8),
            MyColor.primaryColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event,
              size: 80,
              color: MyColor.colorWhite,
            ),
            const SizedBox(height: 16),
            Text(
              'Event Image',
              style: boldLarge.copyWith(
                color: MyColor.colorWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Looking for section
          _buildLookingForSection(),
          const SizedBox(height: 20),

          // Event details
          _buildEventDetailsSection(),
          const SizedBox(height: 20),

          // Time and location
          _buildTimeLocationSection(),
          const SizedBox(height: 20),

          // Attendees and constraints
          _buildAttendeesSection(),
          const SizedBox(height: 20),

          // Description
          if (eventData['details'] != null &&
              eventData['details'].toString().isNotEmpty)
            _buildDescriptionSection(),

          // Add space for bottom action buttons
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLookingForSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.search,
              size: 18,
              color: MyColor.getTextColor().withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              'Looking for',
              style: regularDefault.copyWith(
                color: MyColor.getTextColor().withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _getLookingForText(),
          style: boldDefault.copyWith(
            color: MyColor.getTextColor(),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColor.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MyColor.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Details',
            style: boldLarge.copyWith(
              color: MyColor.primaryColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),

          // Event type
          _buildDetailRow(
            Icons.category,
            'Category',
            (eventData['categoryId'] ?? eventData['category'] ?? 'General')
                .toString(),
          ),

          // Event status
          _buildDetailRow(
            Icons.info_outline,
            'Status',
            _getEventStatus(),
          ),

          // Created by
          if (eventData['createdBy'] != null)
            _buildDetailRow(
              Icons.person_outline,
              'Organized by',
              _getOrganizerName(),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeLocationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'When & Where',
            style: boldLarge.copyWith(
              color: Colors.blue.shade700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),

          // Start time
          _buildDetailRow(
            Icons.access_time,
            'Starts',
            _formatFullDateTime(eventData['dateTime']),
          ),

          // End time
          if (eventData['endDateTime'] != null)
            _buildDetailRow(
              Icons.access_time_filled,
              'Ends',
              _formatFullDateTime(eventData['endDateTime']),
            ),

          // Location
          _buildDetailRow(
            Icons.location_on,
            'Location',
            _getLocationString(),
          ),

          // Event type (in-person/virtual)
          if (eventData['inPersonOrVirtual'] != null)
            _buildDetailRow(
              Icons.event_seat,
              'Type',
              eventData['inPersonOrVirtual'].toString(),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendeesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendees & Requirements',
            style: boldLarge.copyWith(
              color: Colors.green.shade700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),

          // Current attendees
          _buildDetailRow(
            Icons.people,
            'Attendees',
            '${eventData['currentAttendees'] ?? 0}${eventData['maxAttendees'] != null ? '/${eventData['maxAttendees']}' : ''}',
          ),

          // Age restrictions
          if (eventData['minAge'] != null || eventData['maxAge'] != null)
            _buildDetailRow(
              Icons.person_outline,
              'Age Range',
              _getAgeRangeString(),
            ),

          // Price
          if (eventData['price'] != null && eventData['price'] != 0)
            _buildDetailRow(
              Icons.attach_money,
              'Price',
              '\$${eventData['price']}',
            ),

          // Distance (if available)
          _buildDetailRow(
            Icons.straighten,
            'Distance',
            '${(eventData['distance'] ?? 0.5).toStringAsFixed(1)} km away',
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this Event',
          style: boldLarge.copyWith(
            color: MyColor.getTextColor(),
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MyColor.getScreenBgColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            eventData['details'].toString(),
            style: regularDefault.copyWith(
              color: MyColor.getTextColor(),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: MyColor.getTextColor().withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: regularSmall.copyWith(
                    color: MyColor.getTextColor().withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: boldDefault.copyWith(
                    color: MyColor.getTextColor(),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MyColor.getScreenBgColor(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass/Dismiss button (X) - Decline
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                HapticFeedback.lightImpact();
                Get.back();
                _showSnackBar('Event declined');
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.space15),
                decoration: const BoxDecoration(
                  color: MyColor.lBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: const CustomSvgPicture(
                  image: MyImages.cancel,
                  color: MyColor.colorRed,
                  height: Dimensions.space12,
                ),
              ),
            ),
          ),

          // Join/Check button - Accept
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                HapticFeedback.lightImpact();
                _showJoinDialog();
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.space15),
                decoration: BoxDecoration(
                  color: MyColor.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: MyColor.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  color: MyColor.primaryColor,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getOrganizerName() {
    // Try to get organizer name from various possible fields
    if (eventData['organizerName']?.toString().isNotEmpty == true) {
      return eventData['organizerName'].toString();
    }

    if (eventData['creatorName']?.toString().isNotEmpty == true) {
      return eventData['creatorName'].toString();
    }

    // Check if userInfo exists and has a name
    final userInfo = eventData['userInfo'];
    if (userInfo is Map && userInfo['name']?.toString().isNotEmpty == true) {
      return userInfo['name'].toString();
    }
    if (userInfo is Map &&
        userInfo['displayName']?.toString().isNotEmpty == true) {
      return userInfo['displayName'].toString();
    }
    if (userInfo is Map &&
        userInfo['firstName']?.toString().isNotEmpty == true) {
      return userInfo['firstName'].toString();
    }

    // Fallback to user ID with nice formatting
    final userId = eventData['createdBy']?.toString() ??
        eventData['userId']?.toString() ??
        'Unknown';
    if (userId != 'Unknown' && userId.isNotEmpty) {
      if (userId.length > 10) {
        return 'User ${userId.substring(0, 8)}...'; // Show first 8 chars of ID
      }
      return 'User $userId';
    }

    return 'Unknown Organizer';
  }

  String _getEventName() {
    final eventName = eventData['eventName'];
    if (eventName != null && eventName.toString().trim().isNotEmpty) {
      return eventName.toString().trim();
    }

    // Fallback to category if no name
    final category = eventData['categoryId'] ?? eventData['category'];
    if (category != null) {
      return '${category.toString()} Event';
    }

    return 'Untitled Event';
  }

  String _formatDate(dynamic dateTime) {
    if (dateTime == null) return 'Date TBD';

    try {
      DateTime date;
      if (dateTime is DateTime) {
        date = dateTime;
      } else {
        date = DateTime.parse(dateTime.toString());
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final eventDate = DateTime(date.year, date.month, date.day);

      if (eventDate == today) {
        return 'Today';
      } else if (eventDate == today.add(const Duration(days: 1))) {
        return 'Tomorrow';
      } else {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${months[date.month - 1]} ${date.day}';
      }
    } catch (e) {
      return 'Date TBD';
    }
  }

  String _formatFullDateTime(dynamic dateTime) {
    if (dateTime == null) return 'TBD';

    try {
      DateTime date;
      if (dateTime is DateTime) {
        date = dateTime;
      } else {
        date = DateTime.parse(dateTime.toString());
      }

      final timeString =
          EventFormatter.formatEventTimeOnly(date.toIso8601String());
      final dateString =
          EventFormatter.formatEventDateOnly(date.toIso8601String());

      return '$dateString at $timeString';
    } catch (e) {
      return 'TBD';
    }
  }

  String _getLocationString() {
    final location = eventData['location'];
    if (location is Map<String, dynamic>) {
      final address = location['address'] as Map<String, dynamic>?;
      if (address != null) {
        final locality = address['locality'] as String?;
        final administrativeArea = address['administrativeArea'] as String?;
        if (locality != null && administrativeArea != null) {
          return '$locality, $administrativeArea';
        }
        return locality ?? administrativeArea ?? 'Location TBD';
      }
    }

    final locationName = eventData['locationName'];
    if (locationName != null && locationName.toString().isNotEmpty) {
      return locationName.toString();
    }

    return 'Location TBD';
  }

  String _getLookingForText() {
    final category = eventData['categoryId'] ?? eventData['category'];
    final attendees = eventData['currentAttendees'] ?? 0;

    if (category != null) {
      return 'People interested in ${category.toString().toLowerCase()} events';
    }

    if (attendees > 0) {
      return '$attendees people to join this amazing event';
    }

    return 'Fun people to join this event';
  }

  String _getEventStatus() {
    final dateTime = eventData['dateTime'];
    if (dateTime == null) return 'Scheduled';

    try {
      DateTime date;
      if (dateTime is DateTime) {
        date = dateTime;
      } else {
        date = DateTime.parse(dateTime.toString());
      }

      final now = DateTime.now();
      if (date.isAfter(now)) {
        return 'Upcoming';
      } else if (date.isBefore(now)) {
        final endTime = eventData['endDateTime'];
        if (endTime != null) {
          DateTime endDate;
          if (endTime is DateTime) {
            endDate = endTime;
          } else {
            endDate = DateTime.parse(endTime.toString());
          }
          if (endDate.isAfter(now)) {
            return 'Live Now';
          }
        }
        return 'Past Event';
      } else {
        return 'Starting Soon';
      }
    } catch (e) {
      return 'Scheduled';
    }
  }

  String _getAgeRangeString() {
    final minAge = eventData['minAge'];
    final maxAge = eventData['maxAge'];

    if (minAge != null && maxAge != null) {
      return '$minAge - $maxAge years';
    } else if (minAge != null) {
      return '$minAge+ years';
    } else if (maxAge != null) {
      return 'Under $maxAge years';
    }

    return 'All ages';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: MyColor.primaryColor,
      ),
    );
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Event'),
        content: Text('Would you like to join "${_getEventName()}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackBar('Successfully joined the event!');
              // Here you would typically update the event data
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.primaryColor,
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: MyColor.primaryColor,
        unselectedItemColor: MyColor.greyColor,
        currentIndex: 1, // Events tab is selected
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offNamedUntil(RouteHelper.bottomNavBar, (route) => false,
                  arguments: 0);
              break;
            case 1:
              Get.offNamedUntil(RouteHelper.bottomNavBar, (route) => false,
                  arguments: 1);
              break;
            case 2:
              Get.offNamedUntil(RouteHelper.bottomNavBar, (route) => false,
                  arguments: 2);
              break;
            case 3:
              Get.offNamedUntil(RouteHelper.bottomNavBar, (route) => false,
                  arguments: 3);
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              MyImages.presistentOnBoardImageOne,
              color: MyColor.greyColor,
              height: 24,
            ),
            activeIcon: Image.asset(
              MyImages.presistentOnBoardImageOne,
              color: MyColor.primaryColor,
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              MyImages.presistentOnBoardImageThree,
              color: MyColor.primaryColor,
              height: 24,
            ),
            activeIcon: Image.asset(
              MyImages.presistentOnBoardImageThree,
              color: MyColor.primaryColor,
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              MyImages.presistentOnBoardImageFour,
              color: MyColor.greyColor,
              height: 24,
            ),
            activeIcon: Image.asset(
              MyImages.presistentOnBoardImageFour,
              color: MyColor.primaryColor,
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              MyImages.presistentOnBoardImageFive,
              color: MyColor.greyColor,
              height: 24,
            ),
            activeIcon: Image.asset(
              MyImages.presistentOnBoardImageFive,
              color: MyColor.primaryColor,
              height: 24,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
