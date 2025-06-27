import 'package:flutter/material.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/router/navigation_service.dart';

class CustomHeaderBar extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final VoidCallback? onBackPressed;
  final bool showFilterButton;
  final VoidCallback? onFilterPressed;
  final Widget? subtitle;

  const CustomHeaderBar({
    Key? key,
    required this.title,
    this.backgroundColor = Colors.white,
    this.onBackPressed,
    this.showFilterButton = false,
    this.onFilterPressed,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSizes.gapS,
        left: AppSizes.gapM,
        right: AppSizes.gapM,
        bottom: subtitle != null ? AppSizes.gapM : AppSizes.spacingM,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: subtitle != null
            ? BorderRadius.vertical(bottom: Radius.circular(AppSizes.radiusXL))
            : null,
        boxShadow: subtitle != null
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: AppSizes.elevationM * 2.5,
            offset: Offset(0, AppSizes.elevationS),
          ),
        ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: onBackPressed ?? () => NavigationService.instance.goBack(),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Text(
                  title,
                  style: isTablet ? AppTextStyles.bodyMedium : AppTextStyles.bodyMedium,
                ),
              ),
              if (showFilterButton) ...[
                const SizedBox(width: AppSizes.spacingM),
                GestureDetector(
                  onTap: onFilterPressed,
                  child: Container(
                    width: isTablet ? AppSizes.avatarM : AppSizes.buttonHeight * 0.83,
                    height: isTablet ? AppSizes.avatarM : AppSizes.buttonHeight * 0.83,
                    decoration: BoxDecoration(
                      color: Color(0xFF7A9B76),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: isTablet ? AppSizes.iconM : AppSizes.iconS + 4,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppSizes.gapL),
            subtitle!,
          ],
        ],
      ),
    );
  }
}
