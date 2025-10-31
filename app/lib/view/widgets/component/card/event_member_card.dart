import 'package:flutter/material.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';

class EventMemberCard extends StatelessWidget {
  final String userId;
  final String userEmail;
  final String? userDisplayName;
  final String? userPhotoUrl;
  final DateTime? pendingTimestamp;
  final bool isConfirmed;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onMessage;

  const EventMemberCard({
    Key? key,
    required this.userId,
    required this.userEmail,
    this.userDisplayName,
    this.userPhotoUrl,
    this.pendingTimestamp,
    this.isConfirmed = false,
    this.onAccept,
    this.onDecline,
    this.onMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.space15,
        vertical: Dimensions.space8,
      ),
      decoration: BoxDecoration(
        color: MyColor.memberCardBackground,
        borderRadius: BorderRadius.circular(Dimensions.space12),
        border: Border.all(
          color: MyColor.cardBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.lShadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.space15),
        child: Row(
          children: [
            // User Avatar
            _buildUserAvatar(),
            const SizedBox(width: Dimensions.space12),

            // User Info
            Expanded(
              child: _buildUserInfo(),
            ),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MyColor.primaryColor.withOpacity(0.1),
        border: Border.all(
          color: MyColor.primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: userPhotoUrl != null && userPhotoUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                userPhotoUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              ),
            )
          : _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    String initials = '';
    if (userDisplayName != null && userDisplayName!.isNotEmpty) {
      List<String> nameParts = userDisplayName!.split(' ');
      if (nameParts.isNotEmpty) {
        initials = nameParts[0][0].toUpperCase();
        if (nameParts.length > 1) {
          initials += nameParts[1][0].toUpperCase();
        }
      }
    } else {
      initials = userEmail[0].toUpperCase();
    }

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: MyColor.primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display Name
        Text(
          userDisplayName ?? userEmail.split('@')[0],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MyColor.getPrimaryTextColor(),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Dimensions.space5),

        // Email
        Text(
          userEmail,
          style: TextStyle(
            fontSize: 14,
            color: MyColor.getSecondaryTextColor(),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Status and Timestamp
        if (!isConfirmed && pendingTimestamp != null) ...[
          const SizedBox(height: Dimensions.space5),
          _buildPendingInfo(),
        ] else if (isConfirmed) ...[
          const SizedBox(height: Dimensions.space5),
          _buildConfirmedInfo(),
        ],
      ],
    );
  }

  Widget _buildPendingInfo() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: MyColor.memberPendingColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: Dimensions.space7),
        Text(
          MyStrings.pending,
          style: const TextStyle(
            fontSize: 12,
            color: MyColor.memberPendingColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: Dimensions.space8),
        Text(
          _formatPendingTime(),
          style: TextStyle(
            fontSize: 12,
            color: MyColor.getSecondaryTextColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedInfo() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: MyColor.acceptColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: Dimensions.space7),
        Text(
          MyStrings.confirmedMember,
          style: const TextStyle(
            fontSize: 12,
            color: MyColor.acceptColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (isConfirmed) {
      // Show only message button for confirmed members
      return _buildMessageButton();
    } else {
      // Show accept/decline buttons for pending members
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAcceptButton(),
          const SizedBox(width: Dimensions.space8),
          _buildDeclineButton(),
          const SizedBox(width: Dimensions.space8),
          _buildMessageButton(),
        ],
      );
    }
  }

  Widget _buildAcceptButton() {
    return InkWell(
      onTap: onAccept,
      borderRadius: BorderRadius.circular(Dimensions.space8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space12,
          vertical: Dimensions.space8,
        ),
        decoration: BoxDecoration(
          color: MyColor.acceptColor,
          borderRadius: BorderRadius.circular(Dimensions.space8),
        ),
        child: Text(
          MyStrings.acceptRequest,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDeclineButton() {
    return InkWell(
      onTap: onDecline,
      borderRadius: BorderRadius.circular(Dimensions.space8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space12,
          vertical: Dimensions.space8,
        ),
        decoration: BoxDecoration(
          color: MyColor.declineColor,
          borderRadius: BorderRadius.circular(Dimensions.space8),
        ),
        child: Text(
          MyStrings.declineRequest,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageButton() {
    return InkWell(
      onTap: onMessage,
      borderRadius: BorderRadius.circular(Dimensions.space20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: MyColor.memberActionButton,
          shape: BoxShape.circle,
          border: Border.all(
            color: MyColor.messageIconColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.message_outlined,
          size: 18,
          color: MyColor.messageIconColor,
        ),
      ),
    );
  }

  String _formatPendingTime() {
    if (pendingTimestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(pendingTimestamp!);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
