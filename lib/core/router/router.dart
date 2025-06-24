import 'package:go_router/go_router.dart';
import '../../features/chat/presentation/chat_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/presentation/pages/algorithm_recommendation_page.dart';
import '../../features/home/presentation/pages/search_page.dart';
import '../../features/home/presentation/pages/nearby_page.dart';
import '../../features/home/presentation/pages/favorites_page.dart';
import '../../features/home/presentation/pages/recent_activity_page.dart';
import '../../features/main/presentation/pages/error_page.dart';
import '../../features/main/presentation/pages/main_page.dart';
import '../../features/my/presentation/pages/my_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter _router = GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainPage(navigationShell: navigationShell);
        },
        branches: [
          // 홈 브랜치 (index: 0)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'algorithm-recommendation',
                    builder: (context, state) => const AlgorithmRecommendationPage(),
                  ),
                  GoRoute(
                    path: 'search',
                    builder: (context, state) => const SearchPage(),
                  ),
                  GoRoute(
                    path: 'nearby',
                    builder: (context, state) => const NearbyPage(),
                  ),
                  GoRoute(
                    path: 'favorites',
                    builder: (context, state) => const FavoritesPage(),
                  ),
                  GoRoute(
                    path: 'recent',
                    builder: (context, state) => const RecentActivityPage(),
                  ),
                ],
              ),
            ],
          ),
          // 챗 브랜치 (index: 1)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.chat,
                builder: (context, state) => const ChatPage(),
                routes: [
                  // 필요시 채팅 관련 하위 페이지 추가
                ],
              ),
            ],
          ),
          // 마이 브랜치 (index: 2)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.my,
                builder: (context, state) => const MyPage(),
                routes: [
                  // 필요시 마이페이지 하위 페이지 추가
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
  );

  static GoRouter get router => _router;
}

// 라우트 경로들
class RoutePaths {
  static const String home = '/home';
  static const String chat = '/chat';
  static const String my = '/my';  // activity → my로 수정

  // 홈 하위 경로들
  static const String algorithmRecommendation = '/home/algorithm-recommendation';
  static const String search = '/home/search';
  static const String nearby = '/home/nearby';
  static const String favorites = '/home/favorites';
  static const String recent = '/home/recent';
}
