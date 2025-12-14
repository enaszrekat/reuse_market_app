import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List<dynamic> myProducts = [];
  bool loading = true;

  // ❗❗ عدّلي IP حسب جهازك
  final String baseUrl = "http://10.100.11.28/market_app/";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _loadMyProducts();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMyProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id") ?? "";

    final response = await http.post(
      Uri.parse("${baseUrl}get_user_products.php"),
      body: {"user_id": userId},
    );

    final data = json.decode(response.body);

    if (data["status"] == "success") {
      setState(() {
        myProducts = data["products"];
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
      case "active":
        return Colors.greenAccent;
      case "pending":
        return Colors.orangeAccent;
      case "rejected":
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case "sell":
        return const Color(0xFFFFD700);
      case "exchange":
        return Colors.cyanAccent;
      case "donate":
        return Colors.pinkAccent;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "My Products",
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF050608),
                      Color(0xFF111111),
                      Color(0xFF2A1B0F),
                      Color(0xFF111111),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                )
              : myProducts.isEmpty
                  ? const Center(
                      child: Text(
                        "No products yet",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        itemCount: myProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.80,
                        ),
                        itemBuilder: (context, index) {
                          final item = myProducts[index];

                          // ⭐ جلب أول صورة فقط
                          String imageUrl = "";
                          if (item["images"] != null &&
                              item["images"].isNotEmpty) {
                            imageUrl =
                                "${baseUrl}uploads/products/${item["images"][0]}";
                          }

                          return _ProductCard(
                            title: item["title"] ?? "",
                            price: item["price"]?.toString() ?? "",
                            status: item["status"] ?? "",
                            type: item["type"] ?? "",
                            imageUrl: imageUrl,
                            statusColor: _statusColor(item["status"] ?? ""),
                            typeColor: _typeColor(item["type"] ?? ""),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------
// 🎴 بطاقة المنتج
// ------------------------------------------------------
class _ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String status;
  final String type;
  final String imageUrl;
  final Color statusColor;
  final Color typeColor;

  const _ProductCard({
    required this.title,
    required this.price,
    required this.status,
    required this.type,
    required this.imageUrl,
    required this.statusColor,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📌 الصورة
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported,
                            color: Colors.white38, size: 40),
                  )
                : Container(
                    height: 80,
                    width: double.infinity,
                    color: Colors.white12,
                    child: const Icon(Icons.image, color: Colors.white38),
                  ),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            price.isEmpty ? "—" : "$price ₪",
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  color: statusColor.withOpacity(0.9),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
