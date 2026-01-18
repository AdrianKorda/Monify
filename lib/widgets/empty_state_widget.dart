import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const EmptyStateWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(imagePath, height: 160.h),
        SizedBox(height: 20.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyleHelper.instance.title20RegularWorkSans,
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyleHelper.instance.body14RegularWorkSans.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
