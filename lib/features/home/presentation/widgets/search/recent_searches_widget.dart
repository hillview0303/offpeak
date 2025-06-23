import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../core/constants/color.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';

// 최근 검색어 상태 관리
final recentSearchesProvider = StateProvider<List<String>>((ref) => [
  '한옥마을', '조용한 카페', '도서관', '미술관', '궁궐', '공원'
]);

class RecentSearchesWidget extends HookConsumerWidget {
  final Function(String) onSearchTap;
  final VoidCallback? onClearAll;

  const RecentSearchesWidget({
    super.key,
    required this.onSearchTap,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSearches = ref.watch(recentSearchesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 검색어',
              style: AppTextStyles.labelBold,
            ),
            if (recentSearches.isNotEmpty)
              TextButton(
                onPressed: () => _showClearAllDialog(context, ref),
                child: Text(
                  '전체 삭제',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSizes.gapS),
        if (recentSearches.isEmpty)
          _buildEmptyState()
        else
          Wrap(
            spacing: AppSizes.gapS,
            runSpacing: AppSizes.gapS,
            children: recentSearches.map((search) => _buildSearchChip(
              context,
              ref,
              search,
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.gapS),
      child: Text(
        '최근 검색한 내용이 없습니다',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildSearchChip(BuildContext context, WidgetRef ref, String text) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => onSearchTap(text),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSizes.gapM,
            top: AppSizes.gapS,
            bottom: AppSizes.gapS,
            right: AppSizes.gapS,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: AppSizes.iconS,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: AppSizes.gapXS),
              Text(
                text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: AppSizes.gapXS),
              GestureDetector(
                onTap: () => _removeSearchTerm(ref, text),
                child: Container(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeSearchTerm(WidgetRef ref, String term) {
    final notifier = ref.read(recentSearchesProvider.notifier);
    final currentList = ref.read(recentSearchesProvider);
    notifier.state = currentList.where((search) => search != term).toList();
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Text(
          '최근 검색어 삭제',
          style: AppTextStyles.h4,
        ),
        content: Text(
          '모든 최근 검색어를 삭제하시겠습니까?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(recentSearchesProvider.notifier).state = [];
              Navigator.of(context).pop();
              // 전체 삭제 콜백 호출
              onClearAll?.call();
            },
            child: Text(
              '삭제',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// 검색어 추가 헬퍼 함수
void addToRecentSearches(WidgetRef ref, String searchTerm) {
  if (searchTerm.trim().isEmpty) return;

  final notifier = ref.read(recentSearchesProvider.notifier);
  final currentList = ref.read(recentSearchesProvider);

  // 중복 제거 및 최신 순으로 정렬
  final updatedList = [searchTerm, ...currentList.where((s) => s != searchTerm)]
      .take(6) // 최대 6개까지만 저장
      .toList();

  notifier.state = updatedList;
}
