import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

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

  final String baseUrl = "http://10.100.11.28/market_app/";

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
      final response =
          await http.get(Uri.parse("${baseUrl}get_approved_products.php"));

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        setState(() {
          products = data["products"];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _loadUnreadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id") ?? "0";

    try {
      final response = await http.get(
        Uri.parse("${baseUrl}get_unread_notifications.php?user_id=$userId"),
      );

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        setState(() {
          unread = data["unread"];
        });
      }
    } catch (e) {}
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
            // 🔔 Welcome + Notifications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.t("welcome_back"),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade200,
                  ),
                ),
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications,
                          color: Colors.amber, size: 30),
                      if (unread > 0)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unread.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
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

            const SizedBox(height: 10),

            Text(
              t.t("choose_action"),
              style: TextStyle(
                fontSize: 17,
                color: Colors.white.withOpacity(0.8),
              ),
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
                      child:
                          CircularProgressIndicator(color: Colors.amber),
                    )
                  : products.isEmpty
                      ? const Center(
                          child: Text(
                            "No approved products yet",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 18),
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
                            final p = products[index];
                            final img =
                                "${baseUrl}uploads/products/${p["image"]}";

                            return _productCard(
                              p["title"],
                              p["price"] ?? "",
                              img,
                            );
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
              style: TextStyle(
                fontSize: 20,
                color: Colors.amber.shade200,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(icon, size: 32, color: Colors.amber.shade300),
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
            child: Image.network(
              imageUrl,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
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
            "$price ₪",
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
 