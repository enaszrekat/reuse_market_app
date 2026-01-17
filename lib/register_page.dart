// ----------------------------------------------------------
// register_page.dart  FIXED VERSION
// ----------------------------------------------------------

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'services/email_service.dart';
import 'localization/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  final Function(Locale) onLangChange;
  const RegisterPage({super.key, required this.onLangChange});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int step = 0;

  // STEP 1
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  // STEP 2
  final country = TextEditingController();
  final city = TextEditingController();
  final street = TextEditingController();
  final house = TextEditingController();

  // STEP 3
  bool wantsSell = true;
  bool wantsTrade = true;
  bool wantsDonate = false;
  bool wantsHomeDelivery = true;

  String preferredLang = "ar";
  final bio = TextEditingController();

  // ----------------------------------------------------------
  // SAVE USER TO DATABASE
  // ----------------------------------------------------------
  Future<bool> saveToDatabase() async {
    final url = Uri.parse("http://localhost/market_app/register.php");

    try {
      final response = await http.post(url, body: {
        "name": name.text.trim(),
        "email": email.text.trim(),
        "password": password.text.trim(),
        "country": country.text.trim(),
        "city": city.text.trim(),
        "street": street.text.trim(),
        "house": house.text.trim(),
        "pickup_point_id": "",
        "can_sell": wantsSell ? "1" : "0",
        "can_trade": wantsTrade ? "1" : "0",
        "can_donate": wantsDonate ? "1" : "0",
        "home_shipping": wantsHomeDelivery ? "1" : "0",
        "preferred_lang": preferredLang,
        "bio": bio.text.trim(),
      });

      return response.statusCode == 200 &&
          response.body.contains("success");
    } catch (_) {
      return false;
    }
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isRtl = ["ar", "he"]
        .contains(Localizations.localeOf(context).languageCode);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: _buildForm(t, isRtl),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations t, bool isRtl) {
    return Container(
      width: 480,
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.only(top: 30),
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
          Align(
            alignment: isRtl ? Alignment.topRight : Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.green),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, "/login"),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            t.t("register"),
            style: const TextStyle(
              color: Colors.green,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),
          Text(
            _stepTitle(t),
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),
          _steps(),
          const SizedBox(height: 20),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildStepContent(t),
          ),

          const SizedBox(height: 30),
          _buttons(t),
        ],
      ),
    );
  }

  // -------------------- Steps ----------------------

  Widget _steps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(0),
        const SizedBox(width: 8),
        _dot(1),
        const SizedBox(width: 8),
        _dot(2),
      ],
    );
  }

  Widget _dot(int i) {
    bool active = step == i;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 28 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? Colors.green : Colors.green.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // ------------------ Step Content ---------------------

  Widget _buildStepContent(AppLocalizations t) {
    if (step == 0) return _step1(t);
    if (step == 1) return _step2(t);
    return _step3(t);
  }

  Widget _step1(AppLocalizations t) {
    return Column(
      key: const ValueKey("step1"),
      children: [
        _input(t.t("full_name"), name),
        const SizedBox(height: 15),
        _input(t.t("email"), email),
        const SizedBox(height: 15),
        _input(t.t("password"), password, isPass: true),
      ],
    );
  }

  Widget _step2(AppLocalizations t) {
    return Column(
      key: const ValueKey("step2"),
      children: [
        _input(t.t("country"), country),
        const SizedBox(height: 15),
        _input(t.t("city"), city),
        const SizedBox(height: 15),
        _input(t.t("street"), street),
        const SizedBox(height: 15),
        _input(t.t("house_number"), house),
      ],
    );
  }

  Widget _step3(AppLocalizations t) {
    return Column(
      key: const ValueKey("step3"),
      children: [
        _switch(t.t("sell_products"), wantsSell,
            (v) => setState(() => wantsSell = v)),
        const SizedBox(height: 10),
        _switch(t.t("trade_products"), wantsTrade,
            (v) => setState(() => wantsTrade = v)),
        const SizedBox(height: 10),
        _switch(t.t("donate_items"), wantsDonate,
            (v) => setState(() => wantsDonate = v)),
        const SizedBox(height: 10),
        _switch(t.t("home_delivery"), wantsHomeDelivery,
            (v) => setState(() => wantsHomeDelivery = v)),
        const SizedBox(height: 20),
        _input(t.t("bio"), bio, maxLines: 3),
      ],
    );
  }

  // ---------------------- NEXT LOGIC ------------------------

  void _next() async {
    if (step < 2) {
      setState(() => step++);
      return;
    }

    bool ok = await saveToDatabase();
    if (!ok) {
      _showError("خطأ في حفظ البيانات");
      return;
    }

    await EmailService.sendEmail(
      toEmail: email.text.trim(),
      name: name.text.trim(),
      language: preferredLang,
    );

    Navigator.pushReplacementNamed(context, "/login");
  }

  // ---------------------- Buttons ---------------------------

  Widget _buttons(AppLocalizations t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (step > 0)
          ElevatedButton(
            onPressed: () => setState(() => step--),
            child: Text(t.t("back")),
          )
        else
          const SizedBox(width: 1),
        ElevatedButton(
          onPressed: _next,
          child:
              Text(step == 2 ? t.t("create_account") : t.t("next")),
        ),
      ],
    );
  }

  // ---------------- Helpers ---------------------

  Widget _input(String label, TextEditingController c,
      {bool isPass = false, int maxLines = 1}) {
    return TextField(
      controller: c,
      obscureText: isPass,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _switch(String title, bool v, Function(bool) on) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        Switch(value: v, onChanged: on),
      ],
    );
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }

  String _stepTitle(AppLocalizations t) {
    if (step == 0) return t.t("step1");
    if (step == 1) return t.t("step2");
    return t.t("step3");
  }
}
