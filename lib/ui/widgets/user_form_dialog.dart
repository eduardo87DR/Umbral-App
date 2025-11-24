import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user.dart';
import '../../../providers/users_provider.dart';
import '../../../theme/app_theme.dart';

class UserFormDialog extends ConsumerStatefulWidget {
  final User? user;

  const UserFormDialog({super.key, this.user});

  @override
  ConsumerState<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  bool _saving = false;

  final RegExp _emailRegExp = RegExp(r"^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$");

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username ?? "");
    _emailController = TextEditingController(text: widget.user?.email ?? "");
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final notifier = ref.read(usersListProvider.notifier);

    try {
      if (widget.user != null) {
        await _updateUser(notifier);
      } else {
        await _createUser();
      }
    } catch (e) {
      _showErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateUser(UsersNotifier notifier) async {
    await notifier.updateUser(widget.user!.id, {
      "username": _usernameController.text.trim(),
      "email": _emailController.text.trim(),
    });

    if (mounted) Navigator.pop(context);
    await ref.read(usersListProvider.notifier).load();
    _showSuccessSnackbar(context, "Usuario actualizado correctamente.");
  }

  Future<void> _createUser() async {
    if (mounted) Navigator.pop(context);
    _showInfoSnackbar(context, "Crear usuario no implementado en backend.");
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Dialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isEdit),
            const SizedBox(height: 20),
            _buildForm(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEdit) {
    return Text(
      isEdit ? "Editar Usuario" : "Crear Usuario",
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUsernameField(),
          const SizedBox(height: 16),
          _buildEmailField(),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: _inputDecoration(
        "Username",
        icon: Icons.person,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Este campo no puede estar vacío.";
        }
        if (value.trim().length < 3) {
          return "El username debe tener al menos 3 caracteres.";
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: _inputDecoration(
        "Email",
        icon: Icons.email,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Este campo no puede estar vacío.";
        }
        if (!_emailRegExp.hasMatch(value.trim())) {
          return "Email inválido.";
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label, {required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      prefixIcon: Icon(icon, color: AdminTheme.adminAccent),
      filled: true,
      fillColor: AdminTheme.adminCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AdminTheme.adminAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.danger),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.danger),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.textSecondary,
          ),
          child: const Text("Cancelar"),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminTheme.adminAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _saving ? null : _saveUser,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "Guardar",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.accent,
        content: Text(message),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text("Error al guardar: $error"),
      ),
    );
  }

  void _showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }
}