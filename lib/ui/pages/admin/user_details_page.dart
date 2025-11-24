import 'package:flutter/material.dart';
import '../../../models/user.dart';

class UserDetailsPage extends StatelessWidget {
  final User user;

  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 2,
        title: Text("Detalles de ${user.username}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey.shade900,
                child: const Icon(Icons.person, size: 50, color: Color(0xFF0EA5A4)),
              ),
            ),
            const SizedBox(height: 20),
            _info("Username", user.username),
            _info("Email", user.email),
            _info("Rol", user.role.toUpperCase()),
            _info("ID", user.id.toString()),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
