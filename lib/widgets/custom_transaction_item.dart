import 'package:flutter/material.dart';
import '../core/app_export.dart';
import './custom_image_view.dart';

class CustomTransactionItem extends StatelessWidget {
  const CustomTransactionItem({
    Key? key,
    this.iconPath,
    this.title,
    this.subtitle,
    this.amount,
    this.amountColor,
    this.onTap,
    this.backgroundColor,
  }) : super(key: key);

  final String? iconPath;

  final String? title;

  final String? subtitle;

  final String? amount;

  final Color? amountColor;

  final VoidCallback? onTap;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? appTheme.whiteCustom,
          borderRadius: BorderRadius.circular(10.h),
        ),
        child: Row(
          children: [
            CustomImageView(
              imagePath: iconPath ?? ImageConstant.imgExpenseLogo,
              height: 40.h,
              width: 38.h,
            ),

            SizedBox(width: 22.h),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    title ?? 'kaja',
                    style: TextStyleHelper.instance.title16RegularWorkSans
                        .copyWith(height: 1.19),
                  ),

                  SizedBox(height: 2.h),

                  Text(
                    subtitle ?? '21 Sep, 03:02 PM',
                    style: TextStyleHelper.instance.label11RegularWorkSans
                        .copyWith(height: 1.18),
                  ),
                ],
              ),
            ),

            Text(
              amount ?? '-320 FT',
              style: TextStyleHelper.instance.body14RegularWorkSans.copyWith(
                color: amountColor ?? Color(0xFFA10303),
                height: 1.21,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
