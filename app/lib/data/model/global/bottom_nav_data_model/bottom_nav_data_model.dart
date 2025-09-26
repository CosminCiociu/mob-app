// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart';

class BottomNavItemModel {
  int index;
  String name;
  String image;
  bool? isIconData = false;
  IconData? icon;

  BottomNavItemModel({
    required this.index,
    required this.name,
    required this.image,
    this.isIconData,
    this.icon,
  });
}
