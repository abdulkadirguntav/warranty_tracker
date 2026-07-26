import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/warranty_item.dart';
import '../../l10n/app_localizations.dart';
import '../screens/add_edit_screen.dart';
import '../screens/appearance_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/details_screen.dart';

/// Configures the application's navigation graph using GoRouter.
///
/// The router exposes both imperative ([go], [push]) and declarative usage
/// through [appRouter]. Path constants live in [AppConstants] so they can
/// be referenced from anywhere without importing the router.
final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.routeHome,
  routes: [
    GoRoute(
      path: AppConstants.routeHome,
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppConstants.routeAddEdit,
      name: 'addEdit',
      // `extra` may be a [WarrantyItem] (edit mode) or null (add mode).
      builder: (context, state) {
        final extra = state.extra;
        return AddEditScreen(
          existingItem: extra is WarrantyItem ? extra : null,
        );
      },
    ),
    GoRoute(
      path: '${AppConstants.routeDetails}/:id',
      name: 'details',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailsScreen(itemId: id);
      },
    ),
    GoRoute(
      path: AppConstants.routeAppearance,
      name: 'appearance',
      builder: (context, state) => const AppearanceScreen(),
    ),
  ],
  errorBuilder: (context, state) => _RouteNotFoundScreen(error: state.error),
);

class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen({this.error});
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.notFound)),
      body: Center(child: Text('${l.routeNotFound}\n$error')),
    );
  }
}
