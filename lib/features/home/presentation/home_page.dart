import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/constants/size.dart';
import 'widgets/home_header.dart';
import 'widgets/ai_recommendation_section.dart';
import 'widgets/quick_actions_section.dart';
import 'widgets/quiet_activities_section.dart';
import 'widgets/weekly_recommendations_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 헤더 섹션
              const HomeHeader(),

              // AI 맞춤 추천 섹션
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
                child: const AiRecommendationSection(),
              ),

              const SizedBox(height: AppSizes.gapL),

              // 빠른 액션 섹션
              const QuickActionsSection(),

              const SizedBox(height: AppSizes.gapL),

              // 조용한 액티비티 추천 섹션
              const QuietActivitiesSection(),

              const SizedBox(height: AppSizes.gapL),

              // 요일별 조용한 여행지 추천 섹션
              const WeeklyRecommendationsSection(),

              const SizedBox(height: AppSizes.gapL),
            ],
          ),
        ),
      ),
    );
  }
}