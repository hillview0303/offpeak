import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/service/nearby_service.dart';
import '../../../../core/service/tourism_api_service.dart';
import '../../../../core/widgets/custom_header_bar.dart';
import '../widgets/nearby/location_info_card.dart';
import '../widgets/nearby/nearby_places_list.dart';

class NearbyPage extends HookConsumerWidget {
  const NearbyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상태 관리
    final currentPosition = useState<Position?>(null);
    final currentAddress = useState<String>('위치를 가져오는 중...');
    final isLoadingLocation = useState<bool>(true);
    final locationError = useState<String?>(null);
    final nearbyPlaces = useState<List<NearbyPlace>>([]);
    final selectedCategory = useState<String>('전체');
    final isLoadingPlaces = useState<bool>(false);

    // 페이지 기반 무한 스크롤 상태
    final currentPage = useState<int>(1); // 현재 페이지
    final isLoadingMore = useState<bool>(false); // 추가 로딩 중
    final hasMoreData = useState<bool>(true); // 더 불러올 데이터가 있는지
    final maxPages = 10; // 최대 페이지 수 (200개 장소)

    // 스크롤 컨트롤러
    final scrollController = useScrollController();

    // 주소 변환
    Future<String> getAddressFromPosition(Position position) async {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          List<String> addressParts = [];

          if (place.subAdministrativeArea != null) {
            addressParts.add(place.subAdministrativeArea!);
          } else if (place.locality != null) {
            addressParts.add(place.locality!);
          }

          if (place.subLocality != null) {
            addressParts.add(place.subLocality!);
          }

          String fullAddress = addressParts.join(' ');
          return fullAddress.isNotEmpty ? fullAddress : '주소를 찾을 수 없음';
        }

