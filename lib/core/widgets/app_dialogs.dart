import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Centered popup dialogs used app-wide instead of snackbars -- every
/// error/success/confirmation the user needs to acknowledge should go
/// through here so feedback always looks and behaves consistently.
class AppDialogs {
  AppDialogs._();

  static void error(String message, {String title = 'Something went wrong'}) {
    _showStatusDialog(
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.error,
      iconBg: AppColors.weakBg,
    );
  }

  static void success(String message, {String title = 'Success'}) {
    _showStatusDialog(
      title: title,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.strong,
      iconBg: AppColors.strongBg,
    );
  }

  static void info(String message, {String title = 'Heads up'}) {
    _showStatusDialog(
      title: title,
      message: message,
      icon: Icons.info_outline_rounded,
      iconColor: AppColors.primary,
      iconBg: AppColors.primaryLight,
    );
  }

  static void _showStatusDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      _PopupShell(
        icon: icon,
        iconColor: iconColor,
        iconBg: iconBg,
        title: title,
        message: message,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Two-button confirmation popup. Returns true if the user confirmed.
  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await Get.dialog<bool>(
      _PopupShell(
        icon: isDestructive ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
        iconColor: isDestructive ? AppColors.error : AppColors.primary,
        iconBg: isDestructive ? AppColors.weakBg : AppColors.primaryLight,
        title: title,
        message: message,
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(result: false),
              child: Text(cancelLabel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: isDestructive
                  ? ElevatedButton.styleFrom(backgroundColor: AppColors.error)
                  : null,
              onPressed: () => Get.back(result: true),
              child: Text(confirmLabel),
            ),
          ),
        ],
        actionsInRow: true,
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }
}

class _PopupShell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String message;
  final List<Widget> actions;
  final bool actionsInRow;

  const _PopupShell({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.message,
    required this.actions,
    this.actionsInRow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            actionsInRow ? Row(children: actions) : Column(children: actions),
          ],
        ),
      ),
    );
  }
}
