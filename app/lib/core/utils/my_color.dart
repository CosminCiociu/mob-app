import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controller/common/theme_controller.dart';

class MyColor {
  // Dark theme colors - Hobby Matching App Theme
  static const Color dBackgroundColor = Color(0xFF1A1D2E); // Deep midnight blue
  static const Color dCircleColor = greyColor;
  static const Color dTextColor = Color(0xFFFFFFFF);
  static const Color dSubtitleColor = Color(0xFFD4D4D4);
  static const Color dDividerColor = Color(0xFFECECEC);
  static const Color dheadingTextColor = Color(0xFFCECECE);
  static const Color dInputTextColor = Color(0xFFFFFFFF);
  static const Color dPrimaryTextColor = Color(0xFFFFFFFF);
  static const Color dSecondaryTextColor = Color(0xFFB0B0B0);
  static const Color dAccentSecondaryColor =
      Color(0xFFFF6B9D); // Warm pink accent
  static const Color dIconColor = Color(0xFFFFFFFF);
  static const Color dHighlightColor =
      Color(0xFFFF6B9D); // Matching pink highlight
  static const Color dCardColor = Color(0xFF252A44); // Rich navy cards
  static const Color dBorderColor = Color(0xFF8B929C); // Muted borders
  static const Color dShadowColor = Color(0xFF2B303D); // Deep shadows

  // Light theme colors - Hobby Matching App Theme
  static const Color lBackgroundColor = Color(0xFFFFFBFE); // Warm white
  static const Color lTextColor = Color(0xFF1C1B1F); // Rich dark text
  static const Color lCircleColor = colorWhite;
  static const Color lPrimaryTextColor = Color(0xFF1C1B1F);
  static const Color lSubtitleColor = Color(0xFF625B71); // Muted purple
  static const Color lDividerColor = Color(0xFFE6E0E9); // Soft lavender
  static const Color lInputTextColor = Color(0xFF1C1B1F);
  static const Color lSecondaryTextColor = Color(0xFF625B71);
  static const Color lAccentSecondaryColor = Color(0xFFFF6B9D); // Warm pink
  static const Color lHighlightColor = Color(0xFFFF6B9D); // Matching pink
  static const Color lCardColor = Color(0xFFFFFFFF);
  static const Color lBorderColor = Color(0xFFE6E0E9); // Soft border
  static const Color lIconColor = Color(0xFF1C1B1F);
  static const Color lShadowColor = Color(0xFFE6E0E9);
  static const Color ticketDateColor = Color(0xff888888);
  static const Color ticketDetails = Color(0xff5D5D5D);
  static const Color cancelRedColor = Color(0xffFF3B30);
  static const Color greyColor = Color(0xff808080);
  static Color greyColorWithShadeFiveHundred = Colors.grey.shade500;
  static Color greyColorWithShadeFourHundred = Colors.grey.shade400;

  static const Color delteBtnTextColor = Color(0xff6C3137);
  static const Color delteBtnColor = Color(0xffFDD6D7);
  static const Color colorGrey2 = Color(0xffEDF2F6);
  static const Color cardBorderColor = Color(0xffE7E7E7);
  static const Color depositTextColor = Color(0xff454545);
  static const Color buttonColor = Color(0xFFFF6B9D); // Warm pink buttons

  // Hobby matching theme colors
  static const Color primaryColor = Color(0xFFFF6B9D); // Warm pink primary
  static const Color secondaryColor = Color(0xFF6366F1); // Indigo secondary
  static const Color accentColor = Color(0xFFFFAB00); // Amber accent
  static const Color socialColor =
      Color(0xFF10B981); // Emerald for social features

  static Color getColorById(int index) {
    List<String> randomColors = [
      '#2196F3',
      '#4CAF50',
      '#FF9800',
      '#9C27B0',
      '#00BCD4',
      '#795548',
      '#607D8B',
      '#3F51B5',
      '#009688',
      '#FF5722',
    ];

    if (index >= 0 && index < randomColors.length) {
      return Color(
          int.parse(randomColors[index].substring(1), radix: 16) + 0xFF000000);
    } else {
      return Colors.black;
    }
  }

  static Color getFocusColor() {
    return focusColor;
  }

  static Color getGreenColor() {
    return greenP;
  }

  static Color getTicketDetailsColor() {
    return ticketDetails;
  }

  static Color getDepositTextColor() {
    return depositTextColor;
  }

  static Color getDeleteButtonColor() {
    return delteBtnColor;
  }

  static Color getDeleteButtonTextColor() {
    return delteBtnTextColor;
  }

