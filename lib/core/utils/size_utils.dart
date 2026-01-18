import 'package:flutter/material.dart';
import 'dart:math' as math;

extension SizeUtils on num {
  double get fSize => this * SizeConfig.textScaleFactor;
  double get h => this * SizeConfig.heightScaleFactor;
  double get w => this * SizeConfig.widthScaleFactor;
}

class SizeConfig {
  static double screenWidth = 375;
  static double screenHeight = 812;
  static double textScaleFactor = 1.0;
  static double heightScaleFactor = 1.0;
  static double widthScaleFactor = 1.0;

  /// Inicializálja a méretezést a MediaQuery adatai alapján
  static void init(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;

    // Alap felbontás (375x812 iPhone 11)
    widthScaleFactor = screenWidth / 375.0;
    heightScaleFactor = screenHeight / 812.0;

    textScaleFactor = math.min(widthScaleFactor, heightScaleFactor);
  }
}
