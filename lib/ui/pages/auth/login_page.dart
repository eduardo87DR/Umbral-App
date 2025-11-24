import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';

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
  bool _obscurePass = true; 

  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(authStateProvider.notifier)
          .login(_userCtrl.text.trim(), _passCtrl.text.trim());

      final authState = ref.read(authStateProvider);

      if (authState is AsyncData && authState.value != null) {
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/main', (route) => false);
        }
      } else {
        setState(() {
          _error = 'Las credenciales no coinciden con ninguna cuenta existente';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Las credenciales no coinciden con ninguna cuenta existente';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Puerta del Guardián'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A), Color(0xFF2B1E36)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.deepPurpleAccent.withOpacity(0.3),
                    Colors.transparent
                  ],
                  radius: 0.9,
                ),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Center(
            child: Container(
              width: 350,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.deepPurpleAccent.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_moon_outlined,
                        color: Colors.amberAccent,
                        size: 60,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ingreso al Umbral',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                const Shadow(
                                  color: Colors.deepPurpleAccent,
                                  blurRadius: 8,
                                )
                              ],
                            ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _userCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nombre de Usuario',
                          labelStyle:
                              const TextStyle(color: Colors.white70, fontSize: 14),
                          prefixIcon: const Icon(Icons.person_outline,
                              color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.deepPurpleAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.amberAccent, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscurePass, // Usa el estado para ocultar/mostrar
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle:
                              const TextStyle(color: Colors.white70, fontSize: 14),
                          prefixIcon:
                              const Icon(Icons.lock_outline, color: Colors.white70),
                          // Agregamos el icono de visibilidad
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off // Oculta
                                  : Icons.visibility, // Visible
                              color: Colors.deepPurpleAccent,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass), 
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.deepPurpleAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.amberAccent, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          shadowColor: Colors.purpleAccent.withOpacity(0.7),
                          elevation: 10,
                        ),
                        onPressed: _loading ? null : _handleLogin,
                        child: _loading
                            ? const LoadingWidget(message: 'Entrando al calabozo...')
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2),
                              ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushReplacementNamed('/register'),
                        child: const Text(
                          'Registrarme',
                          style: TextStyle(
                            color: Colors.white70,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}