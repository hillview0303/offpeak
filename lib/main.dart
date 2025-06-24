import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants/color.dart';
import 'core/router/router.dart';
import 'core/service/unified_laas_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // .env 파일 로드
    await dotenv.load(fileName: ".env");
    print('✅ 환경변수 로드 완료');

    // LaaS API 연결 상태 확인
    final isLaaSConnected = await UnifiedLaaSAPIService.checkAPIConnection();
    if (isLaaSConnected) {
      print('✅ LaaS API 연결 확인 완료');
    } else {
      print('⚠️ LaaS API 연결 실패 - 앱은 제한된 기능으로 실행됩니다');
    }

    // LaaS AI API 연결 상태 확인
    final isLaaSAiConnected = await UnifiedLaaSAPIService.checkAIConnection();
    if (isLaaSAiConnected) {
      print('✅ LaaS AI API 연결 확인 완료');
    } else {
      print('⚠️ LaaS AI API 연결 실패 - AI 추천 기능이 제한됩니다');
    }

    runApp(
      ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e) {
    print('⚠️ 앱 초기화 중 오류 발생: $e');
    // 오류가 발생해도 앱은 실행 (기본값으로 동작)
    runApp(
      ProviderScope(
        child: MyApp(),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'OffPeak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Pretendard',
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // 앱 전체에 초기화 상태 체크 래퍼 추가
        return AppInitializationWrapper(child: child ?? Container());
      },
    );
  }
}

/// 앱 초기화 상태를 관리하는 래퍼 위젯
class AppInitializationWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppInitializationWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppInitializationWrapper> createState() => _AppInitializationWrapperState();
}

class _AppInitializationWrapperState extends ConsumerState<AppInitializationWrapper> {
  bool _isChecking = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkInitialization();
  }

  Future<void> _checkInitialization() async {
    try {
      print('🔄 LaaS 서비스 연결 상태 확인 중...');

      // LaaS API 연결 확인
      final isApiConnected = await UnifiedLaaSAPIService.checkAPIConnection();
      final isAiConnected = await UnifiedLaaSAPIService.checkAIConnection();

      if (!isApiConnected && !isAiConnected) {
        throw Exception('LaaS 서비스에 연결할 수 없습니다');
      }

      setState(() {
        _isChecking = false;
        _hasError = false;
        _errorMessage = '';
      });

      print('✅ 앱 초기화 검증 완료');

      if (!isApiConnected) {
        print('⚠️ LaaS API 연결 실패 - 관광지 정보 기능 제한');
      }

      if (!isAiConnected) {
        print('⚠️ LaaS AI API 연결 실패 - AI 추천 기능 제한');
      }

    } catch (e) {
      print('⚠️ 초기화 재시도 실패: $e');
      setState(() {
        _isChecking = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 초기화 중이면 로딩 화면 표시
    if (_isChecking) {
      return MaterialApp(
        home: InitializationLoadingScreen(),
        debugShowCheckedModeBanner: false,
      );
    }

    // 초기화 실패시 경고 배너와 함께 앱 실행
    if (_hasError) {
      return Stack(
        children: [
          widget.child,
          // 상단에 경고 배너 표시
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                color: Colors.orange.withOpacity(0.9),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'LaaS 서비스 연결 실패 - 일부 기능이 제한될 수 있습니다',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _hasError = false;
                        });
                      },
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return widget.child;
  }
}

/// 초기화 로딩 화면
class InitializationLoadingScreen extends StatefulWidget {
  @override
  State<InitializationLoadingScreen> createState() => _InitializationLoadingScreenState();
}

class _InitializationLoadingScreenState extends State<InitializationLoadingScreen> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _simulateLoadingSteps();
  }

  void _simulateLoadingSteps() async {
    // 환경설정 확인
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _currentStep = 1);
    }

    // LaaS API 연결
    await Future.delayed(Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _currentStep = 2);
    }

    // AI 서비스 연결
    await Future.delayed(Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _currentStep = 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고 또는 브랜드 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.landscape,
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),

            // 로딩 인디케이터
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),

            // 로딩 메시지
            Text(
              'OffPeak',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'LaaS 서비스에 연결하는 중...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 80),

            // 진행 상태 표시
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _buildLoadingStep('환경설정 확인', _currentStep >= 1),
                  SizedBox(height: 8),
                  _buildLoadingStep('LaaS API 연결', _currentStep >= 2),
                  SizedBox(height: 8),
                  _buildLoadingStep('AI 서비스 연결', _currentStep >= 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStep(String title, bool isCompleted) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.white
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isCompleted
              ? Icon(Icons.check, size: 12, color: AppColors.primary)
              : SizedBox(
            width: 8,
            height: 8,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: isCompleted
                ? Colors.white
                : Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// LaaS API 초기화 상태를 확인하는 Provider
final laasInitializationProvider = FutureProvider<Map<String, bool>>((ref) async {
  try {
    final isApiConnected = await UnifiedLaaSAPIService.checkAPIConnection();
    final isAiConnected = await UnifiedLaaSAPIService.checkAIConnection();

    return {
      'api': isApiConnected,
      'ai': isAiConnected,
      'overall': isApiConnected || isAiConnected, // 하나라도 연결되면 OK
    };
  } catch (e) {
    print('LaaS 초기화 실패: $e');
    return {
      'api': false,
      'ai': false,
      'overall': false,
    };
  }
});

/// LaaS 연결 재시도 Provider
final retryLaaSConnectionProvider = FutureProvider.family<Map<String, bool>, void>((ref, _) async {
  try {
    // 연결 재시도
    final isApiConnected = await UnifiedLaaSAPIService.checkAPIConnection();
    final isAiConnected = await UnifiedLaaSAPIService.checkAIConnection();

    return {
      'api': isApiConnected,
      'ai': isAiConnected,
      'overall': isApiConnected || isAiConnected,
    };
  } catch (e) {
    print('LaaS 재연결 실패: $e');
    return {
      'api': false,
      'ai': false,
      'overall': false,
    };
  }
});

/// 앱 상태 정보 Provider
final appStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final laasStatus = ref.watch(laasInitializationProvider);

  return laasStatus.when(
    data: (status) => {
      'isReady': status['overall'] ?? false,
      'hasApiAccess': status['api'] ?? false,
      'hasAiAccess': status['ai'] ?? false,
      'message': _getStatusMessage(status),
    },
    loading: () => {
      'isReady': false,
      'hasApiAccess': false,
      'hasAiAccess': false,
      'message': 'LaaS 서비스 연결 중...',
    },
    error: (error, stack) => {
      'isReady': false,
      'hasApiAccess': false,
      'hasAiAccess': false,
      'message': 'LaaS 서비스 연결 실패: $error',
    },
  );
});

String _getStatusMessage(Map<String, bool> status) {
  final hasApi = status['api'] ?? false;
  final hasAi = status['ai'] ?? false;

  if (hasApi && hasAi) {
    return '모든 서비스가 정상적으로 연결되었습니다';
  } else if (hasApi && !hasAi) {
    return '관광지 정보는 이용 가능하나 AI 추천 기능이 제한됩니다';
  } else if (!hasApi && hasAi) {
    return 'AI 기능은 이용 가능하나 관광지 정보가 제한됩니다';
  } else {
    return 'LaaS 서비스에 연결할 수 없습니다. 네트워크를 확인해주세요';
  }
}
