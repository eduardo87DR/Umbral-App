import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'ui/pages/auth/login_page.dart';
import 'ui/pages/auth/register_page.dart';
import 'ui/pages/user/user_scaffold.dart';
import 'ui/pages/admin/admin_scaffold.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Umbral App',
      theme: AppTheme.dungeonTheme(),
      home: authState.when(
        loading: () => const LoginPage(
        ),
        error: (_, __) => const LoginPage(),

        data: (user) {
          if (user == null) return const LoginPage();

          // Validación automática del rol
          if (user.role == "admin") {
            return const AdminScaffold();
          } else {
            return const UserScaffold();
          }
        },
      ),
      routes: {
        '/login': (c) => const LoginPage(),
        '/register': (c) => const RegisterPage(),
      },
    );
  }
}
