import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  // -------------------------------------------------------------------
  //                     🔹 INTERNAL HELPERS
  // -------------------------------------------------------------------

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // -------------------------------------------------------------------
  //                     🔹 GET ALL USERS (WEB)
  // -------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getUsers() async {
    final pref = await _prefs;
    final raw = pref.getString("users_db");

    if (raw == null) {
      final initial = [
        {
          "id": "1",
          "name": "Einas",
          "email": "einas@example.com",
          "password": "123123",
          "country": "Israel",
          "city": "Haifa",
          "street": "-",
          "house": "-",
          "joined": DateTime.now().toIso8601String(),
          "trades": 4,
          "sales": 6,
          "avatar": null,
          "lang": "ar",
          "bio": "",
          "prefs": {
            "sell": true,
            "trade": true,
            "donate": false,
            "homeDelivery": true,
          }
        },
      ];

      await pref.setString("users_db", jsonEncode(initial));
      return initial;
    }

    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  Future<void> saveUsers(List<Map<String, dynamic>> users) async {
    final pref = await _prefs;
    await pref.setString("users_db", jsonEncode(users));
  }

  // -------------------------------------------------------------------
  //                  🔹 REGISTER USER (WEB)
  // -------------------------------------------------------------------
  Future<void> registerUser(Map<String, dynamic> user) async {
    final users = await getUsers();

    // Add unique ID
    user["id"] = DateTime.now().millisecondsSinceEpoch.toString();
    user["joined"] = DateTime.now().toIso8601String();

    users.add(user);

    await saveUsers(users);

    // Send welcome email (mock)
    await sendWelcomeEmail(user["email"], user["name"]);
  }

  // -------------------------------------------------------------------
  //                    🔹 LOGIN USER (WEB)
  // -------------------------------------------------------------------
  Future<Map<String, dynamic>?> loginUser(String email, String pass) async {
    final users = await getUsers();

    try {
      return users.firstWhere(
        (u) => u["email"] == email && u["password"] == pass,
      );
    } catch (e) {
      return null;
    }
  }

  // -------------------------------------------------------------------
  //                    🔹 SAVE AVATAR
  // -------------------------------------------------------------------
  Future<void> saveAvatar(String userId, String base64) async {
    final users = await getUsers();
    final index = users.indexWhere((u) => u["id"] == userId);

    if (index == -1) return;

    users[index]["avatar"] = base64;
    await saveUsers(users);
  }

  // -------------------------------------------------------------------
  //                    🔹 ADMIN LOGIN (TEMP)
  // -------------------------------------------------------------------
  Future<Map<String, dynamic>?> loginAdmin(String email, String pass) async {
    if (email == "admin@app.com" && pass == "admin123") {
      return {
        "name": "Main Admin",
        "email": "admin@app.com",
        "role": "admin",
      };
    }
    return null;
  }

  // -------------------------------------------------------------------
  //            🔹 SEND WELCOME EMAIL (SIMULATED FOR NOW)
  // -------------------------------------------------------------------
  Future<void> sendWelcomeEmail(String email, String name) async {
    // لاحقاً نربط API فعلي، الآن فقط console
    debugPrint("📩 Sending Welcome email to: $email");

    String message = """
    שלום $name 💛
    
    תודה שנרשמת לאפליקציה שלנו!
    שמחים שיש אותך כאן 🤍  
    מקווים שתהני מהקניה, החלפה והמסחר 😊
    """;

    debugPrint(message);
  }
}
