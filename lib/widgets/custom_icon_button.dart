import 'package:flutter/material.dart';
import '../core/app_export.dart';
import './custom_image_view.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    required this.iconPath,
    this.onPressed,
    this.backgroundColor,
    this.size,
    this.iconSize,
    this.padding,
  }) : super(key: key);

  final String iconPath;

  final VoidCallback? onPressed;

  final Color? backgroundColor;

  final double? size;

  final double? iconSize;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 40.h;
    final iconSizeValue = iconSize ?? 16.h;
    final buttonBackgroundColor = backgroundColor ?? Color(0xFFD9D9D9);
    final buttonPadding = padding ?? EdgeInsets.all(12.h);

    return IconButton(
      onPressed: onPressed,
      icon: CustomImageView(
        imagePath: iconPath,
        height: iconSizeValue,
        width: iconSizeValue,
        fit: BoxFit.contain,
      ),
      style: IconButton.styleFrom(
        backgroundColor: buttonBackgroundColor,
        minimumSize: Size(buttonSize, buttonSize),
        maximumSize: Size(buttonSize, buttonSize),
        padding: buttonPadding,
        shape: CircleBorder(),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
