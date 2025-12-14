import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List pendingProducts = [];
  bool loading = true;

  // ⭐ IP تبع جهازك
  final String baseUrl = "http://10.100.11.28/market_app/";

  @override
  void initState() {
    super.initState();
    loadPendingProducts();
  }

  // ⭐ جلب المنتجات المعلقة
  Future<void> loadPendingProducts() async {
    try {
      final response =
          await http.get(Uri.parse("${baseUrl}get_pending_products.php"));

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        setState(() {
          pendingProducts = data["products"];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("ERROR: $e");
      setState(() => loading = false);
    }
  }

  // ⭐ قبول المنتج
  Future<void> approveProduct(int id) async {
    await http.post(
      Uri.parse("${baseUrl}admin_approve_product.php"),
      body: {"id": id.toString()},
    );
    loadPendingProducts();
  }

  // ⭐ رفض المنتج
  Future<void> rejectProduct(int id) async {
    await http.post(
      Uri.parse("${baseUrl}admin_reject_product.php"),
      body: {"id": id.toString()},
    );
    loadPendingProducts();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final bool isRtl = ["ar", "he"].contains(locale.languageCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -----------------------------
          // ✨ 1) STATS CARDS
          // -----------------------------
          Row(
            children: [
              statCard("Total Users", "1,204", Icons.people),
              const SizedBox(width: 20),
              statCard("Active Today", "178", Icons.bolt),
              const SizedBox(width: 20),
              statCard("Products", "342", Icons.inventory),
              const SizedBox(width: 20),
              statCard("Pending Reports", "12",
                  Icons.warning_amber_rounded),
            ],
          ),

          const SizedBox(height: 40),

          // -----------------------------
          // ✨ 2) CHART
          // -----------------------------
          chartCard(),

          const SizedBox(height: 40),

          // -----------------------------
          // ✨ 3) Quick Actions
          // -----------------------------
          Text(
            "Quick Actions",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD684),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              quickAction("Add Product", Icons.add_box),
              const SizedBox(width: 16),
              quickAction("Manage Users", Icons.manage_accounts),
              const SizedBox(width: 16),
              quickAction("View Reports", Icons.bar_chart),
            ],
          ),

          const SizedBox(height: 40),

          // -----------------------------
          // ✨ 4) Recent Activity
          // -----------------------------
          Text(
            "Recent Activity",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD684),
            ),
          ),
          const SizedBox(height: 20),

          activity("New user registered", "2 minutes ago",
              const Color(0xFFFFD684), isRtl),
          activity("Product approved", "15 minutes ago",
              Colors.orangeAccent, isRtl),
          activity("Sara uploaded a new item", "1 hour ago",
              const Color(0xFFE4CBAF), isRtl),

          const SizedBox(height: 50),

          // -----------------------------
          // ⭐ 5) Pending Products Section
          // -----------------------------
          Text(
            "Pending Products",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD684),
            ),
          ),
          const SizedBox(height: 20),

          loading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: Colors.amber))
              : pendingProducts.isEmpty
                  ? const Text(
                      "No pending products.",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    )
                  : Column(
                      children: pendingProducts.map((p) {
                        final images = p["images"] as List;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: images.isNotEmpty
                                    ? Image.network(
                                        "${baseUrl}${images[0]}",
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image,
                                        size: 60, color: Colors.white60),
                              ),
                              const SizedBox(width: 15),

                              // ----- TEXT -----
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p["title"],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "By: ${p["user_name"]}",
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.green, size: 30),
                                    onPressed: () =>
                                        approveProduct(p["id"]),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red, size: 30),
                                    onPressed: () =>
                                        rejectProduct(p["id"]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // UI WIDGETS (بدون تعديل منك)
  // ------------------------------------------------------------

  Widget statCard(String title, String value, IconData icon) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 34, color: const Color(0xFFFFD684)),
                const SizedBox(height: 14),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget chartCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Activity Chart",
                style: TextStyle(
                    color: Color(0xFFFFD684),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    bar(40),
                    bar(70),
                    bar(50),
                    bar(110),
                    bar(80),
                    bar(60),
                    bar(95),
                    bar(120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bar(double h) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        height: h,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD684),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget quickAction(String text, IconData icon) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFFD684), size: 26),
                const SizedBox(width: 12),
                Text(text,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget activity(
      String title, String time, Color color, bool isRtl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16)),
                const SizedBox(height: 4),
                Text(time,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
