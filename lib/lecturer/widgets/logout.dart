import 'package:flutter/material.dart';

import '../../auth_storage.dart';
import '../../login.dart';

/// Icon button that logs the lecturer out after confirmation.
class LecturerLogoutButton extends StatefulWidget {
  const LecturerLogoutButton({
    super.key,
    this.iconColor = Colors.white,
  });

  final Color iconColor;

  @override
  State<LecturerLogoutButton> createState() => _LecturerLogoutButtonState();
}

class _LecturerLogoutButtonState extends State<LecturerLogoutButton> {
  bool _busy = false;

  Future<void> _confirmAndLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _logout();
  }

  Future<void> _logout() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await AuthStorage.clearUserId();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Logout',
      onPressed: _busy ? null : _confirmAndLogout,
      icon: _busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.logout, color: widget.iconColor),
    );
  }
}
