import 'package:flutter/material.dart';
import '../../../../../core/service/nearby_service.dart';
import '../../features/home/presentation/widgets/nearby/place_detail_content.dart';
import '../service/tourism_api_service.dart';
import '../widgets/common_bottom_sheet.dart';

/// 장소 상세 정보를 위한 바텀시트 헬퍼 함수
void showPlaceDetailBottomSheet(BuildContext context, NearbyPlace place) {
  showCommonBottomSheet(
    context: context,
    title: place.name,
    content: PlaceDetailContent(
      title: place.name,
      location: place.address,
      distance: place.distance,
      description: place.description.isNotEmpty ? place.description : null,
      reason: place.reason.isNotEmpty ? place.reason : null,
      category: place.category,
      isOpen: place.isOpen,
    ),
  );
}

/// 커스텀 장소 정보를 위한 바텀시트 헬퍼 함수
void showCustomPlaceBottomSheet({
  required BuildContext context,
  required String title,
  String? location,
  String? distance,
  String? description,
  String? reason,
  String? category,
  bool isOpen = true,
}) {
  showCommonBottomSheet(
    context: context,
    title: title,
    content: PlaceDetailContent(
      title: title,
      location: location,
      distance: distance,
      description: description,
      reason: reason,
      category: category,
      isOpen: isOpen,
    ),
  );
}
