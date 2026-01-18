import 'package:flutter/material.dart';
import '../core/app_export.dart';
import './custom_image_view.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({
    Key? key,
    this.title,
    this.titleColor,
    this.backgroundColor,
    this.leadingIcon,
    this.trailingIcon,
    this.onLeadingTap,
    this.onTrailingTap,
    this.height,
    this.horizontalPadding,
    this.showArrowIcon,
    this.arrowIconColor,
    this.titleKey,
  }) : super(key: key);

  final GlobalKey? titleKey;

  final String? title;

  final Color? titleColor;

  final Color? backgroundColor;

  final String? leadingIcon;

  final String? trailingIcon;

  final VoidCallback? onLeadingTap;

  final VoidCallback? onTrailingTap;

  final double? height;

  final double? horizontalPadding;

  final bool? showArrowIcon;

  final Color? arrowIconColor;

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: height ?? 56.h,
      flexibleSpace: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 28.h),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: onLeadingTap,
              behavior: HitTestBehavior.translucent,
              child: Row(
                key: titleKey,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: TextStyleHelper.instance.title20RegularWorkSans
                          .copyWith(
                            color: titleColor ?? Colors.white,
                            height: 1.2,
                          ),
                    ),
                    if (showArrowIcon == true) ...[
                      SizedBox(width: 6.h),
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: arrowIconColor ?? Colors.white,
                          size: 24.h,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            Positioned(
              right: 0,
              child: trailingIcon != null
                  ? GestureDetector(
                      onTap: onTrailingTap,
                      child: CustomImageView(
                        imagePath: trailingIcon!,
                        height: 24.h,
                        width: 24.h,
                      ),
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
