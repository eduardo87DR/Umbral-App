import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'admin_users_page.dart';
import 'admin_events_page.dart';
import 'admin_guides_page.dart';
import 'admin_notifications_page.dart';
import '../shared/profile_page.dart';
class AdminScaffold extends StatefulWidget {
  const AdminScaffold({Key? key}) : super(key: key);

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  int _index = 0;

  final pages = const [
    AdminDashboard(),
    UsersAdminPage(),
    AdminEventsPage(),
    AdminGuidesPage(),
    AdminNotificationsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Colors.amberAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Eventos'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Guías'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
