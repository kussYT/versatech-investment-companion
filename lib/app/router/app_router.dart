import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:versatech_investment_companion/app/router/app_shell.dart';
import 'package:versatech_investment_companion/features/dashboard/presentation/dashboard_screen.dart';
import 'package:versatech_investment_companion/features/explorer/presentation/explorer_screen.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/portfolio_screen.dart';
import 'package:versatech_investment_companion/features/simulator/presentation/simulator_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explorer',
                builder: (context, state) => const ExplorerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/portfolio',
                builder: (context, state) => const PortfolioScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/simulator',
                builder: (context, state) => const SimulatorScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
