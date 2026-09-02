import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'modules/admin/auth/controllers/admin_auth_controller.dart';
import 'routes/admin_pages.dart';
import 'routes/admin_routes.dart';

/// Separate compiled entry point for the admin panel (§31) -- run/build
/// with `-t lib/main_admin.dart`. Shares the student app's Firebase
/// project, models, and repositories, but is otherwise a fully independent
/// app with its own routes, auth gate, and UI shell.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AdminAuthController(), permanent: true);
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PreparationHotspot Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      getPages: AdminPages.routes,
      home: const _AdminSessionGate(),
    );
  }
}

/// Skips the login screen if there's already a valid admin session
/// (persisted Firebase Auth) -- otherwise falls through to login.
class _AdminSessionGate extends StatefulWidget {
  const _AdminSessionGate();

  @override
  State<_AdminSessionGate> createState() => _AdminSessionGateState();
}

class _AdminSessionGateState extends State<_AdminSessionGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isAdmin = await Get.find<AdminAuthController>().checkExistingSession();
      Get.offAllNamed(isAdmin ? AdminRoutes.dashboard : AdminRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
