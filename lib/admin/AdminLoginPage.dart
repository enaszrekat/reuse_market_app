import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../theme/app_theme.dart';
import '../components/premium_logo.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool loading = false;

  Future<void> _login() async {
    if (_username.text.isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter username and password")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}admin_login.php"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "username": _username.text.trim(),
          "password": _password.text.trim(),
        },
      );

      debugPrint("ADMIN LOGIN RESPONSE: ${response.body}");

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("is_admin", true);
        await prefs.setInt("admin_id", data["admin"]["id"]);

        if (!mounted) return;

        // ✅ اسم الراوت الصحيح
        Navigator.pushReplacementNamed(context, "/admin-dashboard");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data["message"]}")),
        );
      }
    } catch (e) {
      debugPrint("ADMIN LOGIN ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server connection error")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.backgroundDark,
        iconTheme: const IconThemeData(color: AppTheme.primaryGreen),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGreen),
          onPressed: () {
            // Navigate back to home/login page
            Navigator.pushReplacementNamed(context, "/login");
          },
          tooltip: "Back to Home",
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: AppTheme.paddingPage,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Logo - Centered and Constrained
                Center(
                  child: PremiumLogoWithIcon(
                    height: 140,
                    showSubtitle: false,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppTheme.primaryGreen,
                      const Color(0xFF50E5B7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    "Admin Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXLarge),

                // Username
                TextField(
                  controller: _username,
                  style: AppTheme.textStyleBody,
                  decoration: InputDecoration(
                    labelText: "Username",
                    labelStyle: AppTheme.textStyleBodySecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLarge),

                // Password
                TextField(
                  controller: _password,
                  obscureText: true,
                  style: AppTheme.textStyleBody,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: AppTheme.textStyleBodySecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXLarge),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: AppTheme.primaryButtonStyle,
                    onPressed: loading ? null : _login,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Login",
                            style: AppTheme.textStyleBody,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
