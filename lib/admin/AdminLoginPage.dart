import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class AdminLoginPage extends StatefulWidget {
  final Function(Locale) onLangChange;

  const AdminLoginPage({super.key, required this.onLangChange});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  // ✅ IP الصحيح حسب جهازك
  final String serverUrl = "http://10.100.11.28/market_app/admin_login.php";

  Future<bool> loginAdmin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        body: {"email": email, "password": password},
      );

      print("ADMIN RESPONSE: ${response.body}");

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        return true;
      }
      return false;
    } catch (e) {
      print("ADMIN LOGIN ERROR: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final t = AppLocalizations(locale);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            children: [
              Text(
                t.t("admin_login"),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 35),

              Container(
                padding: const EdgeInsets.all(26),
                width: 420,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.admin_panel_settings,
                        size: 60, color: Colors.green),

                    const SizedBox(height: 15),

                    Text(
                      t.t("admin_login"),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 25),

                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        labelText: t.t("email"),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: t.t("password"),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() => loading = true);

                          bool ok = await loginAdmin(
                            email.text.trim(),
                            password.text.trim(),
                          );

                          setState(() => loading = false);

                          if (ok) {
                            Navigator.pushReplacementNamed(
                                context, "/admin-dashboard");
                          } else {
                            _error(locale);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                t.t("admin_login"),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _error(Locale locale) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          locale.languageCode == "ar"
              ? "❌ خطأ في البريد الإلكتروني أو كلمة المرور"
              : locale.languageCode == "he"
                  ? "❌ שגיאה במייל או סיסמה"
                  : "❌ Incorrect email or password",
        ),
      ),
    );
  }
}
