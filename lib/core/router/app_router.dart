import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shared_preferences_provider.dart';
// Screens mới
import '../../screens/splash_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/fuel_log_screen.dart';
import '../../screens/fuel_history_screen.dart';
import '../../screens/statistics_screen.dart';
import '../../screens/maintenance_screen.dart';
import '../../screens/reminder_screen.dart';
import '../../screens/expense_screen.dart';
import '../../screens/my_vehicle_screen.dart';
import '../../screens/add_maintenance_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/vehicle/add_edit_vehicle_screen.dart';
import '../../screens/garage_screen.dart';
import '../../screens/parts_screen.dart';
import '../../screens/add_part_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String addFuel = '/fuel-log';
  static const String fuelHistory = '/fuel-history';
  static const String statistics = '/statistics';
  static const String maintenance = '/maintenance';
  static const String reminder = '/reminder';
  static const String expense = '/expense';
  static const String myVehicle = '/my-vehicle';
  static const String garage = '/garage';
  static const String register = '/register';
  static const String addMaintenance = '/add-maintenance';
  static const String addVehicle = '/add-vehicle';
  static const String parts = '/parts';
  static const String addPart = '/add-part';

  // Backwards compatibility cho UI cũ không báo lỗi
  static const String dashboard = '/home/dashboard';
  
  static const String profile = '/profile';
  static const String fuelList = '/home/fuel-list';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  
  // Tạm thời bỏ qua logic Onboarding để đơn giản hóa giao diện mới.
  // final onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: _AuthChangeNotifier(ref),
    redirect: (context, state) {
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isLoginRoute = state.matchedLocation.startsWith(AppRoutes.login);
      final isRegisterRoute = state.matchedLocation.startsWith(AppRoutes.register);

      // Cho phép ở SplashScreen
      if (isSplash) return null;

      // Chưa đăng nhập -> đá về Login (trừ login và register)
      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
        return AppRoutes.login;
      }

      // Đã đăng nhập nhưng cố vào Login -> đẩy vào Home
      if (isLoggedIn && isLoginRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.addFuel,
        name: 'addFuel',
        builder: (context, state) => const FuelLogScreen(),
      ),
      GoRoute(
        path: AppRoutes.fuelHistory,
        name: 'fuelHistory',
        builder: (context, state) => const FuelHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.statistics,
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.maintenance,
        name: 'maintenance',
        builder: (context, state) => const MaintenanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.reminder,
        name: 'reminder',
        builder: (context, state) => const ReminderScreen(),
      ),
      GoRoute(
        path: AppRoutes.expense,
        name: 'expense',
        builder: (context, state) => const ExpenseScreen(),
      ),
      GoRoute(
        path: AppRoutes.myVehicle,
        name: 'myVehicle',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return MyVehicleScreen(vehicleId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMaintenance,
        name: 'addMaintenance',
        builder: (context, state) => const AddMaintenanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.addVehicle,
        name: 'addVehicle',
        builder: (context, state) => const AddEditVehicleScreen(),
      ),
      GoRoute(
        path: AppRoutes.garage,
        name: 'garage',
        builder: (context, state) => const GarageScreen(),
      ),
      GoRoute(
        path: AppRoutes.parts,
        name: 'parts',
        builder: (context, state) => const PartsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addPart,
        name: 'addPart',
        builder: (context, state) => const AddPartScreen(),
      ),
    ],
  );
});

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen<AsyncValue<User?>>(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
}
