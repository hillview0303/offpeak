import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSizes.gapM,
        AppSizes.gapS,
        AppSizes.gapM,
        AppSizes.gapM,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'OffPeak',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.secondaryDark,
            ),
          ),

          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary,
                  size: AppSizes.iconL,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
