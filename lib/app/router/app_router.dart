import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:versatech_investment_companion/app/router/app_shell.dart';
import 'package:versatech_investment_companion/features/dashboard/presentation/dashboard_screen.dart';
import 'package:versatech_investment_companion/features/asset_detail/presentation/asset_detail_screen.dart';
import 'package:versatech_investment_companion/features/explorer/presentation/explorer_screen.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/portfolio_screen.dart';
import 'package:versatech_investment_companion/features/portfolio/presentation/position_form_screen.dart';
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
                routes: [
                  GoRoute(
                    path: ':symbol',
                    builder: (context, state) {
                      final symbol = state.pathParameters['symbol'] ?? '';
                      return AssetDetailScreen(
                        symbol: symbol,
                        assetType: state.uri.queryParameters['type'],
                      );
                    },
                  ),
                ],
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
                builder: (context, state) {
                  return SimulatorScreen(
                    initialSymbol: state.uri.queryParameters['symbol'] ?? '',
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/portfolio/new',
        builder: (context, state) {
          return PositionFormScreen(
            initialSymbol: state.uri.queryParameters['symbol'] ?? '',
          );
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
