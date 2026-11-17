import 'package:flutter/material.dart';
import '../models/models.dart';
import 'admin/admin_shell.dart';

class AdminScreen extends StatelessWidget {
  final UserProfile? profile;

  const AdminScreen({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    final activeProfile = profile ??
        UserProfile(
          id: 3,
          name: 'Verifier Admin',
          email: 'admin@traceback.app',
          role: 'admin',
        );

    return AdminShell(profile: activeProfile);
  }
}
