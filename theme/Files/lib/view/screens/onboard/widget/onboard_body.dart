import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/core/utils/style.dart';
import 'package:ovo_meet/data/model/onboard/onboard_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class OnBoardBody extends StatelessWidget {
  OnBoardModel data;
  OnBoardBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: context.isLandscape ? width / 2 : height / 2,
            child: Center(
                child: data.isSvg
                    ? SvgPicture.asset(
                        data.image,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox.shrink()), // add image.network
          ),
          const SizedBox(height: Dimensions.space40),
          Text(
            data.title,
            style: title.copyWith(fontSize: 24, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.space25 - 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0),
            child: Text(
              data.subtitle,
              style: regularDefault.copyWith(color: const Color(0xff2D2B2E)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
