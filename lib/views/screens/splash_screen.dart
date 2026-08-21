import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_logo.dart';

/// First route on launch — checks for a persisted session before deciding
/// whether to land on the dashboard or the login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    final auth = context.read<AuthController>();
    await auth.restoreSession();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      auth.status == AuthStatus.authenticated
          ? AppRoutes.dashboard
          : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(height: 48),
            SizedBox(height: 28),
            CircularProgressIndicator(color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