        return '주소를 찾을 수 없음';
      } catch (e) {
        print('주소 변환 오류: $e');
        return '위치 확인 중...';
      }
    }

    // 초기 주변 장소 검색 (첫 20개)
    Future<void> fetchInitialNearbyPlaces() async {
      if (currentPosition.value == null) {
        print('위치 정보가 없어 장소 검색을 건너뜁니다.');
        return;
      }

      try {
        isLoadingPlaces.value = true;
        currentPage.value = 1;
        hasMoreData.value = true;

        print('🚀 초기 장소 검색 시작: ${selectedCategory.value} (20개)');

        final places = await NearbyService.fetchInitialNearbyPlaces(
          latitude: currentPosition.value!.latitude,
          longitude: currentPosition.value!.longitude,
          category: selectedCategory.value,
        );

        // contentId를 안전하게 보장하는 변환 과정
        final safePlaces = places.map((place) {
          return NearbyPlace(
            contentId: place.contentId, // ⭐ 중요: contentId를 명시적으로 유지
            name: place.name,
            address: place.address,
            distance: place.distance,
            category: place.category,
            rating: place.rating,
            isOpen: place.isOpen,
            description: place.description,
            reason: place.reason,
            tip: place.tip,
          );
        }).toList();

        nearbyPlaces.value = safePlaces;

        // contentId 확인 로그 추가
        for (final place in safePlaces) {
          print('📋 초기 장소: ${place.name} (contentId: ${place.contentId})');
        }

        if (places.length < 20) {
          // 20개보다 적으면 더 이상 데이터 없음
          hasMoreData.value = false;
          print('📭 첫 페이지에서 ${places.length}개만 조회됨 - 더 이상 데이터 없음');
        }

        print('✅ 초기 장소 ${places.length}개 로드 완료');

      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: '재시도',
                textColor: AppColors.white,
                onPressed: fetchInitialNearbyPlaces,
              ),
            ),
          );
        }
      } finally {
        isLoadingPlaces.value = false;
      }
    }

    // 추가 주변 장소 검색 (무한 스크롤)
    Future<void> fetchMoreNearbyPlaces() async {
      if (currentPosition.value == null ||
          isLoadingMore.value ||
          !hasMoreData.value ||
          currentPage.value >= maxPages) {
        return;
      }

      try {
        isLoadingMore.value = true;

        final nextPage = currentPage.value + 1;

        print('🔄 추가 장소 검색: ${selectedCategory.value} 페이지 $nextPage');

        final newPlaces = await NearbyService.fetchMoreNearbyPlaces(
          latitude: currentPosition.value!.latitude,
          longitude: currentPosition.value!.longitude,
          category: selectedCategory.value,
          nextPage: nextPage,
        );

        if (newPlaces.isEmpty || newPlaces.length < 20) {
          print('📭 페이지 $nextPage에서 ${newPlaces.length}개 조회 - 더 이상 데이터 없음');
          hasMoreData.value = false;
        }

        if (newPlaces.isNotEmpty) {
          // 새로운 장소들도 안전하게 변환
          final safeNewPlaces = newPlaces.map((place) {
            return NearbyPlace(
              contentId: place.contentId, // ⭐ 중요: contentId를 명시적으로 유지
              name: place.name,
              address: place.address,
              distance: place.distance,
              category: place.category,
              rating: place.rating,
              isOpen: place.isOpen,
              description: place.description,
              reason: place.reason,
              tip: place.tip,
            );
          }).toList();

          // 기존 장소에 새로운 장소 추가 (contentId 안전하게 보장)
          final updatedPlaces = List<NearbyPlace>.from(nearbyPlaces.value);
          updatedPlaces.addAll(safeNewPlaces);
          nearbyPlaces.value = updatedPlaces;

          currentPage.value = nextPage;
          print('✅ 추가 ${safeNewPlaces.length}개 장소 로드 완료 (총 ${updatedPlaces.length}개)');

          // contentId 확인 로그 추가
          for (final place in safeNewPlaces) {
            print('📋 추가된 장소: ${place.name} (contentId: ${place.contentId})');
          }
        }

        // 최대 페이지 도달 체크
        if (currentPage.value >= maxPages) {
          print('🏁 최대 페이지($maxPages) 도달');
          hasMoreData.value = false;
        }

      } catch (e) {
        print('❌ 추가 장소 로드 실패: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('추가 장소를 불러오는데 실패했습니다'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        isLoadingMore.value = false;
      }
    }

    // 카테고리 변경
    void onCategoryChanged(String category) {
      if (selectedCategory.value != category) {
        selectedCategory.value = category;
        nearbyPlaces.value = []; // 기존 장소 초기화
        fetchInitialNearbyPlaces();
      }
    }

    // 현재 위치 가져오기
    Future<void> getCurrentLocation() async {
      try {
        isLoadingLocation.value = true;
        locationError.value = null;

        // 위치 서비스 확인
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 활성화해주세요.');
        }

        // 위치 권한 확인
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception('위치 권한이 거부되었습니다.\n앱 설정에서 위치 권한을 허용해주세요.');
          }
        }

        if (permission == LocationPermission.deniedForever) {
          throw Exception('위치 권한이 영구적으로 거부되었습니다.\n설정 > 앱 > 권한에서 위치 권한을 허용해주세요.');
        }

        // 현재 위치 획득
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );

        currentPosition.value = position;
        currentAddress.value = await getAddressFromPosition(position);

        // 위치 획득 후 초기 주변 장소 검색
        await fetchInitialNearbyPlaces();

      } catch (e) {
        locationError.value = e.toString();
        currentAddress.value = '위치를 가져올 수 없음';

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: '재시도',
                textColor: AppColors.white,
                onPressed: getCurrentLocation,
              ),
            ),
          );
        }
      } finally {
        isLoadingLocation.value = false;
      }
    }

    // 위치 새로고침
    Future<void> refreshLocation() async {
      nearbyPlaces.value = [];
      currentPage.value = 1;
      hasMoreData.value = true;
      await getCurrentLocation();
    }

    // 전체 새로고침
    Future<void> refreshAll() async {
      await refreshLocation();
    }

    // 스크롤 이벤트 리스너
    void onScroll() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        // 하단에서 200px 전에 추가 로딩 시작
        fetchMoreNearbyPlaces();
      }
    }

    // 초기화 및 스크롤 리스너 등록
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getCurrentLocation();
      });

      scrollController.addListener(onScroll);

      return () {
        scrollController.removeListener(onScroll);
      };
    }, []);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: refreshAll,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 헤더
            SliverToBoxAdapter(
              child: CustomHeaderBar(
                title: '내 주변',
                backgroundColor: AppColors.background,
              ),
            ),

            // 위치 정보 및 카테고리 필터
            SliverPadding(
              padding: EdgeInsets.all(AppSizes.spacingM),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    LocationInfoCard(
                      currentAddress: currentAddress.value,
                      isLoading: isLoadingLocation.value,
                      hasError: locationError.value != null,
                      errorMessage: locationError.value,
                      onRefresh: refreshLocation,
                      onCategoryChanged: onCategoryChanged,
                      selectedCategory: selectedCategory.value,
                    ),
                    SizedBox(height: AppSizes.gapL),
                  ],
                ),
              ),
            ),

            // 주변 장소 리스트
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
              sliver: NearbyPlacesList(
                places: nearbyPlaces.value,
                isLoading: isLoadingPlaces.value,
                onRefresh: fetchInitialNearbyPlaces,
                // 페이지 기반 무한 스크롤 정보
                isLoadingMore: isLoadingMore.value,
                hasMoreData: hasMoreData.value,
                currentPage: currentPage.value,
                maxPages: maxPages,
                selectedCategory: selectedCategory.value,
                isLocationLoading: isLoadingLocation.value,
              ),
            ),

            // 하단 여백
            SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.gapXL),
            ),
          ],
        ),
      ),
    );
  }
}
