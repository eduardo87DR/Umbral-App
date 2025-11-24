import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePass = true;

  Future<void> _handleRegister() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    // Hacemos la petición manualmente con control de respuesta
    final repo = ref.read(authRepoProvider);
    await repo.api.post('/auth/register', {
      'username': _userCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passCtrl.text.trim(),
    });

    //Login automatico
    await ref.read(authStateProvider.notifier).login(
      _userCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    // Si llega aquí, significa que el registro fue exitoso
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
    }

  } catch (e) {
    String message = 'No se pudo completar el registro.';

    // Detectar si el backend devolvió conflicto de usuario existente
    final error = e.toString().toLowerCase();
    if (error.contains('already exists') ||
        error.contains('400') ||
        error.contains('username') && error.contains('exists')) {
      message = 'El nombre de usuario o correo ya está registrado.';
    } else if (error.contains('network') || error.contains('connection')) {
      message = 'Error de conexión. Verifica tu red.';
    }

    setState(() {
      _error = message;
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
        title: const Text('Ritual de Ingreso'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A), Color(0xFF2B1E36)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Efecto radiante
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
          // Efecto blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // Contenido
          Center(
            child: Container(
              width: 360,
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
                        Icons.auto_fix_high_outlined,
                        color: Colors.amberAccent,
                        size: 60,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Forja tu Identidad',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(
                                  color: Colors.deepPurpleAccent,
                                  blurRadius: 8,
                                )
                              ],
                            ),
                      ),
                      const SizedBox(height: 24),
                      // Usuario
                      TextFormField(
                        controller: _userCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nombre de Aventurero',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon:
                              const Icon(Icons.person_outline, color: Colors.white70),
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
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      const SizedBox(height: 16),
                      // Correo
                      TextFormField(
                        controller: _emailCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Correo Mágico',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon:
                              const Icon(Icons.email_outlined, color: Colors.white70),
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
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obligatorio';
                          if (!v.contains('@')) return 'Correo no válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Contraseña
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscurePass,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Clave Secreta',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon:
                              const Icon(Icons.lock_outline, color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obligatorio';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 70, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          shadowColor: Colors.purpleAccent.withOpacity(0.7),
                          elevation: 10,
                        ),
                        onPressed: _loading ? null : _handleRegister,
                        child: _loading
                            ? const LoadingWidget(message: 'Forjando identidad...')
                            : const Text(
                                'Registrarme',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushReplacementNamed('/login'),
                        child: const Text(
                          'Ya tengo cuenta',
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
