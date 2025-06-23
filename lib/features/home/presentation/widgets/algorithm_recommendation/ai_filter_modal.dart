import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';
import '../../../../../core/widgets/common_dropdown.dart';

class AIFilterModal extends ConsumerWidget {
  final String? selectedAreaCode;
  final String? selectedContentType;
  final Function(String?) onAreaCodeChanged;
  final Function(String?) onContentTypeChanged;
  final VoidCallback onApplyFilters;

  const AIFilterModal({
    super.key,
    required this.selectedAreaCode,
    required this.selectedContentType,
    required this.onAreaCodeChanged,
    required this.onContentTypeChanged,
    required this.onApplyFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 고정 헤더
            Padding(
              padding: EdgeInsets.all(AppSizes.spacingL),
              child: _buildHeader(context),
            ),
            // 스크롤 가능한 컨텐츠
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoContainer(),
                    SizedBox(height: AppSizes.gapL),
                    _buildAreaSelector(),
                    SizedBox(height: AppSizes.spacingM),
                    _buildContentTypeSelector(),
                    SizedBox(height: AppSizes.gapL),
                  ],
                ),
              ),
            ),
            // 고정 버튼
            Padding(
              padding: EdgeInsets.all(AppSizes.spacingL),
              child: _buildApplyButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
        Expanded(
          child: Text(
            '추천 필터',
            style: AppTextStyles.bodyLarge,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(AppSizes.gapXS),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Icon(
              Icons.close,
              size: AppSizes.iconS,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoContainer() {
    return Container(
      padding: EdgeInsets.all(AppSizes.gapM),
      decoration: BoxDecoration(
        color: Color(0xFFF0F7F0),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Text(
        '더 정확한 추천을 할 수 있도록 선호사항을 알려주세요',
        style: AppTextStyles.bodySmall.copyWith(
          color: Color(0xFF7A9B76),
        ),
      ),
    );
  }

  Widget _buildAreaSelector() {
    return CommonDropdown<String>(
      label: '선호 지역',
      value: selectedAreaCode,
      hintText: '전체 지역',
      onChanged: onAreaCodeChanged,
      borderColor: Color(0xFFE5E5E5),
      focusedBorderColor: Color(0xFF7A9B76),
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
    );
  }

  Widget _buildContentTypeSelector() {
    return CommonDropdown<String>(
      label: '여행 스타일',
      value: selectedContentType,
      hintText: '전체 유형',
      onChanged: onContentTypeChanged,
      borderColor: Color(0xFFE5E5E5),
      focusedBorderColor: Color(0xFF7A9B76),
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
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7A9B76), Color(0xFF8FA68E)],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onApplyFilters();
          },
          icon: Icon(Icons.auto_awesome, size: AppSizes.iconS, color: Colors.white),
          label: Text(
            'AI 추천 받기',
            style: AppTextStyles.buttonMedium,
          ),
        ),
      ),
    );
  }
}

