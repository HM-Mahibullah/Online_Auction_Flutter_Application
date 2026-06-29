import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/auth_binding.dart';
import 'bindings/dashboard_binding.dart';
import 'bindings/antique_binding.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'ui/splash/splash_screen.dart';
import 'ui/auth/login_screen.dart';
import 'ui/auth/signup_screen.dart';
import 'ui/dashboard/dashboard_screen.dart';
import 'ui/antique/antique_detail_screen.dart';
import 'ui/add_antique/add_antique_screen.dart';
import 'ui/admin/edit_antique_screen.dart';
import 'ui/auth/forgot_password_screen.dart';
import 'ui/auth/change_password_screen.dart';
import 'ui/notifications/notifications_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Antique Auction',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.initial,
      getPages: [
        GetPage(
          name: AppRoutes.splash,
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: AppRoutes.signup,
          page: () => const SignupScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: AppRoutes.dashboard,
          page: () => const DashboardScreen(),
          binding: DashboardBinding(),
        ),
        GetPage(
          name: AppRoutes.antiqueDetail,
          page: () => const AntiqueDetailScreen(),
          binding: AntiqueBinding(),
        ),
        GetPage(
          name: AppRoutes.addAntique,
          page: () => const AddAntiqueScreen(),
          binding: AntiqueBinding(),
        ),
        GetPage(
          name: AppRoutes.editAntique,
          page: () => const EditAntiqueScreen(),
          binding: AntiqueBinding(),
        ),
        GetPage(
          name: AppRoutes.forgotPassword,
          page: () => const ForgotPasswordScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: AppRoutes.changePassword,
          page: () => const ChangePasswordScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: AppRoutes.notifications,
          page: () => const NotificationsScreen(),
        ),
      ],
    );
  }
}
