import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/admin_auth_controller.dart';

class AdminLoginView extends GetView<AdminAuthController> {
  AdminLoginView({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 20),
                  Text('${AppStrings.appName} Admin',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  const Text('Sign in with your admin account',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    onSubmitted: (_) => controller.signIn(
                      _emailController.text,
                      _passwordController.text,
                    ),
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  Obx(() {
                    final error = controller.errorMessage.value;
                    if (error == null) return const SizedBox(height: 20);
                    return Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(error, style: const TextStyle(color: AppColors.error)),
                    );
                  }),
                  const SizedBox(height: 8),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.signIn(
                                  _emailController.text,
                                  _passwordController.text,
                                ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Sign In'),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
