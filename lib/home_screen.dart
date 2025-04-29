import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';
import 'services_screen.dart';
import 'contact_screen.dart';
import 'login_screen.dart'; // Ensure this screen exists
import 'api_service.dart';  // Ensure AuthService.logout() is defined

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ProfileScreen(),
    const StatsScreen(),
    ServicesScreen(),
    const ContactUsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Logout'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await AuthService.logout();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: "Services",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: "Contact Us",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _logout(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.logout),
        tooltip: 'Logout',
      ),
    );
  }
}
