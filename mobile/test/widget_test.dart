import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:traceback/data/demo_data.dart';
import 'package:traceback/models/models.dart';
import 'package:traceback/screens/admin/admin_shell.dart';
import 'package:traceback/screens/auth/login_screen.dart';
import 'package:traceback/screens/customer/customer_shell.dart';
import 'package:traceback/screens/producer/producer_shell.dart';
import 'package:traceback/screens/product_detail_screen.dart';
import 'package:traceback/theme/app_theme.dart';

void main() {
  testWidgets('LoginScreen renders brand, inputs, and demo accounts', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: const LoginScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('TraceBack'), findsWidgets);
    expect(find.text('Know the journey behind every product.'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Producer'), findsOneWidget);
    expect(find.text('Verifier / Admin'), findsOneWidget);
  });

  test('UserRoleHelper correctly normalizes role strings', () {
    expect(UserRoleHelper.normalize('admin'), 'admin');
    expect(UserRoleHelper.normalize('ADMINISTRATOR'), 'admin');
    expect(UserRoleHelper.normalize('verifier'), 'admin');
    expect(UserRoleHelper.normalize('producer'), 'producer');
    expect(UserRoleHelper.normalize('supplier'), 'producer');
    expect(UserRoleHelper.normalize('farmer'), 'producer');
    expect(UserRoleHelper.normalize('customer'), 'customer');
    expect(UserRoleHelper.normalize(''), 'customer');
    expect(UserRoleHelper.normalize(null), 'customer');
  });

  testWidgets('CustomerShell renders navigation destinations', (WidgetTester tester) async {
    final profile = UserProfile(
      id: 1,
      name: 'Ananya Sharma',
      email: 'customer@traceback.app',
      role: 'customer',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: CustomerShell(profile: profile),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Scan QR'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('ProducerShell renders navigation destinations', (WidgetTester tester) async {
    final profile = UserProfile(
      id: 2,
      name: 'Rajesh Nambiar',
      email: 'producer@traceback.app',
      role: 'producer',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: ProducerShell(profile: profile),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Batches'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('AdminShell renders navigation destinations', (WidgetTester tester) async {
    final profile = UserProfile(
      id: 3,
      name: 'Dr. Vikramaditya Rao',
      email: 'admin@traceback.app',
      role: 'admin',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: AdminShell(profile: profile),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Verification'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('ProductDetailScreen renders product info and transparency score', (WidgetTester tester) async {
    final product = DemoData.getProducts().first;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: ProductDetailScreen(product: product),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text(product.name), findsWidgets);
    expect(find.text('Transparency Index'), findsOneWidget);
    expect(find.text('Product Narrative'), findsOneWidget);
  });
}
