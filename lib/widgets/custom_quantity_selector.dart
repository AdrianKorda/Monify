import 'package:flutter/material.dart';
import '../core/app_export.dart';

class CustomQuantitySelector extends StatelessWidget {
  const CustomQuantitySelector({
    Key? key,
    this.quantity,
    this.amount,
    this.onIncrement,
    this.onDecrement,
    this.quantityTextStyle,
    this.amountTextStyle,
    this.amountColor,
  }) : super(key: key);

  final int? quantity;
  final String? amount;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final TextStyle? quantityTextStyle;
  final TextStyle? amountTextStyle;
  final Color? amountColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onDecrement,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.remove,
                    size: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 8.h),
              Text(
                '${quantity ?? 1}',
                style:
                    quantityTextStyle ??
                    TextStyleHelper.instance.body14RegularWorkSans.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              SizedBox(width: 8.h),
              GestureDetector(
                onTap: onIncrement,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.add, size: 14, color: Colors.black),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          Text(
            amount ?? '-320 FT',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                amountTextStyle ??
                TextStyleHelper.instance.body14RegularWorkSans.copyWith(
                  color: amountColor ?? const Color(0xFFA10303),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
