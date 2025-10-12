import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/style.dart';

class EmptyEventsState extends StatelessWidget {
  const EmptyEventsState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: Dimensions.space60,
            color: MyColor.colorGrey.withOpacity(0.5),
          ),
          const SizedBox(height: Dimensions.space15),
          Text(
            'No events yet',
            style: boldLarge.copyWith(
              color: MyColor.colorGrey,
            ),
          ),
          const SizedBox(height: Dimensions.space8),
          Text(
            'Create your first event by tapping the + button',
            style: regularDefault.copyWith(
              color: MyColor.colorGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
