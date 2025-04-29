/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/main/app_themedata.dart';
import 'package:flutter/material.dart';

// Converts a hex, rgb, or rgba color string to Color object
Color hexOrRGBToColor(String colorStr) {
  final RegExp hexColorRegex = RegExp(r'^#?([0-9a-fA-F]{3,8})$');

  if (colorStr.startsWith("rgba")) {
    // convert rgba
    final List<String> rgbaList = colorStr.substring(5, colorStr.length - 1).split(",");
    return Color.fromRGBO(
      int.parse(rgbaList[0].trim()),
      int.parse(rgbaList[1].trim()),
      int.parse(rgbaList[2].trim()),
      double.parse(rgbaList[3].trim()),
    );
  } else if (colorStr.startsWith("rgb")) {
    // convert rgb
    final List<int> rgbList =
        colorStr.substring(4, colorStr.length - 1).split(",").map((c) => int.parse(c.trim())).toList();
    return Color.fromRGBO(rgbList[0], rgbList[1], rgbList[2], 1.0);
  } else if (hexColorRegex.hasMatch(colorStr)) {
    // conver hex
    colorStr = colorStr.replaceFirst("#", "");
    if (colorStr.length == 3) {
      colorStr = colorStr.split("").map((c) => "$c$c").join();
    }

    if (colorStr.length == 6) {
      return Color(int.parse("0xFF$colorStr"));
    } else if (colorStr.length == 8) {
      return Color(int.parse("0x$colorStr"));
    }
  } else if (colorStr.toLowerCase() == 'none') {
    return AppThemeColor.transparentColor;
  } else {
    throw ArgumentError("Only hex, rgb, or rgba color format currently supported. Invalid string: $colorStr");
  }

  return AppThemeColor.transparentColor;
}

// convert a color to hex
String colorToHex(Color color) {
  final r = color.r.toInt().toRadixString(16).padLeft(2, '0');
  final g = color.g.toInt().toRadixString(16).padLeft(2, '0');
  final b = color.b.toInt().toRadixString(16).padLeft(2, '0');
  return '#$r$g$b';
}
