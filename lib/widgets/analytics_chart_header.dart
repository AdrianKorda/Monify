import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/app_export.dart';
import '../pages/elemzes_page.dart';
import '../core/localization/app_strings.dart';

class AnalyticsChartHeader extends StatelessWidget {
  final ElemzesTipus tipus;
  final ValueChanged<ElemzesTipus> onTypeChanged;
  final LineChartData chartData;

  const AnalyticsChartHeader({
    super.key,
    required this.tipus,
    required this.onTypeChanged,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.h, 40.h, 18.h, 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appTheme.deep_purple_300,
            appTheme.purple_500,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.expenseStatistics,
                style: TextStyleHelper.instance.title20RegularWorkSans.copyWith(
                  fontSize: 25.fSize,
                  color: appTheme.white_A700,
                ),
              ),
              _buildDropdown(),
            ],
          ),

          SizedBox(height: 20.h),

          SizedBox(
            height: 220.h,
            child: LineChart(chartData),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.h),
      decoration: BoxDecoration(
        color: appTheme.white_A700.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ElemzesTipus>(
          value: tipus,
          dropdownColor: appTheme.purple_500,
          icon: Icon(Icons.keyboard_arrow_down,
              color: appTheme.white_A700),
          style: TextStyle(
            color: appTheme.white_A700,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (val) {
            if (val != null) onTypeChanged(val);
          },
          items: [
            DropdownMenuItem(
              value: ElemzesTipus.napi,
              child: Text(AppStrings.filterDaily),
            ),
            DropdownMenuItem(
              value: ElemzesTipus.heti,
              child: Text(AppStrings.filterWeekly),
            ),
            DropdownMenuItem(
              value: ElemzesTipus.havi,
              child: Text(AppStrings.filterMonthly),
            ),
          ],
        ),
      ),
    );
  }
}
