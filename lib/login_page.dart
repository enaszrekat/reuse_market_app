import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  final Function(Locale) onLangChange;
  const LoginPage({super.key, required this.onLangChange});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();

  final String serverUrl = "http://localhost/market_app/login.php";
  bool loading = false;

  String currentLang = "en";

  Future<bool> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        body: {"email": email, "password": password},
      );

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("user_id", data["user"]["id"].toString());
        prefs.setString("name", data["user"]["name"]);
        prefs.setString("email", data["user"]["email"]);
        return true;
      }
      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // 🔥 زر تغيير اللغة
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors.green.shade50,
                      value: currentLang,
                      icon: const Icon(Icons.language, color: Colors.black),
                      style: const TextStyle(color: Colors.black),
                      items: const [
                        DropdownMenuItem(value: "en", child: Text("English")),
                        DropdownMenuItem(value: "ar", child: Text("العربية")),
                        DropdownMenuItem(value: "he", child: Text("עברית")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => currentLang = value);
                          widget.onLangChange(Locale(value));
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 🌿 اللوجو (مكبّر)
              Image.asset(
                "assets/logo.png",
                width: 230,
                height: 230,
              ),

              const SizedBox(height: 25),

              // 📩 Email
              _input(t.t("email"), email, false),

              const SizedBox(height: 14),

              // 🔒 Password
              _input(t.t("password"), pass, true),

              const SizedBox(height: 20),

              // زر تسجيل الدخول أخضر
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() => loading = true);

                    bool ok = await loginUser(
                      email.text.trim(),
                      pass.text.trim(),
                    );

                    setState(() => loading = false);

                    if (ok) {
                      Navigator.pushReplacementNamed(context, "/home");
                    } else {
                      _error(locale);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          t.t("login"),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              // Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t.t("no_account"),
                    style: const TextStyle(color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/register");
                    },
                    child: Text(
                      t.t("register"),
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/admin-login");
                },
                child: Text(
                  t.t("admin_login"),
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller, bool isPass) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14),
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
              ? "❌ البريد الإلكتروني أو كلمة المرور غير صحيحة"
              : locale.languageCode == "he"
                  ? "❌ שגיאה באימייל או סיסמה"
                  : "❌ Incorrect email or password",
        ),
      ),
    );
  }
}
