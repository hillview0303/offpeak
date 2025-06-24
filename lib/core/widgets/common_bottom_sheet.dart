import 'package:flutter/material.dart';
import '../../../../../core/constants/color.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';

void showCommonBottomSheet({
  required BuildContext context,
  String? title, // nullable로 변경
  required Widget content,
  double minHeightFactor = 0.4,
  double maxHeightFactor = 0.9,
  double initialHeightFactor = 0.6,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CommonBottomSheet(
      title: title,
      content: content,
      minHeightFactor: minHeightFactor,
      maxHeightFactor: maxHeightFactor,
      initialHeightFactor: initialHeightFactor,
    ),
  );
}

class CommonBottomSheet extends StatelessWidget {
  final String? title; // nullable로 변경
  final Widget content;
  final double minHeightFactor;
  final double maxHeightFactor;
  final double initialHeightFactor;

  const CommonBottomSheet({
    super.key,
    this.title, // required 제거
    required this.content,
    this.minHeightFactor = 0.4,
    this.maxHeightFactor = 0.9,
    this.initialHeightFactor = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialHeightFactor,
      minChildSize: minHeightFactor,
      maxChildSize: maxHeightFactor,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXL),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: EdgeInsets.only(top: AppSizes.gapS),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더 (title이 있으면 제목 표시, 없으면 여백만)
              Padding(
                padding: EdgeInsets.all(AppSizes.spacingM),
                child: title != null
                    ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title!,
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : SizedBox(height: 0), // 제목 없을 때는 여백만 유지
              ),

              // 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
                  child: content,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
