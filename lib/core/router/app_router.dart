import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/main/main_shell.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/vehicle/vehicle_detail_screen.dart';
import '../../screens/vehicle/add_edit_vehicle_screen.dart';
import '../../screens/fuel/fuel_list_screen.dart';
import '../../screens/fuel/add_edit_fuel_screen.dart';
import '../../screens/maintenance/maintenance_list_screen.dart';
import '../../screens/maintenance/add_edit_maintenance_screen.dart';
import '../../screens/statistics/statistics_screen.dart';
import '../../screens/profile/profile_screen.dart';

/// Route names
class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String dashboard = '/home/dashboard';
  static const String vehicleDetail = '/vehicle/:id';
  static const String addVehicle = '/vehicle/add';
  static const String editVehicle = '/vehicle/:id/edit';
  static const String fuelList = '/home/fuel';
  static const String addFuel = '/home/fuel/add';
  static const String editFuel = '/home/fuel/:id/edit';
  static const String maintenanceList = '/home/maintenance';
  static const String addMaintenance = '/home/maintenance/add';
  static const String editMaintenance = '/home/maintenance/:id/edit';
  static const String statistics = '/home/statistics';
  static const String profile = '/home/profile';
}

// ─── Router Provider (cần Ref để watch authState) ─────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  // Lắng nghe auth state để refresh router
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: _AuthChangeNotifier(ref),
    redirect: (context, state) {
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isAuthRoute = state.matchedLocation.startsWith('/login');

      // Splash và onboarding luôn cho qua
      if (isSplash || isOnboarding) return null;

      // Chưa đăng nhập → về login
      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;

      // Đã đăng nhập → không ở màn login nữa
      if (isLoggedIn && isAuthRoute) return AppRoutes.dashboard;

      return null;
    },
    routes: [
      // ===== AUTH & SPLASH =====
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'register',
            name: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
        ],
      ),

      // ===== MAIN SHELL (BottomNavBar) =====
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.fuelList,
            name: 'fuelList',
            builder: (context, state) => const FuelListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'addFuel',
                builder: (context, state) => const AddEditFuelScreen(),
              ),
              GoRoute(
                path: ':fuelId/edit',
                name: 'editFuel',
                builder: (context, state) {
                  final fuelId = state.pathParameters['fuelId']!;
                  return AddEditFuelScreen(fuelId: fuelId);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.maintenanceList,
            name: 'maintenanceList',
            builder: (context, state) => const MaintenanceListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'addMaintenance',
                builder: (context, state) =>
                    const AddEditMaintenanceScreen(),
              ),
              GoRoute(
                path: ':maintId/edit',
                name: 'editMaintenance',
                builder: (context, state) {
                  final maintId = state.pathParameters['maintId']!;
                  return AddEditMaintenanceScreen(
                      maintenanceId: maintId);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.statistics,
            name: 'statistics',
            builder: (context, state) => const StatisticsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ===== VEHICLE (outside shell for full-screen) =====
      GoRoute(
        path: '/vehicle/add',
        name: 'addVehicle',
        builder: (context, state) => const AddEditVehicleScreen(),
      ),
      GoRoute(
        path: '/vehicle/:id',
        name: 'vehicleDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VehicleDetailScreen(vehicleId: id);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: 'editVehicle',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AddEditVehicleScreen(vehicleId: id);
            },
          ),
        ],
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Trang không tìm thấy',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ─── Listenable để GoRouter lắng nghe auth state thay đổi ────────────────────
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen<AsyncValue<User?>>(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
}

