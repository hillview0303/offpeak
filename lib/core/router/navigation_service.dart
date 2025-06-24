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

  // 기본 네비게이션 메소드들 (GoRouter 래핑)

  /// 경로로 이동 (기존 히스토리 유지)
  /// context.push('/path') 대체
  void navigateTo(String path, {Object? extra}) {
    _router.push(path, extra: extra);
  }

  /// 현재 스택을 모두 제거하고 새 경로로 이동
  /// context.go('/path') 대체
  void pushAndRemoveUntil(String path, {Object? extra}) {
    _router.go(path, extra: extra);
  }

  /// 이름이 있는 라우트로 이동
  /// context.pushNamed('routeName') 대체
  void navigateToNamed(String name, {Map<String, String> pathParameters = const {}, Object? extra}) {
    _router.pushNamed(name, pathParameters: pathParameters, extra: extra);
  }

  /// 현재 페이지를 새 경로로 교체
  /// context.pushReplacement('/path') 대체
  void replaceTo(String path, {Object? extra}) {
    _router.pushReplacement(path, extra: extra);
  }

  /// 이름이 있는 라우트로 교체
  /// context.pushReplacementNamed('routeName') 대체
  void replaceToNamed(String name, {Map<String, String> pathParameters = const {}, Object? extra}) {
    _router.pushReplacementNamed(name, pathParameters: pathParameters, extra: extra);
  }

  /// 뒤로가기
  /// context.pop() 대체
  void goBack([Object? result]) {
    if (_router.canPop()) {
      _router.pop(result);
    }
  }

  /// 특정 경로까지 뒤로가기
  /// context.popUntil() 대체
  void popUntil(String path) {
    while (_router.canPop() && _router.routerDelegate.currentConfiguration.uri.path != path) {
      _router.pop();
    }
  }

  // 추가 유틸리티 메소드들

  /// 현재 위치가 특정 경로인지 확인
  bool isCurrentRoute(String path) {
    return currentLocation == path;
  }

  /// 뒤로갈 수 있는지 확인
  bool canPop() => _router.canPop();

  /// 현재 위치 반환
  String get currentLocation {
    final routerDelegate = _router.routerDelegate;
    final routeInformation = routerDelegate.currentConfiguration;
    return routeInformation.uri.toString();
  }

  /// 특정 라우트가 스택에 있는지 확인
  bool hasRoute(String path) {
    // GoRouter의 스택을 확인하는 로직 구현 필요
    return currentLocation.contains(path);
  }

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

  // 편의 메소드들 (선택사항 - 자주 사용하는 경로들)
  void goHome() => pushAndRemoveUntil(RoutePaths.home);
  void goChat() => pushAndRemoveUntil(RoutePaths.chat);
  void goMy() => pushAndRemoveUntil(RoutePaths.my);
}

/*
라우터 사용법:

기존 GoRouter 방식 → NavigationService 방식
- context.push('/path') → NavigationService.instance.navigateTo('/path')
- context.go('/path') → NavigationService.instance.pushAndRemoveUntil('/path')
- context.pushNamed('routeName') → NavigationService.instance.navigateToNamed('routeName')
- context.pop() → NavigationService.instance.goBack()
- context.pushReplacement('/path') → NavigationService.instance.replaceTo('/path')
- context.pushReplacementNamed('routeName') → NavigationService.instance.replaceToNamed('routeName')

예시:
NavigationService.instance.navigateTo('/home/search');
NavigationService.instance.navigateToNamed('quiet-activities-detail',
  pathParameters: {'categoryType': 'library'},
  extra: {'data': someData}
);
NavigationService.instance.pushAndRemoveUntil('/home');
NavigationService.instance.goBack();
*/
