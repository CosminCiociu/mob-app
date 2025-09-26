import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:ovo_meet/core/utils/my_images.dart';
import 'package:ovo_meet/data/controller/search_connection/search_connection_controller.dart';
import 'package:get/get.dart';

class SearchConnectionScreen extends StatefulWidget {
  const SearchConnectionScreen({super.key});

  @override
  State<SearchConnectionScreen> createState() => _SearchConnectionScreenState();
}

class _SearchConnectionScreenState extends State<SearchConnectionScreen> {
  @override
  void initState() {
    super.initState();

  
     Get.put(SearchConnectionController());


      print("Activating route after 4 seconds...");
      Future.delayed(Duration(seconds: 4), () {
           print("Activating ...");
        Get.toNamed(RouteHelper.matchScreen);
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.portrait) {
      print("Screen is in vertical orientation (Portrait)");
    } else if (orientation == Orientation.landscape) {
      print("Screen is in horizontal orientation (Landscape)");
    }

    List<double> radii = [
      orientation == Orientation.portrait ? min(size.width, size.height) * 0.4 : 45,
      orientation == Orientation.portrait ? min(size.width, size.height) * 0.3 : 120,
      orientation == Orientation.portrait ? min(size.width, size.height) * 0.4 : 65,
      orientation == Orientation.portrait ? min(size.width, size.height) * 0.35 : 125,
      orientation == Orientation.portrait ? min(size.width, size.height) * 0.1 : 90,
      orientation == Orientation.portrait ? min(size.width, size.height) * 0.3 : 150,
    ];

    return GetBuilder<SearchConnectionController>(
      builder: (controller) => Scaffold(
        body: Stack(
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Image.asset(
                MyImages.map,
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: CircleAvatar(
                backgroundColor: MyColor.transparentColor,
                backgroundImage: const AssetImage(MyImages.network),
                radius: orientation == Orientation.portrait ? size.width * 0.5 : size.width * 0.2,
              ),
            ),
            Stack(
              children: controller.buildCircleImages(size, radii, controller.imagePaths, context),
            ),
          ],
        ),
      ),
    );
  }
}
