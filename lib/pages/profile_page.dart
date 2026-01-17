import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Loading...";
  String email = "Loading...";
  String country = "Loading...";
  String accountType = "Regular User";
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id") ?? 0;

      if (userId == 0) {
        if (mounted) {
          setState(() {
            loading = false;
            errorMessage = "Please login to view profile";
            userName = "Not logged in";
            email = "N/A";
            country = "N/A";
          });
        }
        return;
      }

      // Ensure baseUrl ends with /
      final base = AppConfig.baseUrl.endsWith('/') 
          ? AppConfig.baseUrl 
          : '${AppConfig.baseUrl}/';
      final url = "${base}get_user.php";
      
      debugPrint("ProfilePage: Fetching user data from: $url");
      debugPrint("ProfilePage: User ID: $userId");
      
      final response = await http.post(
        Uri.parse(url),
        body: {"user_id": userId.toString()},
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Request timeout");
        },
      );

      debugPrint("ProfilePage: Response status: ${response.statusCode}");
      debugPrint("ProfilePage: Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}");

      if (response.statusCode == 404) {
        throw Exception("Endpoint not found (404). Please ensure get_user.php exists in your XAMPP htdocs/market_app/ directory.");
      }
      
      if (response.statusCode != 200) {
        throw Exception("Server returned status ${response.statusCode}");
      }

      if (response.body.isEmpty || response.body.trim().isEmpty) {
        throw Exception("Empty response from server");
      }

      if (response.body.contains('<!DOCTYPE') || response.body.contains('<html')) {
        throw Exception("Server returned HTML error. Check backend PHP files.");
      }

      final data = json.decode(response.body);

      if (!mounted) return;

      if (data["status"] == "success" && data["user"] != null) {
        final user = data["user"];
        setState(() {
          userName = user["name"] ?? user["username"] ?? "User";
          email = user["email"] ?? "N/A";
          country = user["country"] ?? "N/A";
          accountType = user["account_type"] ?? user["role"] ?? "Regular User";
          loading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          loading = false;
          errorMessage = data["message"] ?? "Failed to load user data";
          userName = "Error";
          email = "N/A";
          country = "N/A";
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
      if (mounted) {
        setState(() {
          loading = false;
          errorMessage = "Error: ${e.toString()}";
          userName = "Error";
          email = "N/A";
          country = "N/A";
        });
      }
    }
  }

  Future<void> _logout() async {
    // Clear cart on logout
    final cartService = Provider.of<CartService>(context, listen: false);
    await cartService.clearCart();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        title: const Text("Profile", style: AppTheme.textStyleTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.primaryGreen),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🔥 BLACK & GREEN GRADIENT
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0D0D0D),
                  const Color(0xFF0E1412),
                  const Color(0xFF151E1B),
                  Colors.black,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ✨ GREEN Circles
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3DDC97).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3DDC97).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 🟡 CONTENT
          loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                )
              : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppTheme.errorRed,
                            size: AppTheme.iconSizeXLarge,
                          ),
                          const SizedBox(height: AppTheme.spacingLarge),
                          Text(
                            errorMessage!,
                            style: AppTheme.textStyleBodySecondary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacingLarge),
                          ElevatedButton(
                            onPressed: _loadUserData,
                            style: AppTheme.primaryButtonStyle,
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Avatar
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(0xFF3DDC97).withOpacity(0.2),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF3DDC97),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Username
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // INFO BOXES
                          _infoCard(Icons.email, "Email", email),
                          const SizedBox(height: 16),

                          _infoCard(Icons.flag, "Country", country),
                          const SizedBox(height: 16),

                          _infoCard(Icons.person, "Account Type", accountType),
                          const SizedBox(height: 30),

                          // LOGOUT BUTTON - Make it more visible
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF3DDC97),
                                width: 2,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: _logout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3DDC97),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.logout, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }

  // 🟦 REUSABLE INFO CARD
  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3DDC97).withOpacity(0.3)),
        color: Colors.white.withOpacity(0.06),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3DDC97), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
