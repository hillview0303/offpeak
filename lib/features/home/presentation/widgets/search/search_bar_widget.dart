import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../core/constants/color.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';

class SearchBarWidget extends HookConsumerWidget {
  final Function(String) onSearchChanged;
  final Function(String) onSearchSubmitted;
  final String? initialValue;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController(text: initialValue);
    final focusNode = useFocusNode();
    final showClearButton = useState(initialValue?.isNotEmpty ?? false);

    useEffect(() {
      void listener() {
        showClearButton.value = searchController.text.isNotEmpty;
      }
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        focusNode: focusNode,
        onChanged: onSearchChanged,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            onSearchSubmitted(value.trim());
            // 검색 완료 후 검색창 초기화
            searchController.clear();
            showClearButton.value = false;
            focusNode.unfocus();
          }
        },
        decoration: InputDecoration(
          hintText: '조용한 여행지를 검색해보세요',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: AppSizes.iconM,
          ),
          suffixIcon: showClearButton.value
              ? IconButton(
            onPressed: () {
              searchController.clear();
              onSearchChanged('');
              showClearButton.value = false;
            },
            icon: Icon(
              Icons.clear,
              color: AppColors.textSecondary,
              size: AppSizes.iconS,
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.gapM,
            vertical: AppSizes.gapM,
          ),
        ),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
