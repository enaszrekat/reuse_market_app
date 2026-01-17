import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  Future<bool> _isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_admin") ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdmin(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == false) {
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, "/admin-login");
          });
          return const SizedBox();
        }

        return child;
      },
    );
  }
}