  static Color getGreyText1() {
    return MyColor.colorBlack.withOpacity(0.6);
  }

  static Color getSubtitleTextColorText() {
    return Get.find<ThemeController>().darkTheme
        ? MyColor.dSubtitleColor.withOpacity(0.8)
        : MyColor.lSubtitleColor.withOpacity(0.8);
  }

  static Color getCardColor() {
    return Get.find<ThemeController>().darkTheme
        ? MyColor.dCardColor.withOpacity(0.8)
        : MyColor.colorBlack.withOpacity(0.8);
  }

  static Color getSplashColor() {
    return focusColor;
  }

  static Color getRedColor() {
    return colorRed;
  }

  static Color getRedCancelTextColor() {
    return redCancelTextColor;
  }

  static Color getContentTextColor() {
    return contentTextColor;
  }

  static Color getLabelTextColor() {
    return labelTextColor;
  }

  static Color getHintTextColor() {
    return hintTextColor;
  }

  static Color getTextFieldDisableBorder() {
    return textFieldDisableBorderColor;
  }

  static Color getTextFieldFillColor() {
    return textFieldFillColor;
  }

  static Color getTextFieldEnableBorder() {
    return textFieldEnableBorderColor;
  }

  static Color getPrimaryButtonColor() {
    return primaryColor;
  }

  static Color getSecondaryButtonTextColor() {
    return secondaryButtonTextColor;
  }

  static Color getTransparentColor() {
    return transparentColor;
  }

  static Color getTextColor() {
    return Get.find<ThemeController>().darkTheme ? dTextColor : lTextColor;
  }

  static Color getInputTextColor() {
    return Get.find<ThemeController>().darkTheme
        ? dInputTextColor
        : lInputTextColor;
  }

  static Color getBottomNavBgColor() {
    return colorWhite;
  }

  static Color getSurfaceTintColor() {
    return colorWhite;
  }

  static Color getGreyText() {
    return MyColor.colorBlack.withOpacity(0.5);
  }

  static Color getGreyColor() {
    return MyColor.greyColor;
  }

  static Color getPendingColor() {
    return MyColor.pendingColor;
  }

  static Color getCurrencyBoxColor() {
    return currencyBoxColor;
  }

  static Color getWhiteColor() {
    return MyColor.colorWhite;
  }

  static Color getBlackColor() {
    return MyColor.colorBlack;
  }

  static Color getAppBarColor() {
    return Get.find<ThemeController>().darkTheme
        ? dBackgroundColor
        : colorWhite;
  }

  static Color getCircleColor() {
    return Get.find<ThemeController>().darkTheme ? dCircleColor : lCircleColor;
  }

  static Color getDividerColor() {
    return Get.find<ThemeController>().darkTheme
        ? dDividerColor
        : lDividerColor;
  }

  static Color getAppBarContentColor() {
    return appBarContentColor;
  }

  static Color getContentColor() {
    return contentTextColor;
  }

  static Color getGreyColorwithShade500() {
    return greyColorWithShadeFiveHundred;
  }

  static Color getGreyColorwithShade400() {
    return greyColorWithShadeFourHundred;
  }

  static Color getPrupleColor() {
    return highPriorityPurpleColor;
  }

  static Color getPrupleAccentColor() {
    return purpleAcccent;
  }

  static Color getBodyTextColor() {
    return bodyTextColor;
  }

  static Color getHeadingTextColor() {
    return Get.find<ThemeController>().darkTheme
        ? dheadingTextColor
        : primaryTextColor;
  }

  static const Color screenBgColor = Color(0xFFffffff);
  static const Color secondaryScreenBgColor = Color(0xFFEEEDED);
  static const Color primaryTextColor = Color(0xff262626);
  static const Color contentTextColor = Color(0xff777777);
  static const Color borderColor = Color(0xffD9D9D9);
  static const Color bodyTextColor = Color(0xFF747475);
  static const Color purpleAcccent = Color(0xFF6C63FF);

  static const Color appBarColor = primaryColor;
  static const Color appBarContentColor = colorWhite;

  static const Color textFieldDisableBorderColor = Color(0xffCFCEDB);
  static const Color textFieldFillColor = Color(0xffCFCEDB);
  static const Color textFieldEnableBorderColor = primaryColor;
  static const Color hintTextColor = Color(0xff98a1ab);

  static const Color primaryButtonTextColor = colorWhite;
  static const Color secondaryButtonColor = colorWhite;
  static const Color secondaryButtonTextColor = colorBlack;

