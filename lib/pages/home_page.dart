import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../config.dart';
import '../theme/app_theme.dart';
import '../components/premium_logo.dart';

class HomePage extends StatefulWidget {
  final Function(Locale) onLangChange;
  const HomePage({super.key, required this.onLangChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List products = [];
  bool loading = true;
  int unread = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _loadApprovedProducts();
    _loadUnreadNotifications();
  }

  Future<void> _loadApprovedProducts() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}get_approved_products.php"),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Request timeout");
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Server returned status ${response.statusCode}");
      }

      if (response.body.isEmpty || response.body.trim().isEmpty) {
        throw Exception("Empty response from server");
      }

      if (response.body.contains('<!DOCTYPE') || response.body.contains('<html')) {
        throw Exception("Server returned HTML error");
      }

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        setState(() {
          products = data["products"] ?? [];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Error loading approved products: $e");
      setState(() => loading = false);
    }
  }

  Future<void> _loadUnreadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id") ?? 0;

    if (userId == 0) return;

    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}get_unread_notifications.php?user_id=$userId"),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return http.Response("", 408);
        },
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = json.decode(response.body);
        if (data["status"] == "success") {
          setState(() {
            unread = data["unread"] ?? 0;
          });
        }
      }
    } catch (e) {
      // Silently fail for notifications
      debugPrint("Error loading notifications: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final t = AppLocalizations(locale);
    final isRtl = ["ar", "he"].contains(locale.languageCode);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0D0D0D),
                    Color.lerp(
                      const Color(0xFF1A140D),
                      const Color(0xFF3D2C18),
                      _controller.value,
                    )!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: child,
            );
          },
          child: _buildContent(t),
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations t) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo at the top
            Center(
              child: PremiumLogoWithIcon(
                height: 120,
                showSubtitle: true,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            // 🔔 Welcome + Notifications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.t("welcome_back"),
                  style: AppTheme.textStyleHeadline.copyWith(color: AppTheme.primaryGreen),
                ),
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications,
                          color: AppTheme.primaryGreen, size: 30),
                      if (unread > 0)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.errorRed,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unread.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: AppTheme.fontSizeTiny),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/notifications")
                        .then((_) => _loadUnreadNotifications());
                  },
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLarge),

            Text(
              t.t("choose_action"),
              style: AppTheme.textStyleSubtitle.copyWith(color: AppTheme.textSecondary),
            ),

            const SizedBox(height: 35),

            // ⭐ MAIN ACTION BUTTONS
            _menuItem(Icons.sell, t.t("sell_product"), "/sell-product"),
            const SizedBox(height: 20),

            // ✅ التعديل المهم هنا
            _menuItem(
              Icons.sync_alt,
              t.t("trade_product"),
              "/trade-products",
            ),

            const SizedBox(height: 20),
            _menuItem(
              Icons.volunteer_activism,
              t.t("donate_item"),
              "/donate-item",
            ),

            const SizedBox(height: 30),

            // ⭐ APPROVED PRODUCTS
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                    )
                  : products.isEmpty
                      ? Center(
                          child: Text(
                            "No approved products yet",
                            style: AppTheme.textStyleSubtitle.copyWith(color: AppTheme.textSecondary),
                          ),
                        )
                      : GridView.builder(
                          itemCount: products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.80,
                          ),
                          itemBuilder: (context, index) {
                            try {
                              final p = products[index];
                              
                              // ✅ Handle both images array and single image field
                              final base = AppConfig.baseUrl.endsWith('/') 
                                  ? AppConfig.baseUrl 
                                  : '${AppConfig.baseUrl}/';
                              String img = "";
                              
                              if (p["images"] != null && p["images"] is List && (p["images"] as List).isNotEmpty) {
                                final imageName = (p["images"] as List)[0].toString().trim();
                                if (imageName.isNotEmpty) {
                                  img = "${base}uploads/products/$imageName";
                                }
                              } else if (p["image"] != null && p["image"].toString().trim().isNotEmpty) {
                                final imageName = p["image"].toString().trim();
                                img = "${base}uploads/products/$imageName";
                              }

                              // ✅ Safely parse price
                              final price = double.tryParse(p["price"]?.toString() ?? "0") ?? 0.0;
                              
                              return _productCard(
                                p["title"]?.toString() ?? "",
                                price.toStringAsFixed(2),
                                img,
                              );
                            } catch (e) {
                              debugPrint("Error building product card in home: $e");
                              return Container(
                                padding: const EdgeInsets.all(16),
                                child: const Text(
                                  "Error",
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            }
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.09),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF3DDC97),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(icon, size: 32, color: Color(0xFF3DDC97)),
          ],
        ),
      ),
    );
  }

  Widget _productCard(String title, String price, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 80,
                        width: double.infinity,
                        color: Colors.white12,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: const Color(0xFF3DDC97),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      width: double.infinity,
                      color: Colors.white12,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white38, size: 40),
                    ),
                  )
                : Container(
                    height: 80,
                    width: double.infinity,
                    color: Colors.white12,
                    child: const Icon(Icons.image, color: Colors.white38),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            price.isEmpty ? "—" : "$price ₪",
            style: const TextStyle(
              color: Color(0xFF3DDC97),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
 