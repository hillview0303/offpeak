import 'package:flutter/material.dart';
import 'package:offpeak/features/home/presentation/widgets/weekly_recommendations_section.dart';
import '../../../../core/constants/size.dart';
import 'ai_recommendation_section.dart';
import 'quick_actions_section.dart';
import 'quiet_activities_section.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.gapM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 맞춤 추천 섹션
          const AiRecommendationSection(),
          SizedBox(height: AppSizes.gapL),

          // 빠른 액션 섹션
          const QuickActionsSection(),
          SizedBox(height: AppSizes.gapL),

          // 조용한 액티비티 추천 섹션
          const QuietActivitiesSection(),
          SizedBox(height: AppSizes.gapL),

          // 요일별 조용한 여행지 추천 섹션
          const WeeklyRecommendationsSection(),
          SizedBox(height: AppSizes.gapL),
        ],
      ),
    );
  }
}
