import 'package:flutter/material.dart';

String _appTheme = "lightCode";
LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

class ThemeHelper {
  final Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors(),
  };

  final Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme,
  };

  void changeTheme(String newTheme) {
    _appTheme = newTheme;
  }

  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
    );
  }

  LightCodeColors themeColor() => _getThemeColors();

  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light();
}

class LightCodeColors {
  Color get indigo_500 => Color(0xFF4E56C0);
  Color get blue_gray_900 => Color(0xFF131751);
  Color get gray_800 => Color(0xFF4E4E4E);
  Color get blue_gray_900_01 => Color(0xFF131851);
  Color get blue_gray_100 => Color(0xFFD9D9D9);
  Color get black_900 => Color(0xFF000000);
  Color get deep_purple_300 => Color(0xFF9B5DE0);
  Color get red_900 => Color(0xFFA10303);
  Color get white_A700 => Color(0xFFFFFFFF);
  Color get blue_gray_50 => Color(0xFFF1F1F1);
  Color get purple_500 => Color(0xFF6B46C1);
  Color get primaryPurple => Color(0xFF8E44AD);

  Color get transparentCustom => Colors.transparent;
  Color get greyCustom => Colors.grey;
  Color get whiteCustom => Colors.white;
  Color get color190000 => Color(0x19000000);

  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;
}

