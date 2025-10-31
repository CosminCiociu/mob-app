import 'package:flutter/material.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/style.dart';

class PendingAttendeeCard extends StatelessWidget {
  final Map<String, dynamic> attendee;
  final VoidCallback? onAcceptTap;
  final VoidCallback? onDeclineTap;
  final VoidCallback? onProfileTap;

  const PendingAttendeeCard({
    Key? key,
    required this.attendee,
    this.onAcceptTap,
    this.onDeclineTap,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.space12),
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
          color: MyColor.memberPendingColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile Image
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: MyColor.memberPendingColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: attendee['profileImage'] != null &&
                        attendee['profileImage'].toString().isNotEmpty
                    ? Image.network(
                        attendee['profileImage'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar();
                        },
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
          ),

          const SizedBox(width: Dimensions.space12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendee['displayName'] ?? 'Unknown User',
                  style: boldDefault.copyWith(
                    color: MyColor.getTextColor(),
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (attendee['age'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${attendee['age']} years old',
                    style: regularSmall.copyWith(
                      color: MyColor.getTextColor().withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
                if (attendee['location'] != null &&
                    attendee['location'].toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: MyColor.getTextColor().withOpacity(0.6),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          attendee['location'],
                          style: regularSmall.copyWith(
                            color: MyColor.getTextColor().withOpacity(0.7),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                // Pending indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: MyColor.memberPendingColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pending Approval',
                    style: regularSmall.copyWith(
                      color: MyColor.memberPendingColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              // Accept Button
              GestureDetector(
                onTap: onAcceptTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MyColor.acceptColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: MyColor.acceptColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Decline Button
              GestureDetector(
                onTap: onDeclineTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MyColor.declineColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: MyColor.declineColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    String displayName = attendee['name'] ?? attendee['displayName'] ?? 'U';
    String initials =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Container(
      decoration: BoxDecoration(
        color: MyColor.memberPendingColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: boldDefault.copyWith(
            color: MyColor.memberPendingColor,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
