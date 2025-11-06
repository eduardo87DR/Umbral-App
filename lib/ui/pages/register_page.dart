import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Aventurero')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Crea tu Identidad de Héroe',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre de Usuario'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: AppTheme.danger)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() {
                            _loading = true;
                            _error = null;
                          });
                          try {
                            await ref
                                .read(authStateProvider.notifier)
                                .register(_userCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text.trim());
                            Navigator.of(context).pushReplacementNamed('/home');
                          } catch (e) {
                            setState(() {
                              _error = 'Registro falló: ${e.toString()}';
                            });
                          } finally {
                            setState(() {
                              _loading = false;
                            });
                          }
                        },
                  child: _loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Registrarme'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                  child: const Text('Ya tengo cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
