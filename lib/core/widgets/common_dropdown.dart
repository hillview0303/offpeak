import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';

class CommonDropdown<T> extends HookConsumerWidget {
  final String label;
  final T? value;
  final ValueChanged<T?> onChanged;
  final List<DropdownMenuItem<T>> items;
  final String hintText;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final bool showLabel;
  final Widget? prefixIcon;

  const CommonDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.items,
    required this.hintText,
    this.borderColor,
    this.focusedBorderColor,
    this.showLabel = true,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedValue = useState<T?>(value);
    final isDropdownOpen = useState<bool>(false);
    final layerLink = useMemoized(() => LayerLink());
    final dropdownKey = GlobalKey();
    OverlayEntry? overlayEntry;

    void closeDropdown() {
      overlayEntry?.remove();
      overlayEntry = null;
      isDropdownOpen.value = false;
    }

    void openDropdown() {
      final RenderBox renderBox = dropdownKey.currentContext!.findRenderObject() as RenderBox;
      final Size size = renderBox.size;
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;
      final availableHeight = screenHeight - offset.dy - size.height;
      final bool shouldOpenUpwards = availableHeight < 200;

      overlayEntry = OverlayEntry(
        builder: (context) => GestureDetector(
          onTap: closeDropdown,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: shouldOpenUpwards
                    ? offset.dy - 200
                    : offset.dy + size.height + 4,
                width: size.width,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(color: borderColor ?? Color(0xFFE5E5E5)),
                    ),
                    constraints: BoxConstraints(
                      maxHeight: 200,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: items.map((item) {
                          final isSelected = item.value == selectedValue.value;
                          return InkWell(
                            onTap: () {
                              selectedValue.value = item.value;
                              onChanged(item.value);
                              closeDropdown();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.gapM,
                                vertical: AppSizes.gapS + 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (focusedBorderColor ?? Color(0xFF7A9B76)).withOpacity(0.1)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  if (isSelected) ...[
                                    Icon(
                                      Icons.check,
                                      size: AppSizes.iconS,
                                      color: focusedBorderColor ?? Color(0xFF7A9B76),
                                    ),
                                    SizedBox(width: AppSizes.gapS),
                                  ],
                                  Expanded(child: item.child),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      Overlay.of(context).insert(overlayEntry!);
      isDropdownOpen.value = true;
    }

    void toggleDropdown() {
      if (isDropdownOpen.value) {
        closeDropdown();
      } else {
        openDropdown();
      }
    }

    // 선택된 아이템의 텍스트 찾기
    String getSelectedText() {
      if (selectedValue.value == null) return hintText;

      final selectedItem = items.firstWhere(
            (item) => item.value == selectedValue.value,
        orElse: () => items.first,
      );

      if (selectedItem.child is Text) {
        return (selectedItem.child as Text).data ?? hintText;
      }
      return hintText;
    }

    useEffect(() {
      selectedValue.value = value;
      return null;
    }, [value]);

    return CompositedTransformTarget(
      link: layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel) ...[
            Text(
              label,
              style: AppTextStyles.labelBold,
            ),
            SizedBox(height: AppSizes.gapS),
          ],
          GestureDetector(
            key: dropdownKey,
            onTap: toggleDropdown,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.gapM,
                vertical: AppSizes.gapS,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isDropdownOpen.value
                      ? (focusedBorderColor ?? Color(0xFF7A9B76))
                      : (borderColor ?? Color(0xFFE5E5E5)),
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    SizedBox(width: AppSizes.gapS),
                  ],
                  Expanded(
                    child: Text(
                      getSelectedText(),
                      style: selectedValue.value != null
                          ? AppTextStyles.bodyMedium
                          : AppTextStyles.bodyMedium.copyWith(color: Color(0xFF999999)),
                    ),
                  ),
                  Icon(
                    isDropdownOpen.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Color(0xFF666666),
                    size: AppSizes.iconM,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
