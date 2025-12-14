import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class AdminDashboardPage extends StatefulWidget {
  final Function(Locale) onLangChange;

  const AdminDashboardPage({super.key, required this.onLangChange});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int selectedTab = 1;
  bool loading = false;
  List<Product> pendingProducts = [];

  static const String baseUrl = "http://10.100.11.28/market_app/";

  @override
  void initState() {
    super.initState();
    _loadPendingProducts();
  }

  Future<void> _loadPendingProducts() async {
    setState(() => loading = true);

    try {
      final response = await http.get(
        Uri.parse("${baseUrl}admin_get_pending_products.php"),
      );

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        List list = data["products"] ?? [];

        pendingProducts = list
            .map((json) => Product.fromJson(json))
            .toList()
            .cast<Product>();
      }
    } catch (e) {
      debugPrint("LOAD ERROR: $e");
    }

    setState(() => loading = false);
  }

  Future<void> _updateProductStatus(int productId, String status) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}update_product_status.php"),
        body: {
          "id": productId.toString(),
          "status": status,
        },
      );

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        _loadPendingProducts();
      } else {
        _showErrorSnack(data["message"] ?? "Error");
      }
    } catch (e) {
      _showErrorSnack("Network error");
    }
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final t = AppLocalizations(locale);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          _buildSidebar(t),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildTabContent(t, locale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(AppLocalizations t) {
    return Container(
      width: 230,
      height: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings,
                  color: Colors.green, size: 32),
              const SizedBox(width: 10),
              Text(
                t.t("admin_panel"),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          _buildSideButton(Icons.people, t.t("users"), 0),
          const SizedBox(height: 10),
          _buildSideButton(Icons.inventory_2, t.t("products"), 1),
          const SizedBox(height: 10),
          _buildSideButton(Icons.bar_chart, t.t("reports"), 2),

          const Spacer(),

          Text(
            t.t("language"),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _langChip("ع", const Locale("ar")),
              const SizedBox(width: 6),
              _langChip("En", const Locale("en")),
              const SizedBox(width: 6),
              _langChip("ע", const Locale("he")),
            ],
          ),

          const SizedBox(height: 20),

          TextButton.icon(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, "/admin-login"),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: Text(
              t.t("logout"),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton(IconData icon, String label, int index) {
    final active = selectedTab == index;

    return InkWell(
      onTap: () {
        setState(() => selectedTab = index);
        if (index == 1) _loadPendingProducts();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: active ? Colors.green.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.green : Colors.grey[700]),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? Colors.green : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _langChip(String label, Locale locale) {
    final current = Localizations.localeOf(context);
    final active = current.languageCode == locale.languageCode;

    return GestureDetector(
      onTap: () => widget.onLangChange(locale),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: active ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(AppLocalizations t, Locale locale) {
    if (selectedTab == 0) {
      return Center(
        child: Text(
          t.t("users_placeholder"),
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    if (selectedTab == 2) {
      return Center(
        child: Text(
          t.t("reports_placeholder"),
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    if (loading) return const Center(child: CircularProgressIndicator());

    if (pendingProducts.isEmpty) {
      return Center(
        child: Text(
          t.t("no_pending_products"),
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return _buildPendingProductsList(t);
  }

  Widget _buildPendingProductsList(AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.t("pending_products"),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: ListView.separated(
            itemCount: pendingProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final p = pendingProducts[i];

              // 🎯 التعديل المهم هنا
              final imageUrl = p.images.isNotEmpty
                  ? "${baseUrl}uploads/products/${p.images.first}"
                  : null;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported),
                            ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.title,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("${t.t("owner")}: ${p.userName}",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey)),
                          Text(
                            "${t.t("type")}: ${p.typeText(t)}   •   ${t.t("price")}: ${p.price}",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              _updateProductStatus(p.id, "approved"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(90, 32),
                          ),
                          child: Text(t.t("approve")),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          onPressed: () =>
                              _updateProductStatus(p.id, "rejected"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            minimumSize: const Size(90, 32),
                          ),
                          child: Text(t.t("reject")),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

//
// 🔥 Product Model — يدعم الصور المتعددة
//

class Product {
  final int id;
  final String title;
  final String userName;
  final String type;
  final String price;
  final String status;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.userName,
    required this.type,
    required this.price,
    required this.status,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> imgs = [];

    if (json["images"] != null) {
      imgs = (json["images"] as List)
          .map((e) => e.toString())
          .toList();
    }

    return Product(
      id: int.tryParse(json["id"].toString()) ?? 0,
      title: json["title"] ?? "",
      userName: json["user_name"] ?? "",
      type: json["type"] ?? "",
      price: json["price"]?.toString() ?? "0",
      status: json["status"] ?? "",
      images: imgs,
    );
  }

  String typeText(AppLocalizations t) {
    if (type.toLowerCase() == "exchange") return t.t("exchange");
    if (type.toLowerCase() == "donate") return t.t("donate");
    return t.t("sell");
  }
}