  static const Color inputFillColor = Colors.transparent;
  static const Color iconColor = Color.fromARGB(255, 122, 122, 122);
  static const Color labelTextColor = Color.fromARGB(255, 0, 0, 0);
  static const Color focusColor = Color(0xff262626);
  static const Color shadowColor = Color(0xffEAEAEA);
  static const Color colorWhite = Color(0xffFFFFFF);
  static const Color colorBlack = Color(0xff262626);
  // Semantic colors for hobby matching app
  static const Color colorGreen = Color(0xFF10B981); // Emerald success
  static const Color colorRed = Color(0xFFEF4444); // Modern red
  static const Color colorGrey = Color(0xFF6B7280); // Modern gray
  static const Color transparentColor = Colors.transparent;

  static const Color greenSuccessColor = Color(0xFF10B981); // Emerald
  static const Color redCancelTextColor = Color(0xFFEF4444); // Modern red
  static const Color highPriorityPurpleColor = Color(0xFF8B5CF6); // Purple
  static const Color pendingColor = Color(0xFFFFAB00); // Amber warning
  static const Color greenP = Color(0xFF10B981); // Emerald
  static const Color containerBgColor = Color(0xFFFFFBFE); // Warm container
  static const Color currencyBoxColor = Color(0xFF6366F1); // Indigo
  static const Color goldenColor = Color(0xFFFFAB00); // Amber gold

  // Hobby category colors
  static const Color sportsColor = Color(0xFF059669); // Sports - emerald
  static const Color musicColor = Color(0xFF7C3AED); // Music - violet
  static const Color artColor = Color(0xFFEC4899); // Art - pink
  static const Color cookingColor = Color(0xFFEA580C); // Cooking - orange
  static const Color travelColor = Color(0xFF0284C7); // Travel - sky blue
  static const Color gamesColor = Color(0xFF7C2D12); // Games - brown
  static const Color fitnessColor = Color(0xFF16A34A); // Fitness - green
  static const Color readingColor = Color(0xFF4338CA); // Reading - indigo

  static Color getPrimaryColor() {
    return buttonColor;
  }

  static Color getSecondaryColor() {
    return secondaryColor;
  }

  static Color getPrimaryTextColor() {
    return Get.find<ThemeController>().darkTheme
        ? dPrimaryTextColor
        : lPrimaryTextColor;
  }

  static Color getSecondaryTextColor() {
    return Get.find<ThemeController>().darkTheme
        ? dSecondaryTextColor
        : lSecondaryTextColor;
  }

  static Color getBackgroundColor() {
    return Get.find<ThemeController>().darkTheme
        ? dBackgroundColor
        : lBackgroundColor;
  }

  static Color getScreenBgColor() {
    return getWhiteColor();
  }

  static Color getCardBgColor() {
    return Get.find<ThemeController>().darkTheme ? dCardColor : lCardColor;
  }

  static Color getBorderColor() {
    return Get.find<ThemeController>().darkTheme ? dBorderColor : lBorderColor;
  }

  static Color getIconColor() {
    return Get.find<ThemeController>().darkTheme ? dIconColor : lIconColor;
  }

  static Color getShadowColor() {
    return Get.find<ThemeController>().darkTheme
        ? dSecondaryTextColor
        : lShadowColor;
  }

  // Hobby matching specific getters
  static Color getAccentColor() {
    return accentColor;
  }

  static Color getSocialColor() {
    return socialColor;
  }

  // Hobby category color getters
  static Color getSportsColor() {
    return sportsColor;
  }

  static Color getMusicColor() {
    return musicColor;
  }

  static Color getArtColor() {
    return artColor;
  }

  static Color getCookingColor() {
    return cookingColor;
  }

  static Color getTravelColor() {
    return travelColor;
  }

  static Color getGamesColor() {
    return gamesColor;
  }

  static Color getFitnessColor() {
    return fitnessColor;
  }

  static Color getReadingColor() {
    return readingColor;
  }

  // Dynamic hobby color getter by category
  static Color getHobbyColor(String category) {
    switch (category.toLowerCase()) {
      case 'sports':
        return sportsColor;
      case 'music':
        return musicColor;
      case 'art':
        return artColor;
      case 'cooking':
        return cookingColor;
      case 'travel':
        return travelColor;
      case 'games':
      case 'gaming':
        return gamesColor;
      case 'fitness':
      case 'workout':
        return fitnessColor;
      case 'reading':
      case 'books':
        return readingColor;
      case 'social':
        return socialColor;
      default:
        return primaryColor;
    }
  }
}
