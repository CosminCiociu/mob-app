import 'package:flutter/material.dart';
import 'package:ovo_meet/core/route/route.dart';
import 'package:ovo_meet/view/screens/homescreen/widgets/swipe_image.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  CardController? cardController;
  final ZoomDrawerController drawerController = ZoomDrawerController();
  List<String> girlsImages = [
    "assets/images/girl1.jpg",
    "assets/images/girl2.jpg",
    "assets/images/girl3.jpg",
    "assets/images/girl4.jpg",
  ];
  int distance = 10;
  int age = 10;
  String selectedAddress = "";
  final bool resetSwiper = false;
  final TextEditingController addressController = TextEditingController();
  chnageSelectedAddress(String address) {
    addressController.clear();
    addressController.text = address;
    update();
  }

  RangeValues rangeValues = RangeValues(10, 50);
  int currentIndex = 0;
  List<String> names = [
    "Alexa, 22",
    "Bella, 32",
    "Catherine, 21",
    "Diana, 18",
    "Emily, 14",
    "Fiona, 18"
  ];

  List<Map<String, String>> addresses = [
    {
      'street': '123 Main Street',
    },
    {
      'street': '456 Elm Road',
    },
    {
      'street': '789 Maple Avenue',
    },
    {
      'street': '101 Oak Drive',
    },
    {
      'street': '202 Pine Street',
    },
    {
      'street': '303 Cedar Lane',
    },
    {
      'street': '404 Birch Boulevard',
    },
    {
      'street': '505 Walnut Court',
    },
    {
      'street': '606 Spruce Place',
    },
    {
      'street': '707 Willow Terrace',
    }
  ];
  List<Map<String, dynamic>> interestedIn = [
    {'genders': 'Men', 'status': false},
    {'genders': 'Women', 'status': false},
    {'genders': 'Other', 'status': false},
  ];
  void resetCurrentIndex() {
    currentIndex = 0;
    print("object666");

    update();
  }

  @override
  void onInit() {
    super.onInit();
    resetCurrentIndex();
  }

  void resetCardController() {
    cardController = CardController();
    update();
  }

  void onSwipeComplete(CardSwipeOrientation orientation, int index) {
    // Calculate the new currentIndex by using modulo, creating an endless loop
    currentIndex = (index + 1) % girlsImages.length;

    update(); // Update the UI
  }

  changeStatus(int index) {
    interestedIn[index]['status'] = !interestedIn[index]['status'];
    update();
  }
}
