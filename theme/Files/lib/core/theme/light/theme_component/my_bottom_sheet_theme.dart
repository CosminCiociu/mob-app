import 'package:flutter/material.dart';
import 'package:ovo_meet/core/utils/my_color.dart';

class MyBottomSheetTheme {

  static BottomSheetThemeData get lightBottomSheetTheme => BottomSheetThemeData(
   elevation: 4,
   modalBackgroundColor: MyColor.getCardBgColor(),
    surfaceTintColor: MyColor.getSurfaceTintColor(),
   /*modalBarrierColor: ,
   modalElevation: ,
   shape: ,
   showDragHandle: ,*/
  );

  static BottomSheetThemeData get darkBottomSheetTheme => BottomSheetThemeData(
    elevation: 4,
    modalBackgroundColor: MyColor.getCardBgColor(),
    surfaceTintColor: MyColor.getSurfaceTintColor(),
    /*modalBarrierColor: ,
   modalElevation: ,
   shape: ,
   showDragHandle: ,*/
  );

}