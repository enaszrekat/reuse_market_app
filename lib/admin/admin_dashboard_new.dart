import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ❌ انحذف
// import '../main.dart';

// ✅ أُضيف
import '../localization/app_localizations.dart';

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

    // ❌ كان: AppLocalizations(locale)
    // ✅ صار:
    final t = AppLocalizations.of(context);

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

  Widget _buildTabContent(AppLocalizations t, Locale locale) {
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

              final imageUrl = p.images.isNotEmpty
                  ? "${baseUrl}uploads/products/${p.images.first}"
                  : null;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    imageUrl != null
                        ? Image.network(imageUrl,
                            width: 70, height: 70, fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(p.title),
                    ),

                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              _updateProductStatus(p.id, "approved"),
                          child: Text(t.t("approve")),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          onPressed: () =>
                              _updateProductStatus(p.id, "rejected"),
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

class Product {
  final int id;
  final String title;
  final String price;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json["id"].toString()) ?? 0,
      title: json["title"] ?? "",
      price: json["price"]?.toString() ?? "0",
      images: (json["images"] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
