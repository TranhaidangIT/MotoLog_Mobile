import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motolog_mobile/features/auth/providers/auth_provider.dart';
import 'package:motolog_mobile/providers/shared_preferences_provider.dart';
import 'package:motolog_mobile/core/constants/app_constants.dart';
// Screens mới
import 'package:motolog_mobile/features/auth/screens/login_screen.dart';
import 'package:motolog_mobile/features/onboarding_screen.dart';
import 'package:motolog_mobile/features/home_screen.dart';
import 'package:motolog_mobile/features/fuel/screens/fuel_log_screen.dart';
import 'package:motolog_mobile/features/fuel/screens/fuel_history_screen.dart';
import 'package:motolog_mobile/features/maintenance/screens/maintenance_screen.dart';
import 'package:motolog_mobile/features/reminder/screens/reminder_screen.dart';
import 'package:motolog_mobile/features/statistics/screens/expense_screen.dart';
import 'package:motolog_mobile/features/statistics/screens/statistics_screen.dart';
import 'package:motolog_mobile/features/vehicle/screens/my_vehicle_screen.dart';
import 'package:motolog_mobile/features/maintenance/screens/add_maintenance_screen.dart';
import 'package:motolog_mobile/features/auth/screens/register_screen.dart';
import 'package:motolog_mobile/features/profile/screens/profile_screen.dart';
import 'package:motolog_mobile/features/vehicle/screens/add_edit_vehicle_screen.dart';
import 'package:motolog_mobile/features/vehicle/screens/add_vehicle_method_screen.dart';
import 'package:motolog_mobile/features/vehicle/screens/quick_setup_vehicle_screen.dart';
import 'package:motolog_mobile/features/garage_screen.dart';
import 'package:motolog_mobile/features/maintenance/screens/parts_screen.dart';
import 'package:motolog_mobile/features/maintenance/screens/add_part_screen.dart';

/// Định nghĩa tên các màn hình (Route Names) sử dụng trong toàn bộ ứng dụng
class AppRoutes {
  AppRoutes._();
  static String onboarding = '/onboarding';
  static String login = '/login';
  static String home = '/home';
  static String addFuel = '/fuel-log';
  static String fuelHistory = '/fuel-history';
  static String maintenance = '/maintenance';
  static String reminder = '/reminder';
  static String expense = '/expense';
  static String statistics = '/statistics';
  static String myVehicle = '/my-vehicle';
  static String garage = '/garage';
  static String register = '/register';
  static String addMaintenance = '/add-maintenance';
  static String addVehicle = '/add-vehicle';
  static String addVehicleManual = '/add-vehicle-manual';
  static String quickSetupVehicle = '/quick-setup-vehicle';
  static String parts = '/parts';
  static String addPart = '/add-part';
  static String profile = '/profile';
}

/// Provider cấu hình và quản lý hệ thống định tuyến (Routing) của ứng dụng bằng GoRouter.
/// Tự động chuyển hướng (Redirect) dựa trên Trạng thái Đăng nhập và Onboarding.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  
  final onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    refreshListenable: _AuthChangeNotifier(ref),
    redirect: (context, state) {
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isLoginRoute = state.matchedLocation.startsWith(AppRoutes.login);
      final isRegisterRoute = state.matchedLocation.startsWith(AppRoutes.register);

      // Chưa đăng nhập -> đá về Login (trừ login, register, và onboarding)
      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute && state.matchedLocation != AppRoutes.onboarding) {
        if (!onboardingDone) {
          return AppRoutes.onboarding;
        }
        return AppRoutes.login;
      }

      // Đã đăng nhập nhưng cố vào Login/Onboarding -> đẩy vào Home
      if (isLoggedIn && (isLoginRoute || state.matchedLocation == AppRoutes.onboarding)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
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
        path: AppRoutes.statistics,
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
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
        name: 'addVehicleMethod',
        builder: (context, state) => const AddVehicleMethodScreen(),
      ),
      GoRoute(
        path: AppRoutes.addVehicleManual,
        name: 'addVehicleManual',
        builder: (context, state) => const AddEditVehicleScreen(),
      ),
      GoRoute(
        path: AppRoutes.quickSetupVehicle,
        name: 'quickSetupVehicle',
        builder: (context, state) => const QuickSetupVehicleScreen(),
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
