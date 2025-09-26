// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class OnBoardModel {
  String title;
  String subtitle;
  String image;
  bool isSvg;
  Color? bgcolor;
  IconData? icon;
  OnBoardModel({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.isSvg,
    this.bgcolor = MyColor.primaryColor,
    this.icon,
  });
}
