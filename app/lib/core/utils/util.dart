import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ovo_meet/core/utils/dimensions.dart';
import 'package:ovo_meet/data/model/global/formdata/global_keyc_formData.dart';
import 'package:get/get.dart';
import 'package:ovo_meet/core/utils/my_color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'my_strings.dart';

class MyUtils {

  static splashScreen() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: MyColor.getPrimaryColor(), statusBarIconBrightness: Brightness.light, systemNavigationBarColor: MyColor.getPrimaryColor(), systemNavigationBarIconBrightness: Brightness.light));
  }

  static allScreen() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: MyColor.getPrimaryColor(), statusBarIconBrightness: Brightness.light, systemNavigationBarColor: MyColor.getWhiteColor(), systemNavigationBarIconBrightness: Brightness.dark));
  }

  static dynamic getShadow({
    Color? color,
    Offset? offset,
    double? blurRadius,
    double? spreadRadius,
  }) {
    return [
      BoxShadow(
        blurRadius: blurRadius ?? 15.0,
        offset: offset ?? const Offset(0, 25),
        color: color ?? MyColor.getGreyColorwithShade500().withOpacity(0.6),
        spreadRadius: spreadRadius ?? -35.0,
      ),
    ];
  }

  static dynamic getShadow2({
    double blurRadius = 8,
    Color? color,
    Offset? offset,
    double? spreadRadius,
  }) {
    return [
      BoxShadow(
        blurRadius: blurRadius,
        offset: offset ?? const Offset(0, 25),
        color: color ?? MyColor.getGreyColorwithShade500().withOpacity(0.6),
        spreadRadius: spreadRadius ?? -35.0,
      ),
      BoxShadow(
        blurRadius: blurRadius,
        offset: offset ?? const Offset(0, 1),
        color: color ?? MyColor.getGreyColorwithShade500().withOpacity(0.6),
        spreadRadius: spreadRadius ?? 1,
      ),
    ];
  }

  static dynamic getBottomSheetShadow() {
    return [
      BoxShadow(
        color: MyColor.getGreyColorwithShade500().withOpacity(0.08),
        spreadRadius: 3,
        blurRadius: 4,
        offset: const Offset(0, 3),
      ),
    ];
  }

  static dynamic getCardShadow() {
    return [
      BoxShadow(
        color: MyColor.getShadowColor().withOpacity(0.05),
        spreadRadius: 2,
        blurRadius: 2,
        offset: const Offset(0, 3),
      ),
    ];
  }

  static getOperationTitle(String value) {
    String number = value;
    RegExp regExp = RegExp(r'^(\d+)(\w+)$');
    Match? match = regExp.firstMatch(number);
    if (match != null) {
      String? num = match.group(1) ?? '';
      String? unit = match.group(2) ?? '';
      String title = '${MyStrings.last.tr} $num ${unit.capitalizeFirst}';
      return title.tr;
    } else {
      return value.tr;
    }
  }

  String maskSensitiveInformation(String input) {
    if (input.isEmpty) {
      return '';
    }

    final int maskLength = input.length ~/ 2; // Mask half of the characters.
    final String mask = '*' * maskLength;
    final String maskedInput = maskLength > 4 ? input.replaceRange(5, maskLength, mask) : input.replaceRange(0, maskLength, mask);
    return maskedInput;
  }

  static List<GlobalFormModle> dynamicFormSelectValueFormatter(List<GlobalFormModle>? dynamicFormList) {
    List<GlobalFormModle> mainFormList = [];

    if (dynamicFormList != null && dynamicFormList.isNotEmpty) {
      mainFormList.clear();

      for (var element in dynamicFormList) {
        if (element.type == 'select') {
          bool? isEmpty = element.options?.isEmpty;
          bool empty = isEmpty ?? true;
          if (element.options != null && empty != true) {
            if (!element.options!.contains(MyStrings.selectOne)) {
              element.options?.insert(0, MyStrings.selectOne);
            }

            element.selectedValue = element.options?.first;
            mainFormList.add(element);
          }
        } else {
          mainFormList.add(element);
        }
      }
    }
    return mainFormList;
  }

  List<Row> makeTwoPairWidget({required List<Widget> widgets}) {
    List<Row> pairs = [];
    for (int i = 0; i < widgets.length; i += 2) {
      Widget first = widgets[i];
      Widget? second = (i + 1 < widgets.length) ? widgets[i + 1] : const SizedBox();

      pairs.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Expanded(child: first), const SizedBox(width: Dimensions.space15), Expanded(child: second)],
        ),
      );
    }

    return pairs;
  }

  void stopLandscape() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  static Future<void> launchUrlToBrowser(String downloadUrl) async {
    try {
      final Uri url = Uri.parse(downloadUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static bool isImage(String path) {
    if (path.contains('.jpg')) {
      return true;
    }
    if (path.contains('.png')) {
      return true;
    }
    if (path.contains('.jpeg')) {
      return true;
    }
    return false;
  }

  static bool isXlsx(String path) {
    if (path.contains('.xlsx')) {
      return true;
    }
    if (path.contains('.xls')) {
      return true;
    }
    if (path.contains('.xlx')) {
      return true;
    }
    return false;
  }

  static bool isDoc(String path) {
    if (path.contains('.doc')) {
      return true;
    }
    if (path.contains('.docs')) {
      return true;
    }
    return false;
  }

  static bool isURL(String urlString) {
    Uri? uri = Uri.tryParse(urlString);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

}
