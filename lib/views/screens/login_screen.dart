import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';

/// Split-screen login — navy brand panel on the left, credentials card on
/// the right. Purely presentational: "Log in" simply routes into the app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    final auth = context.read<AuthController>();
    final success = await auth.login(email: email, password: password);
    if (!mounted || !success) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showBrandPanel = Responsive.width(context) >= AppSizes.tablet;
    final auth = context.watch<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Row(
        children: [
          if (showBrandPanel) const Expanded(flex: 5, child: _BrandPanel()),
          Expanded(
            flex: 7,
            child: ColoredBox(
              color: const Color(0xFFF7F9FC),
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x140F244D),
                            blurRadius: 28,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: _LoginForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        onToggleObscure: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onLogin: _login,
                        isLoading: auth.isLoading,
                        errorMessage: auth.errorMessage,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark navy brand panel with the logo and the "Welcome back." message.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101A38), AppColors.navy],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -70,
            bottom: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 44, 48, 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(width: 8, height: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'G-TEC ',
                            style: AppTextStyles.jakarta(
                              size: 16,
                              weight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                          TextSpan(
                            text: 'Education',
                            style: AppTextStyles.jakarta(
                              size: 16,
                              weight: FontWeight.w600,
                              color: AppColors.roleAdmin,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Welcome back.',
                  style: AppTextStyles.jakarta(
                    size: 32,
                    weight: FontWeight.w800,
                    color: AppColors.white,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 330),
                  child: Text(
                    'Pick up exactly where you left off — your progress, '
                    'notes and downloads are synced across devices.',
                    style: AppTextStyles.jakarta(
                      size: 14,
                      weight: FontWeight.w500,
                      color: AppColors.notifBody,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onLogin,
    required this.isLoading,
    required this.errorMessage,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            height: 140,
            child: Lottie.asset(
              'assets/lottie/login.json',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Log in to continue',
            style: AppTextStyles.jakarta(
              size: 25,
              weight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            "Welcome back — let's keep going.",
            style: AppTextStyles.jakarta(
              size: 14,
              weight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Email address', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        _LoginField(
          controller: emailController,
          hint: 'you@example.com',
          leadingIconPaths: AppIcons.mail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Password', style: AppTextStyles.fieldLabel),
            GestureDetector(
              onTap: () {},
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  'Forgot password?',
                  style: AppTextStyles.jakarta(
                    size: 12.5,
                    weight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _LoginField(
          controller: passwordController,
          hint: 'Enter your password',
          leadingIconPaths: AppIcons.lock,
          obscureText: obscurePassword,
          trailing: GestureDetector(
            onTap: onToggleObscure,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AppIcon(
                obscurePassword ? AppIcons.eye : AppIcons.eyeOff,
                size: 18,
                color: AppColors.grey,
                strokeWidth: 1.8,
              ),
            ),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.redBg,
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
            ),
            child: Text(
              errorMessage!,
              style: AppTextStyles.jakarta(
                size: 12.5,
                weight: FontWeight.w600,
                color: AppColors.red,
              ),
            ),
          ),
        ],
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: isLoading ? null : onLogin,
            child: MouseRegion(
              cursor: isLoading
                  ? SystemMouseCursors.forbidden
                  : SystemMouseCursors.click,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isLoading
                      ? AppColors.navy.withValues(alpha: 0.6)
                      : AppColors.navy,
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                ),
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppColors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Log in',
                            style: AppTextStyles.jakarta(
                              size: 14.5,
                              weight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const AppIcon(
                            AppIcons.arrowRight,
                            size: 16,
                            color: AppColors.white,
                            strokeWidth: 2.2,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bordered credential input: leading icon + editable text + optional
/// trailing action (used for the password visibility toggle).
class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.hint,
    required this.leadingIconPaths,
    this.obscureText = false,
    this.trailing,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final String leadingIconPaths;
  final bool obscureText;
  final Widget? trailing;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      ),
      child: Row(
        children: [
          AppIcon(
            leadingIconPaths,
            size: 17,
            color: AppColors.grey,
            strokeWidth: 1.8,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: AppTextStyles.jakarta(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.ink,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                hintText: hint,
                hintStyle: AppTextStyles.jakarta(
                  size: 14,
                  weight: FontWeight.w500,
                  color: AppColors.grey,
                ),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
