import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/widgets/custom_header_bar.dart';
import '../providers/algorithm_recommendation_provider.dart';
import '../providers/recommendation_model.dart';
import '../widgets/algorithm_recommendation/recommendation_card_widget.dart';
import '../widgets/algorithm_recommendation/ai_filter_modal.dart';
import '../widgets/algorithm_recommendation/ai_recommendation_states.dart';

class AlgorithmRecommendationPage extends HookConsumerWidget {
  const AlgorithmRecommendationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final controller = ref.read(algorithmRecommendationControllerProvider);
    final recommendations = ref.watch(recommendationsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final hasError = ref.watch(hasErrorProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadAIRecommendations();
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(isTablet, context, ref),
          Expanded(
            child: _buildBody(recommendations, isLoading, hasError, isTablet, controller),
          ),
        ],
      ),
      floatingActionButton: AIFloatingButton(
        isLoading: isLoading,
        isTablet: isTablet,
        onPressed: () => controller.loadAIRecommendations(),
      ),
    );
  }

  Widget _buildHeader(bool isTablet, BuildContext context, WidgetRef ref) {
    return CustomHeaderBar(
      title: '맞춤 여행지 추천',
      showFilterButton: true,
      onFilterPressed: () => _showFilterDialog(context, ref),
      subtitle: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.gapM,
          vertical: isTablet ? AppSizes.gapM : AppSizes.gapS,
        ),
        decoration: BoxDecoration(
          color: Color(0xFFF0F7F0),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: Row(
          children: [
            Container(
              width: isTablet ? AppSizes.spacingL : AppSizes.iconM,
              height: isTablet ? AppSizes.spacingL : AppSizes.iconM,
              decoration: BoxDecoration(
                color: Color(0xFF7A9B76),
                borderRadius: BorderRadius.circular(AppSizes.radiusS - 2),
              ),
              child: Icon(
                Icons.travel_explore,
                color: Colors.white,
                size: isTablet ? AppSizes.iconS : 14.0,
              ),
            ),
            SizedBox(width: AppSizes.gapS),
            Expanded(
              child: Text(
                '관광공사 데이터 기반 맞춤 추천',
                style: isTablet
                    ? AppTextStyles.bodyMedium.copyWith(color: Color(0xFF7A9B76))
                    : AppTextStyles.bodySmall.copyWith(color: Color(0xFF7A9B76)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
      List<RecommendationCard> recommendations,
      bool isLoading,
      bool hasError,
      bool isTablet,
      AlgorithmRecommendationController controller,
      ) {
    if (isLoading) {
      return AILoadingState(isTablet: isTablet);
    }

    if (hasError || recommendations.isEmpty) {
      return AIEmptyState(
        isTablet: isTablet,
        onRetry: () => controller.loadAIRecommendations(),
      );
    }

    return _buildRecommendationList(recommendations, isTablet);
  }

  Widget _buildRecommendationList(List<RecommendationCard> recommendations, bool isTablet) {
    final padding = isTablet ? AppSizes.gapXL : AppSizes.spacingM;
    final spacing = isTablet ? AppSizes.spacingM : AppSizes.gapM;

    return ListView.separated(
      padding: EdgeInsets.all(padding),
      itemCount: recommendations.length + 1,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        if (index == recommendations.length) {
          return SizedBox(height: isTablet ? AppSizes.iconXL * 2 : AppSizes.iconXL + AppSizes.gapL);
        }
        return RecommendationCardWidget(
          recommendation: recommendations[index],
          onTap: () {
            // TODO: 상세 페이지로 이동
            print('🔍 상세 페이지 이동: ${recommendations[index].title}');
          },
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final controller = ref.read(algorithmRecommendationControllerProvider);

    showDialog(
      context: context,
      builder: (context) => AIFilterModal(
        selectedAreaCode: controller.selectedAreaCode,
        selectedContentType: controller.selectedContentType,
        selectedSigunguCode: controller.selectedSigunguCode, // 간소화됨 (사용하지 않음)
        onAreaCodeChanged: (value) => controller.updateAreaCode(value),
        onContentTypeChanged: (value) => controller.updateContentType(value),
        onSigunguCodeChanged: (value) => controller.updateSigunguCode(value), // 간소화됨 (사용하지 않음)
        onApplyFilters: () => controller.loadAIRecommendations(),
      ),
    );
  }
}
