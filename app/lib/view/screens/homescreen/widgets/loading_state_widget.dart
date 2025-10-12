import 'package:flutter/material.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: MyColor.buttonColor,
            ),
            const SizedBox(height: 20),
            Text(
              MyStrings.loadingNearbyEvents,
              style: regularLarge.copyWith(
                color: MyColor.buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
