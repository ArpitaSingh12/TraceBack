import 'package:flutter/material.dart';
import '../models/models.dart';
import 'admin/admin_shell.dart';
import 'customer/customer_shell.dart';
import 'producer/producer_shell.dart';

class HomeScreen extends StatelessWidget {
  final UserProfile? userProfile;

  const HomeScreen({super.key, this.userProfile});

  @override
  Widget build(BuildContext context) {
    final profile = userProfile ??
        UserProfile(
          id: 0,
          name: 'Customer',
          email: 'customer@traceback.app',
          role: 'customer',
        );

    final role = UserRoleHelper.normalize(profile.role);

    if (role == 'admin') {
      return AdminShell(profile: profile);
    }

    if (role == 'producer') {
      return ProducerShell(profile: profile);
    }

    return CustomerShell(profile: profile);
  }
}
