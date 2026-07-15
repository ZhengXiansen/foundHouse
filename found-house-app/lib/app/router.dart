import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/compare/compare_page.dart';
import '../features/house/house_detail_page.dart';
import '../features/house/house_list_page.dart';
import '../features/scan/quick_record_page.dart';
import '../features/scan/village_detail_page.dart';
import '../features/scan/village_home_page.dart';
import '../features/scoring/score_detail_page.dart';
import '../features/settings/oss_settings_page.dart';
import '../features/settings/preference_page.dart';
import '../features/settings/privacy_page.dart';
import '../features/settings/settings_page.dart';
import 'kawaii_widgets.dart';
import 'motion.dart';
import 'theme.dart';

/// 路由路径常量集中定义，避免魔法字符串散落各处。
///
/// 职责边界：仅声明路径与命名，不含导航业务逻辑；跳转由各页面
/// 通过 `context.go` / `context.push` 调用。
abstract final class AppRoutes {
  const AppRoutes._();

  // 一级 Tab
  static const String scan = '/scan';
  static const String houses = '/houses';
  static const String compare = '/compare';
  static const String settings = '/settings';

  // 二级页面（相对父路由的 path 片段见下方 GoRoute 定义）
  static const String quickRecordName = 'quick-record';
  static const String villageDetailName = 'village-detail';
  static const String buildingHouseListName = 'building-house-list';
  static const String houseDetailName = 'house-detail';
  static const String scoreDetailName = 'score-detail';
  static const String preferenceName = 'preference';
  static const String privacyName = 'privacy';
  static const String ossSettingsName = 'oss-settings';
}

/// 全局导航 Key，供 StatefulShellRoute 与嵌套分支使用。
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// go_router 实例的 Riverpod Provider。
///
/// 用 Provider 暴露便于后续注入鉴权/偏好等 redirect 逻辑（W1-2+），
/// 当前仅提供静态路由树。
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.scan, // 启动默认进入「首页」村列表
    debugLogDiagnostics: true,
    routes: [
      // 一级 4 Tab：StatefulShellRoute.indexedStack 保持各 Tab 状态
      // （对应 UI §10「Tab 状态保持：IndexedStack 或 StatefulShellRoute」）。
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _RootScaffold(navigationShell: navigationShell);
        },
        branches: [
          // 分支 0：首页 / 扫楼
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.scan,
                pageBuilder: (context, state) => _fadeTabPage(
                  state,
                  const VillageHomePage(),
                ),
                routes: [
                  GoRoute(
                    path: 'villages/:villageId',
                    name: AppRoutes.villageDetailName,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _pushPage(
                      state,
                      VillageDetailPage(
                        villageId: state.pathParameters['villageId'] ?? '',
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'buildings/:buildingId/houses',
                        name: AppRoutes.buildingHouseListName,
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) => _pushPage(
                          state,
                          HouseListPage(
                            fixedVillageId:
                                state.pathParameters['villageId'] ?? '',
                            fixedBuildingId:
                                state.pathParameters['buildingId'] ?? '',
                            fixedBuildingName:
                                state.uri.queryParameters['buildingName'],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 快速记录必须带 villageId；缺失时页面会提示回首页选择村。
                  GoRoute(
                    path: AppRoutes.quickRecordName,
                    name: AppRoutes.quickRecordName,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _pushPage(
                      state,
                      QuickRecordPage(
                        villageId: state.uri.queryParameters['villageId'] ?? '',
                        buildingId: state.uri.queryParameters['buildingId'],
                        buildingName: state.uri.queryParameters['buildingName'],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 分支 1：房源
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.houses,
                pageBuilder: (context, state) => _fadeTabPage(
                  state,
                  const HouseListPage(),
                ),
                routes: [
                  GoRoute(
                    path: ':houseId', // 房源详情：/houses/:houseId
                    name: AppRoutes.houseDetailName,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _pushPage(
                      state,
                      HouseDetailPage(
                        houseId: state.pathParameters['houseId'] ?? '',
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'score', // 评分详情：/houses/:houseId/score
                        name: AppRoutes.scoreDetailName,
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) => _pushPage(
                          state,
                          ScoreDetailPage(
                            houseId: state.pathParameters['houseId'] ?? '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // 分支 2：对比
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.compare,
                pageBuilder: (context, state) => _fadeTabPage(
                  state,
                  const ComparePage(),
                ),
              ),
            ],
          ),
          // 分支 3：我的
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) => _fadeTabPage(
                  state,
                  const SettingsPage(),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.preferenceName,
                    name: AppRoutes.preferenceName,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _pushPage(
                      state,
                      const PreferencePage(),
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.privacyName,
                    name: AppRoutes.privacyName,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _pushPage(
                      state,
                      const PrivacyPage(),
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.ossSettingsName,
                    name: AppRoutes.ossSettingsName,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _pushPage(
                      state,
                      const OssSettingsPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('页面不存在')),
      body: Center(
        child: Text('未找到路由：${state.uri}'),
      ),
    ),
  );
});

/// 一级 Tab 切换转场：交叉淡入淡出（UI §2「一级 Tab 切换使用交叉淡入淡出」、
/// §7「Tab 切换 180ms easeOut」）。
CustomTransitionPage<void> _fadeTabPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: AppMotion.tabSwitch,
    reverseTransitionDuration: AppMotion.tabSwitch,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 减少动态效果时 FadeTransition 已是最温和形式，无需额外降级。
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: AppMotion.tabSwitchCurve,
        ),
        child: child,
      );
    },
  );
}

/// 二级页面 push 转场：父子层级进入（UI §7「页面 push 260ms easeOutCubic /
/// pop 220ms easeInOut」）。系统开启减少动态效果时降级为纯淡入。
CustomTransitionPage<void> _pushPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: AppMotion.pagePush,
    reverseTransitionDuration: AppMotion.pagePop,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (AppMotion.animationsDisabled(context)) {
        return FadeTransition(opacity: animation, child: child);
      }
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: AppMotion.pagePushCurve),
      );
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

/// 承载底部导航的根 Scaffold。
///
/// 职责边界：仅负责 4 个一级入口的切换与 IndexedStack 状态保持，
/// 不含任何页面业务逻辑。
class _RootScaffold extends StatelessWidget {
  const _RootScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: KawaiiPressable(
            onTap: null,
            borderRadius: BorderRadius.circular(26),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                // Tapping the active tab still returns to its branch root.
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: '首页',
                ),
                NavigationDestination(
                  icon: Icon(Icons.home_work_outlined),
                  selectedIcon: Icon(Icons.home_work_rounded),
                  label: '房源',
                ),
                NavigationDestination(
                  icon: Icon(Icons.compare_arrows_outlined),
                  selectedIcon: Icon(Icons.compare_arrows_rounded),
                  label: '对比',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: '我的',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
