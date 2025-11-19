import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../auth_storage.dart';
import '../../login.dart';
import '../config.dart';

/// Icon button that logs the lecturer out after confirmation.
class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key, this.iconColor = Colors.white});

  final Color iconColor;

  @override
  State<LogoutButton> createState() => LogoutButtonState();
}

class LogoutButtonState extends State<LogoutButton> {
  bool busy = false;

  Future<void> confirmAndLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => LogoutDialog(
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    if (ok != true) return;
    await logout();
  }

  Future<void> logout() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      try {
        final cookie = await AuthStorage.getSessionCookie();
        final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/logout'),
          headers: cookie != null ? {'cookie': cookie} : null,
        );
        if (response.statusCode >= 400) {
          debugPrint(
            'Logout API failed: ${response.statusCode} ${response.body}',
          );
        }
      } catch (e) {
        debugPrint('Logout API error: $e');
      }
      await AuthStorage.clearUserId();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Logout',
      onPressed: busy ? null : confirmAndLogout,
      icon: busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.logout, color: widget.iconColor),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({required this.onConfirm, required this.onCancel});

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    const accent = Color.fromARGB(255, 210, 245, 160);
    const dark = Color(0xFF1F1F1F);
    return AlertDialog(
      backgroundColor: dark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      title: const Text(
        'Logout',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: const Text(
        'Are you sure you want to log out?',
        style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 15, height: 1.4),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF424242)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: onConfirm,
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
