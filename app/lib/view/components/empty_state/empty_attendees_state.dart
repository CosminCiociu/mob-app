import 'package:flutter/material.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';

class EmptyAttendeesState extends StatelessWidget {
  final String? customMessage;
  final IconData? customIcon;

  const EmptyAttendeesState({
    Key? key,
    this.customMessage,
    this.customIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(Dimensions.space30),
            decoration: BoxDecoration(
              color: MyColor.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              customIcon ?? Icons.group_outlined,
              size: 60,
              color: MyColor.primaryColor.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: Dimensions.space20),

          // Title
          Text(
            MyStrings.noAttendeesYet,
            style: boldExtraLarge.copyWith(
              color: MyColor.getTextColor(),
              fontSize: 20,
            ),
          ),

          const SizedBox(height: Dimensions.space10),

          // Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.space40),
            child: Text(
              customMessage ?? MyStrings.waitingForPeople,
              style: regularDefault.copyWith(
                color: MyColor.getSecondaryTextColor(),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
