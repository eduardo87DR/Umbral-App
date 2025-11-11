import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'ui/pages/login_page.dart';
import 'ui/pages/register_page.dart';
import 'ui/pages/notification_page.dart';
import 'ui/pages/main_scaffold.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Umbral App',
      theme: AppTheme.dungeonTheme(),
      initialRoute: '/',
      routes: {
        '/': (c) => const LoginPage(),
        '/login': (c) => const LoginPage(),
        '/register': (c) => const RegisterPage(),
        '/main': (c) => const MainScaffold(), 
        '/notifications': (c) => const NotificationPage(),
      },
    );
  }
}
