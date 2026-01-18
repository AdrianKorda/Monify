import 'package:flutter/material.dart';
import '../core/app_export.dart';

class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  TextStyle get display36RegularWorkSans => TextStyle(
    fontSize: 36.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Work Sans',
    color: appTheme.indigo_500,
  );

  TextStyle get display36MediumWorkSans => TextStyle(
    fontSize: 36.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Work Sans',
  );

  TextStyle get headline28RegularWorkSans => TextStyle(
    fontSize: 28.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Work Sans',
    color: appTheme.blue_gray_900,
  );

  TextStyle get title20RegularRoboto => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );

  TextStyle get title20RegularWorkSans => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Work Sans',
    color: appTheme.blue_gray_900,
  );

  TextStyle get title16RegularWorkSans => TextStyle(
    fontSize: 16.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Work Sans',
    color: appTheme.blue_gray_900_01,
  );

  TextStyle get title15RegularWorkSans => TextStyle(
    fontSize: 15.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Work Sans',
  );

  TextStyle get body14RegularWorkSans => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Work Sans',
  );

  TextStyle get label11RegularWorkSans => TextStyle(
    fontSize: 11.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Work Sans',
    color: appTheme.gray_800,
  );
}
