import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../widgets/loading_widget.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Puerta del Guardián')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Ingreso al Calabozo', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Usuario')),
              const SizedBox(height: 8),
              TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
              const SizedBox(height: 12),
              if (_error != null) Text(_error!, style: const TextStyle(color: AppTheme.danger)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loading ? null : () async {
                  setState(() { _loading = true; _error = null; });
                  try {
                    await ref.read(authStateProvider.notifier).login(_userCtrl.text.trim(), _passCtrl.text.trim());
                    // en caso de exito, navegador a Home
                    Navigator.of(context).pushReplacementNamed('/home');
                  } catch (e) {
                    setState(() { _error = 'Login falló: ${e.toString()}'; });
                  } finally {
                    setState(() { _loading = false; });
                  }
                },
                child: _loading ? 
                const LoadingWidget(message: 'Entrando al calabozo...')
                : const Text('Entrar')
              ),
              TextButton(onPressed: () => Navigator.of(context).pushNamed('/register'), child: const Text('Registrarme'))
            ]),
          ),
        ),
      ),
    );
  }
}
