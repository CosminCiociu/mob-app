import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../data/controller/event_members_controller.dart';
import 'event_members_screen_v2.dart';

class EventMembersDemoScreen extends StatelessWidget {
  const EventMembersDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppBar(
        title: const Text('Event Members Demo'),
        backgroundColor: MyColor.getAppBarColor(),
        foregroundColor: MyColor.getPrimaryTextColor(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group,
              size: 100,
              color: MyColor.primaryColor,
            ),
            const SizedBox(height: Dimensions.space30),
            Text(
              'Event Member Management',
              style: TextStyle(
                fontSize: Dimensions.fontHeader,
                fontWeight: FontWeight.bold,
                color: MyColor.getPrimaryTextColor(),
              ),
            ),
            const SizedBox(height: Dimensions.space15),
            Text(
              'Manage event members with accept/decline functionality',
              style: TextStyle(
                fontSize: Dimensions.fontDefault,
                color: MyColor.getSecondaryTextColor(),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.space50),
            ElevatedButton(
              onPressed: () => _openEventMembersScreen(),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.space40,
                  vertical: Dimensions.space15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.space12),
                ),
              ),
              child: Text(
                MyStrings.viewMembers,
                style: const TextStyle(
                  fontSize: Dimensions.fontLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.space20),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: Dimensions.space30),
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
                children: [
                  _buildFeatureItem(
                    Icons.check_circle_outline,
                    'Accept Members',
                    'Accept pending join requests',
                    MyColor.acceptColor,
                  ),
                  const SizedBox(height: Dimensions.space10),
                  _buildFeatureItem(
                    Icons.cancel_outlined,
                    'Decline Members',
                    'Decline unwanted requests',
                    MyColor.declineColor,
                  ),
                  const SizedBox(height: Dimensions.space10),
                  _buildFeatureItem(
                    Icons.message_outlined,
                    'Direct Message',
                    'Chat with event members',
                    MyColor.messageIconColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Dimensions.space8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: Dimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: Dimensions.fontDefault,
                  fontWeight: FontWeight.w600,
                  color: MyColor.getPrimaryTextColor(),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: Dimensions.fontSmall,
                  color: MyColor.getSecondaryTextColor(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openEventMembersScreen() {
    // Initialize controller with demo data
    final controller = Get.put(EventMembersController());

    // Set demo data
    controller.eventId.value = 'demo_event_123';
    controller.currentUserId.value = 'current_user_123';

    // Mock demo members data
    controller.confirmedMembers.value = [
      {
        'id': 'user1',
        'email': 'john.doe@example.com',
        'displayName': 'John Doe',
        'photoUrl': null,
      },
      {
        'id': 'user2',
        'email': 'jane.smith@example.com',
        'displayName': 'Jane Smith',
        'photoUrl': null,
      },
    ];

    controller.pendingMembers.value = [
      {
        'id': 'user3',
        'email': 'mike.wilson@example.com',
        'displayName': 'Mike Wilson',
        'photoUrl': null,
        'pendingTimestamp':
            (DateTime.now().millisecondsSinceEpoch / 1000).round() -
                3600, // 1 hour ago
      },
      {
        'id': 'user4',
        'email': 'sarah.johnson@example.com',
        'displayName': 'Sarah Johnson',
        'photoUrl': null,
        'pendingTimestamp':
            (DateTime.now().millisecondsSinceEpoch / 1000).round() -
                7200, // 2 hours ago
      },
    ];

    controller.isLoading.value = false;

    // Navigate to members screen
    Get.to(() => const EventMembersScreen());
  }
}
