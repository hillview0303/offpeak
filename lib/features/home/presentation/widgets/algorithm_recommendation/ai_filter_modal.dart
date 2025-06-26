import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';
import '../../../../../core/widgets/common_dropdown.dart';
import '../../providers/algorithm_recommendation_provider.dart';

class AIFilterModal extends ConsumerStatefulWidget {
  final String? selectedAreaCode;
  final String? selectedContentType;
  final String? selectedSigunguCode;
  final Function(String?) onAreaCodeChanged;
  final Function(String?) onContentTypeChanged;
  final Function(String?) onSigunguCodeChanged;
  final VoidCallback onApplyFilters;

  const AIFilterModal({
    super.key,
    required this.selectedAreaCode,
    required this.selectedContentType,
    this.selectedSigunguCode,
    required this.onAreaCodeChanged,
    required this.onContentTypeChanged,
    required this.onSigunguCodeChanged,
    required this.onApplyFilters,
  });

  @override
  ConsumerState<AIFilterModal> createState() => _SimpleAIFilterModalState();
}

class _SimpleAIFilterModalState extends ConsumerState<AIFilterModal> {
  String? currentAreaCode;
  String? currentContentType;
  String? currentSigunguCode;

  @override
  void initState() {
    super.initState();
    currentAreaCode = widget.selectedAreaCode;
    currentContentType = widget.selectedContentType;
    currentSigunguCode = widget.selectedSigunguCode;
  }

  @override
  Widget build(BuildContext context) {
    // 관광공사 API 상태 확인
    final tourismApiStatus = ref.watch(tourismApiStatusProvider);

    return tourismApiStatus.when(
      data: (isConnected) {
        if (!isConnected) {
          return _buildErrorDialog('관광공사 API 연결에 실패했습니다. 네트워크를 확인해주세요.');
        }
        return _buildMainDialog(context);
      },
      loading: () => _buildLoadingDialog(),
      error: (error, stack) => _buildErrorDialog('서비스 연결에 문제가 발생했습니다: $error'),
    );
  }

  Widget _buildMainDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
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
            Padding(
              padding: EdgeInsets.all(AppSizes.spacingL),
              child: _buildApplyButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDialog() {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Container(
        padding: EdgeInsets.all(AppSizes.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF7A9B76)),
            SizedBox(height: AppSizes.gapL),
            Text(
              '관광공사 서비스 연결 중...',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDialog(String message) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Container(
        padding: EdgeInsets.all(AppSizes.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: AppSizes.iconXL,
            ),
            SizedBox(height: AppSizes.gapL),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.gapL),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.spacingL),
      child: Row(
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
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
      ),
    );
  }

  Widget _buildInfoContainer() {
    return Container(
      padding: EdgeInsets.all(AppSizes.gapM),
      decoration: BoxDecoration(
        color: Color(0xFFF0F7F0),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: Color(0xFF7A9B76).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.travel_explore,
            color: Color(0xFF7A9B76),
            size: AppSizes.iconS,
          ),
          SizedBox(width: AppSizes.gapS),
          Expanded(
            child: Text(
              '관광공사 데이터를 기반으로 맞춤 추천을 제공합니다',
              style: AppTextStyles.bodySmall.copyWith(
                color: Color(0xFF7A9B76),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaSelector() {
    final areaCodeList = ref.watch(areaCodeListProvider);

    return CommonDropdown<String>(
      label: '선호 지역',
      value: currentAreaCode,
      hintText: '전체 지역',
      onChanged: (value) {
        setState(() {
          currentAreaCode = value;
          currentSigunguCode = null; // 지역 변경시 시군구 초기화
        });
        widget.onAreaCodeChanged(value);
        widget.onSigunguCodeChanged(null);
      },
      borderColor: Color(0xFFE5E5E5),
      focusedBorderColor: Color(0xFF7A9B76),
      items: areaCodeList.map((item) => DropdownMenuItem(
        value: item.value,
        child: Text(item.label),
      )).toList(),
    );
  }

  Widget _buildContentTypeSelector() {
    final contentTypeList = ref.watch(contentTypeListProvider);

    return CommonDropdown<String>(
      label: '여행 스타일',
      value: currentContentType,
      hintText: '전체 유형',
      onChanged: (value) {
        setState(() {
          currentContentType = value;
        });
        widget.onContentTypeChanged(value);
      },
      borderColor: Color(0xFFE5E5E5),
      focusedBorderColor: Color(0xFF7A9B76),
      items: contentTypeList.map((item) => DropdownMenuItem(
        value: item.value,
        child: Text(item.label),
      )).toList(),
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
          boxShadow: [
            BoxShadow(
              color: Color(0xFF7A9B76).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            widget.onApplyFilters();
          },
          icon: Icon(
            Icons.search,
            size: AppSizes.iconS,
            color: Colors.white,
          ),
          label: Text(
            '맞춤 추천 받기',
            style: AppTextStyles.buttonMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: AppSizes.gapM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
        ),
      ),
    );
  }
}
