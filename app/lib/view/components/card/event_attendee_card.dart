import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/style.dart';

class EventAttendeeCard extends StatelessWidget {
  final Map<String, dynamic> attendee;
  final VoidCallback? onChatTap;
  final VoidCallback? onProfileTap;
  final bool isCompact;

  const EventAttendeeCard({
    Key? key,
    required this.attendee,
    this.onChatTap,
    this.onProfileTap,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isCompact ? Dimensions.space10 : Dimensions.space15,
      ),
      padding: EdgeInsets.all(
        isCompact ? Dimensions.space12 : Dimensions.space15,
      ),
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        borderRadius: BorderRadius.circular(Dimensions.space12),
        boxShadow: [
          BoxShadow(
            color: MyColor.primaryColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: MyColor.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(),

          SizedBox(width: isCompact ? Dimensions.space10 : Dimensions.space12),

          // User Info
          Expanded(
            child: _buildUserInfo(),
          ),

          SizedBox(width: isCompact ? Dimensions.space8 : Dimensions.space10),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final double avatarSize = isCompact ? 40 : 48;

    return CircleAvatar(
      radius: avatarSize / 2,
      backgroundColor: MyColor.primaryColor.withOpacity(0.1),
      backgroundImage: attendee['profileImage'] != null &&
              attendee['profileImage'].toString().isNotEmpty
          ? NetworkImage(attendee['profileImage'])
          : null,
      child: attendee['profileImage'] == null ||
              attendee['profileImage'].toString().isEmpty
          ? Icon(
              Icons.person,
              size: avatarSize * 0.6,
              color: MyColor.primaryColor,
            )
          : null,
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Name
        Text(
          attendee['name'] ?? attendee['displayName'] ?? 'Anonymous User',
          style: isCompact
              ? boldDefault.copyWith(
                  color: MyColor.getTextColor(),
                  fontSize: 14,
                )
              : boldLarge.copyWith(
                  color: MyColor.getTextColor(),
                  fontSize: 16,
                ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        if (!isCompact) ...[
          const SizedBox(height: 2),

          // Additional info if available
          if (attendee['age'] != null || attendee['location'] != null)
            Text(
              _buildUserDetails(),
              style: regularSmall.copyWith(
                color: MyColor.getSecondaryTextColor(),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],

        // Join date or status
        if (attendee['joinedAt'] != null && !isCompact) ...[
          const SizedBox(height: 2),
          Text(
            'Joined ${_formatJoinDate(attendee['joinedAt'])}',
            style: regularSmall.copyWith(
              color: Colors.green.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chat Button
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          color: MyColor.primaryColor,
          onTap: () {
            HapticFeedback.lightImpact();
            onChatTap?.call();
          },
        ),

        if (!isCompact) ...[
          const SizedBox(width: Dimensions.space8),

          // Profile Button
          _buildActionButton(
            icon: Icons.person_outline,
            color: Colors.blue.shade600,
            onTap: () {
              HapticFeedback.lightImpact();
              onProfileTap?.call();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final double buttonSize = isCompact ? 32 : 36;
    final double iconSize = isCompact ? 16 : 18;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(buttonSize / 2),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: color,
        ),
      ),
    );
  }

  String _buildUserDetails() {
    final List<String> details = [];

    if (attendee['age'] != null) {
      details.add('${attendee['age']} years old');
    }

    if (attendee['location'] != null) {
      details.add(attendee['location']);
    }

    return details.join(' • ');
  }

  String _formatJoinDate(dynamic joinedAt) {
    try {
      DateTime date;
      if (joinedAt is String) {
        date = DateTime.parse(joinedAt);
      } else if (joinedAt is DateTime) {
        date = joinedAt;
      } else {
        return 'recently';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return 'recently';
      }
    } catch (e) {
      return 'recently';
    }
  }
}
