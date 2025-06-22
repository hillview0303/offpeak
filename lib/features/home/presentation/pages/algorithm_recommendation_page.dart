import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/router/navigation_service.dart';
import '../providers/ai_recommendation_service.dart';
import '../providers/recommendation_model.dart';
import '../widgets/recommendation_card_widget.dart';

// State Providers
final recommendationsProvider = StateProvider<List<RecommendationCard>>((ref) => []);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final selectedAreaCodeProvider = StateProvider<String?>((ref) => null);
final selectedContentTypeProvider = StateProvider<String?>((ref) => null);
final hasErrorProvider = StateProvider<bool>((ref) => false);

class AlgorithmRecommendationPage extends HookConsumerWidget {
  const AlgorithmRecommendationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final recommendations = ref.watch(recommendationsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final hasError = ref.watch(hasErrorProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAIRecommendations(ref);
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref, isTablet),
            Expanded(
              child: isLoading
                  ? _buildLoadingState(isTablet)
                  : hasError || recommendations.isEmpty
                  ? _buildEmptyState(ref, isTablet)
                  : _buildRecommendationList(recommendations, isTablet),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingButton(ref, isLoading, isTablet),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppSizes.gapXL : AppSizes.gapL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppSizes.radiusXL),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: AppSizes.elevationM * 2.5,
            offset: Offset(0, AppSizes.elevationS),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => NavigationService.instance.goBack(),
                child: Container(
                  width: isTablet ? AppSizes.avatarM : AppSizes.buttonHeight * 0.83,
                  height: isTablet ? AppSizes.avatarM : AppSizes.buttonHeight * 0.83,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF333333),
                    size: isTablet ? AppSizes.iconM : AppSizes.iconS + 2,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'AI 맞춤 추천',
                    style: isTablet
                        ? AppTextStyles.h3
                        : AppTextStyles.h4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showFilterDialog(context, ref),
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
          ),
          SizedBox(height: isTablet ? AppSizes.gapXL : AppSizes.gapL),
          Container(
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
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: isTablet ? AppSizes.iconS : 14.0,
                  ),
                ),
                SizedBox(width: AppSizes.gapS),
                Expanded(
                  child: Text(
                    'AI가 당신의 취향을 분석해서 추천해드려요',
                    style: isTablet
                        ? AppTextStyles.bodyMedium.copyWith(color: Color(0xFF7A9B76))
                        : AppTextStyles.bodySmall.copyWith(color: Color(0xFF7A9B76)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? AppSizes.iconXL * 2 : AppSizes.iconXL + AppSizes.gapXL,
            height: isTablet ? AppSizes.iconXL * 2 : AppSizes.iconXL + AppSizes.gapXL,
            decoration: BoxDecoration(
              color: Color(0xFF7A9B76).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7A9B76),
                strokeWidth: isTablet ? 4.0 : 3.0,
              ),
            ),
          ),
          SizedBox(height: isTablet ? AppSizes.gapXXL : AppSizes.gapL),
          Text(
            'AI가 분석 중이에요',
            style: isTablet
                ? AppTextStyles.h3
                : AppTextStyles.h4,
          ),
          SizedBox(height: AppSizes.gapS),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.gapXL),
            child: Text(
              '당신만을 위한 특별한 여행지를\n찾고 있어요',
              style: isTablet
                  ? AppTextStyles.bodyLarge.copyWith(color: Color(0xFF888888))
                  : AppTextStyles.bodyMedium.copyWith(color: Color(0xFF888888)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? AppSizes.gapXXL + AppSizes.gapL : AppSizes.gapXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? AppSizes.iconXL * 2.5 : AppSizes.iconXL * 2,
              height: isTablet ? AppSizes.iconXL * 2.5 : AppSizes.iconXL * 2,
              decoration: BoxDecoration(
                color: Color(0xFF7A9B76).withOpacity(0.1),
                borderRadius: BorderRadius.circular(isTablet ? AppSizes.gapXL + 6 : AppSizes.radiusXL + 9),
              ),
              child: Icon(
                Icons.cloud_off,
                size: isTablet ? AppSizes.iconXL + AppSizes.gapS : AppSizes.iconXL + 2,
                color: Color(0xFF7A9B76),
              ),
            ),
            SizedBox(height: isTablet ? AppSizes.gapXXL : AppSizes.gapXL),
            Text(
              '연결할 수 없습니다',
              style: isTablet
                  ? AppTextStyles.h2
                  : AppTextStyles.h3,
            ),
            SizedBox(height: AppSizes.gapS),
            Text(
              'AI 서비스에 연결할 수 없어요\n인터넷 연결을 확인하고 다시 시도해주세요',
              style: isTablet
                  ? AppTextStyles.bodyLarge.copyWith(color: Color(0xFF888888))
                  : AppTextStyles.bodyMedium.copyWith(color: Color(0xFF888888)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? AppSizes.gapXL : AppSizes.gapL),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7A9B76), Color(0xFF8FA68E)],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: TextButton.icon(
                onPressed: () => _loadAIRecommendations(ref),
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: isTablet ? AppSizes.iconM : AppSizes.iconS + 2,
                ),
                label: Text(
                  '다시 시도',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16.0 : 14.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            // 상세 페이지로 이동
          },
        );
      },
    );
  }

  Widget _buildFloatingButton(WidgetRef ref, bool isLoading, bool isTablet) {
    final buttonSize = isTablet ? AppSizes.avatarL : AppSizes.listItemHeight;
    final iconSize = isTablet ? AppSizes.iconL : AppSizes.iconM;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF7A9B76),
            Color(0xFF8FA68E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF7A9B76).withOpacity(0.4),
            blurRadius: AppSizes.spacingM,
            offset: Offset(0, AppSizes.gapS),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () => _loadAIRecommendations(ref),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Center(
            child: isLoading
                ? SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: isTablet ? 3.0 : 2.0,
              ),
            )
                : Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  void _loadAIRecommendations(WidgetRef ref) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(hasErrorProvider.notifier).state = false;
    ref.read(recommendationsProvider.notifier).state = [];

    try {
      final selectedAreaCode = ref.read(selectedAreaCodeProvider);
      final selectedContentType = ref.read(selectedContentTypeProvider);

      final recommendations = await AIRecommendationService.fetchRecommendations(
        areaCode: selectedAreaCode,
        contentType: selectedContentType,
      );

      if (recommendations.isNotEmpty) {
        ref.read(recommendationsProvider.notifier).state = recommendations;
        ref.read(hasErrorProvider.notifier).state = false;
      } else {
        ref.read(hasErrorProvider.notifier).state = true;
      }
    } catch (e) {
      print('Error loading AI recommendations: $e');
      ref.read(hasErrorProvider.notifier).state = true;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final selectedAreaCode = ref.read(selectedAreaCodeProvider);
    final selectedContentType = ref.read(selectedContentTypeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
        title: Row(
          children: [
            Container(
              width: AppSizes.iconM,
              height: AppSizes.iconM,
              decoration: BoxDecoration(
                color: Color(0xFF7A9B76),
                borderRadius: BorderRadius.circular(AppSizes.radiusS - 2),
              ),
              child: Icon(
                Icons.tune,
                color: Colors.white,
                size: 14.0,
              ),
            ),
            SizedBox(width: AppSizes.gapS),
            Text(
              'AI 추천 필터',
              style: AppTextStyles.h4,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.gapM),
                decoration: BoxDecoration(
                  color: Color(0xFFF0F7F0),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Text(
                  'AI가 더 정확한 추천을 할 수 있도록 선호사항을 알려주세요',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Color(0xFF7A9B76),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.gapL),
              Text(
                '선호 지역',
                style: AppTextStyles.labelBold,
              ),
              SizedBox(height: AppSizes.gapS),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFE5E5E5)),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedAreaCode,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSizes.gapM,
                      vertical: AppSizes.gapS,
                    ),
                    hintText: '전체 지역',
                    hintStyle: TextStyle(color: Color(0xFF999999)),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('전체 지역')),
                    DropdownMenuItem(value: '1', child: Text('서울')),
                    DropdownMenuItem(value: '2', child: Text('인천')),
                    DropdownMenuItem(value: '3', child: Text('대전')),
                    DropdownMenuItem(value: '4', child: Text('대구')),
                    DropdownMenuItem(value: '5', child: Text('광주')),
                    DropdownMenuItem(value: '6', child: Text('부산')),
                    DropdownMenuItem(value: '7', child: Text('울산')),
                    DropdownMenuItem(value: '8', child: Text('세종')),
                    DropdownMenuItem(value: '31', child: Text('경기도')),
                    DropdownMenuItem(value: '32', child: Text('강원도')),
                    DropdownMenuItem(value: '33', child: Text('충청북도')),
                    DropdownMenuItem(value: '34', child: Text('충청남도')),
                    DropdownMenuItem(value: '35', child: Text('경상북도')),
                    DropdownMenuItem(value: '36', child: Text('경상남도')),
                    DropdownMenuItem(value: '37', child: Text('전라북도')),
                    DropdownMenuItem(value: '38', child: Text('전라남도')),
                    DropdownMenuItem(value: '39', child: Text('제주도')),
                  ],
                  onChanged: (value) {
                    ref.read(selectedAreaCodeProvider.notifier).state = value;
                  },
                ),
              ),
              SizedBox(height: AppSizes.spacingM),
              Text(
                '여행 스타일',
                style: AppTextStyles.labelBold,
              ),
              SizedBox(height: AppSizes.gapS),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFE5E5E5)),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedContentType,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSizes.gapM,
                      vertical: AppSizes.gapS,
                    ),
                    hintText: '전체 유형',
                    hintStyle: TextStyle(color: Color(0xFF999999)),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('전체 유형')),
                    DropdownMenuItem(value: '12', child: Text('🏔️ 관광지')),
                    DropdownMenuItem(value: '14', child: Text('🎭 문화시설')),
                    DropdownMenuItem(value: '15', child: Text('🎪 축제공연행사')),
                    DropdownMenuItem(value: '25', child: Text('🗺️ 여행코스')),
                    DropdownMenuItem(value: '28', child: Text('🏃 레포츠')),
                    DropdownMenuItem(value: '32', child: Text('🏨 숙박')),
                    DropdownMenuItem(value: '39', child: Text('🍽️ 음식점')),
                  ],
                  onChanged: (value) {
                    ref.read(selectedContentTypeProvider.notifier).state = value;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(selectedAreaCodeProvider.notifier).state = null;
              ref.read(selectedContentTypeProvider.notifier).state = null;
              Navigator.pop(context);
            },
            child: Text(
              '초기화',
              style: AppTextStyles.bodyMedium.copyWith(color: Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: AppTextStyles.bodyMedium.copyWith(color: Color(0xFF888888)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7A9B76), Color(0xFF8FA68E)],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _loadAIRecommendations(ref);
              },
              icon: Icon(Icons.auto_awesome, size: AppSizes.iconS, color: Colors.white),
              label: Text(
                'AI 추천 받기',
                style: AppTextStyles.buttonMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
