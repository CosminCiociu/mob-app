import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';

class InviteApprovalSelector extends StatelessWidget {
  final bool requiresApproval;
  final ValueChanged<bool> onChanged;
  final String label;

  const InviteApprovalSelector({
    Key? key,
    required this.requiresApproval,
    required this.onChanged,
    this.label = 'Invite Approval',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: MyColor.getTextColor(),
          ),
        ),
        const SizedBox(height: Dimensions.space8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: MyColor.getBorderColor()),
            borderRadius: BorderRadius.circular(8),
            color: MyColor.getCardBgColor(),
          ),
          child: Column(
            children: [
              // Auto-accept option
              _buildOption(
                title: 'Auto-accept invites',
                subtitle: 'Anyone can join immediately',
                icon: Icons.check_circle_outline,
                iconColor: Colors.green,
                isSelected: !requiresApproval,
                onTap: () => onChanged(false),
              ),

              Divider(
                height: 1,
                color: MyColor.getBorderColor(),
              ),

              // Approval required option
              _buildOption(
                title: 'Approval required',
                subtitle: 'Organizer must approve each invite',
                icon: Icons.person_add_alt_1,
                iconColor: Colors.orange,
                isSelected: requiresApproval,
                onTap: () => onChanged(true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.space15),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(Dimensions.space8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.cardRadius),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),

            const SizedBox(width: Dimensions.space12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: regularDefault.copyWith(
                      color: MyColor.getTextColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: regularSmall.copyWith(
                      color: MyColor.getSecondaryTextColor(),
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? MyColor.getPrimaryColor()
                      : MyColor.getBorderColor(),
                  width: 2,
                ),
                color:
                    isSelected ? MyColor.getPrimaryColor() : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: MyColor.colorWhite,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
