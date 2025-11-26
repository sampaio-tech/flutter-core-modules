import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_design_system/ios_design_system.dart';

class ShellRouteWidget extends HookConsumerWidget {
  final List<NavigationTab> tabs;
  final Color? activeColor;

  const ShellRouteWidget({required this.tabs, super.key, this.activeColor});

  Future<bool> _handleSystemBack({
    required NavigationTab currentTab,
    required BuildContext context,
  }) async {
    final navigatorState = currentTab.navigatorKey(context).currentState;
    if (navigatorState == null) {
      return false;
    }
    if (navigatorState.canPop()) {
      navigatorState.pop();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useCupertinoTabController(
      initialIndex: max(0, tabs.indexWhere((tab) => tab.initialTab)),
    );
    final theme = IosTheme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final currentTab = tabs[controller.index];
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final allow = await _handleSystemBack(
              currentTab: currentTab,
              context: context,
            );
            if (allow) Navigator.of(context).maybePop();
          },
          child: CupertinoTabScaffold(
            controller: controller,
            tabBar: CupertinoTabBar(
              activeColor: activeColor ?? theme.acessibleColors.systemGreen,
              items: tabs
                  .map(
                    (navigationTab) => BottomNavigationBarItem(
                      icon: Icon(navigationTab.icon),
                      label: navigationTab.label(context),
                    ),
                  )
                  .toList(),
              onTap: (index) {
                final tapped = tabs[index];
                final navigatorKey = tapped.navigatorKey(context);
                if (tapped == currentTab) {
                  navigatorKey.currentState?.popUntil((route) => route.isFirst);
                  return;
                }
                controller.index = index;
              },
            ),
            tabBuilder: (context, index) {
              final tab = tabs[index];
              return HookConsumer(
                builder: (context, ref, child) {
                  final navigatorKey = useMemoized(
                    () => tab.navigatorKey(context),
                    [tab, context],
                  );
                  return CupertinoTabView(
                    navigatorKey: navigatorKey,
                    routes: tab.routes,
                    defaultTitle: tab.defaultTitle(context),
                    navigatorObservers: tab.navigatorObservers(context),
                    restorationScopeId: tab.restorationScopeId,
                    onGenerateRoute: tab.onGenerateRoute,
                    onUnknownRoute: tab.onUnknownRoute,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

abstract class NavigationTab {
  final String name;
  final IconData icon;
  final bool initialTab;
  final Widget Function(BuildContext)? builder;
  final Route<dynamic>? Function(RouteSettings)? onGenerateRoute;
  final Route<dynamic>? Function(RouteSettings)? onUnknownRoute;

  final String? restorationScopeId;

  const NavigationTab({
    required this.name,
    required this.icon,
    this.initialTab = false,
    this.builder,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.restorationScopeId,
  });

  GlobalKey<NavigatorState> navigatorKey(BuildContext context) =>
      ProviderScope.containerOf(context).read(navigatiorKeyProvider(this));

  String label(BuildContext context);

  String? defaultTitle(BuildContext context) => null;

  Map<String, Widget Function(BuildContext)>? get routes;

  List<NavigatorObserver> navigatorObservers(BuildContext context) => [];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NavigationTab &&
        other.name == name &&
        other.icon == icon &&
        other.initialTab == initialTab &&
        other.builder == builder &&
        mapEquals(other.routes, routes) &&
        other.onGenerateRoute == onGenerateRoute &&
        other.onUnknownRoute == onUnknownRoute &&
        other.restorationScopeId == restorationScopeId;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        icon.hashCode ^
        initialTab.hashCode ^
        builder.hashCode ^
        routes.hashCode ^
        onGenerateRoute.hashCode ^
        onUnknownRoute.hashCode ^
        restorationScopeId.hashCode;
  }
}

final navigatiorKeyProvider =
    Provider.family<GlobalKey<NavigatorState>, NavigationTab?>(
      (ref, args) => GlobalKey<NavigatorState>(),
    );
