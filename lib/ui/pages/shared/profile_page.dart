import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authStateProvider.notifier).logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  Future<void> _showEditProfileModal(
    BuildContext context,
    WidgetRef ref,
    String currentUsername,
    String currentEmail,
  ) async {
    final usernameController = TextEditingController(text: currentUsername);
    final emailController = TextEditingController(text: currentEmail);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            color: Colors.amberAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  labelStyle: TextStyle(color: Colors.white70),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'El nombre no puede estar vacío';
                  if (v.trim().length < 3)
                    return 'Debe tener al menos 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  labelStyle: TextStyle(color: Colors.white70),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'El correo no puede estar vacío';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                    return 'Correo inválido';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await ref.read(authRepoProvider).updateProfile({
                    "username": usernameController.text.trim(),
                    "email": emailController.text.trim(),
                  });
                  await ref.read(authStateProvider.notifier).refreshUser();
                  if (context.mounted) Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Perfil actualizado correctamente"),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al actualizar: $e")),
                  );
                }
              }
            },
            child: const Text(
              'Guardar cambios',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordModal(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final pass1 = TextEditingController();
    final pass2 = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        bool obscure1 = true;
        bool obscure2 = true;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Cambiar contraseña',
              style: TextStyle(
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: pass1,
                    obscureText: obscure1,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      labelStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurpleAccent),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure1 ? Icons.visibility_off : Icons.visibility,
                          color: Colors.deepPurpleAccent,
                        ),
                        onPressed: () => setState(() => obscure1 = !obscure1),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'No puede estar vacía';
                      if (v.length < 6)
                        return 'Debe tener al menos 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: pass2,
                    obscureText: obscure2,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      labelStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurpleAccent),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure2 ? Icons.visibility_off : Icons.visibility,
                          color: Colors.deepPurpleAccent,
                        ),
                        onPressed: () => setState(() => obscure2 = !obscure2),
                      ),
                    ),
                    validator: (v) {
                      if (v != pass1.text)
                        return 'Las contraseñas no coinciden';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      await ref.read(authRepoProvider).updateProfile({
                        "password": pass1.text.trim(),
                      });
                      if (context.mounted) Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Contraseña actualizada correctamente"),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error al actualizar contraseña: $e"),
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Actualizar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authStateProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Perfil del Aventurero'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.amberAccent),
            tooltip: 'Cerrar sesión',
            onPressed: () => _handleLogout(context, ref),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D0D0D),
                  Color(0xFF1B1322),
                  Color(0xFF2B1E36),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.deepPurpleAccent.withOpacity(0.25),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          userState.when(
            data: (user) {
              if (user == null) {
                return const Center(
                  child: Text(
                    "No hay sesión activa",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return Center(
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.deepPurpleAccent.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurpleAccent.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.deepPurpleAccent,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.deepPurpleAccent,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Divider(height: 32, color: Colors.deepPurpleAccent),
                      ListTile(
                        leading: const Icon(
                          Icons.edit,
                          color: Colors.amberAccent,
                        ),
                        title: const Text(
                          'Editar perfil',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white38,
                          size: 18,
                        ),
                        onTap: () => _showEditProfileModal(
                          context,
                          ref,
                          user.username,
                          user.email,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(
                          Icons.lock,
                          color: Colors.amberAccent,
                        ),
                        title: const Text(
                          'Cambiar contraseña',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white38,
                          size: 18,
                        ),
                        onTap: () => _showChangePasswordModal(context, ref),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent),
            ),
            error: (e, _) => Center(
              child: Text(
                'Error: $e',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
