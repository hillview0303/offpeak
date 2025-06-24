import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:offpeak/core/router/router.dart';

class NavigationService {
  NavigationService._();

  static final NavigationService _instance = NavigationService._();
  static NavigationService get instance => _instance;

  // 라우터 인스턴스 참조
  GoRouter get _router => AppRouter.router;

  // 더블 백 버튼 처리용 변수들
  static DateTime? _lastBackPressed;
  static const Duration _backPressThreshold = Duration(seconds: 2);

  // 기본 네비게이션 메소드들
  /// 경로로 이동 (기존 히스토리 유지)
  void navigateTo(String path) {
    _router.push(path);
  }

  /// 현재 스택을 모두 제거하고 새 경로로 이동
  void pushAndRemoveUntil(String path) {
    _router.go(path);
  }

  /// 뒤로가기
  void goBack() {
    if (_router.canPop()) {
      _router.pop();
    }
  }

  /// 현재 페이지를 새 경로로 교체
  void replaceTo(String path) {
    _router.pushReplacement(path);
  }

  // 편의 메소드들 (특정 페이지로 바로 이동)
  void goHome() => pushAndRemoveUntil(RoutePaths.home);
  void goChat() => pushAndRemoveUntil(RoutePaths.chat);
  void goActivity() => pushAndRemoveUntil(RoutePaths.my);
  void goAlgorithmRecommendation() => navigateTo(RoutePaths.algorithmRecommendation);

  // 백버튼 처리 메소드
  Future<bool> handleBackPress(BuildContext context) async {
    // 현재 라우터에서 뒤로갈 수 있는지 확인
    if (_router.canPop()) {
      _router.pop();
      return false;
    }

    // 메인 페이지에서 더블 백 처리
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > _backPressThreshold) {
      _lastBackPressed = now;

      // 스낵바로 안내 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('뒤로가기 버튼을 한 번 더 누르면 앱이 종료됩니다.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false; // 앱 종료 방지
    }

    // 두 번째 백 버튼 누름 - 앱 종료
    SystemNavigator.pop();
    return true;
  }

  bool canPop() => _router.canPop();

  String get currentLocation {
    final routerDelegate = _router.routerDelegate;
    final routeInformation = routerDelegate.currentConfiguration;
    return routeInformation.uri.toString();
  }

  void clearAndNavigateTo(String path) {
    pushAndRemoveUntil(path);
  }
}
