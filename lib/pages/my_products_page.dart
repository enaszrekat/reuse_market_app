import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../theme/app_theme.dart';

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
  String? errorMessage;

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

  /// ✅ يرجع user_id سواء كان محفوظ int أو String
  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    final int? asInt = prefs.getInt("user_id");
    if (asInt != null && asInt > 0) return asInt;

    final String? asString = prefs.getString("user_id");
    final int parsed = int.tryParse(asString ?? "") ?? 0;
    return parsed;
  }

  Future<void> _loadMyProducts() async {
    try {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      final userId = await _getUserId();

      if (userId == 0) {
        if (!mounted) return;
        setState(() {
          loading = false;
          errorMessage = "Please login to view your products";
        });
        return;
      }

      final String base = AppConfig.baseUrl.endsWith('/')
          ? AppConfig.baseUrl
          : '${AppConfig.baseUrl}/';

      final uri = Uri.parse("${base}get_user_products.php");

      final response = await http
          .post(
            uri,
            headers: {
              "Accept": "application/json",
            },
            body: {"user_id": userId.toString()},
          )
          .timeout(
            const Duration(seconds: 12),
            onTimeout: () => throw Exception("Request timeout"),
          );

      if (response.statusCode != 200) {
        throw Exception("Server returned status ${response.statusCode}");
      }

      final body = response.body.trim();
      if (body.isEmpty) {
        throw Exception("Empty response from server");
      }

      // إذا رجع HTML يعني PHP طبع خطأ / Warning / Fatal
      if (body.contains('<!DOCTYPE') || body.contains('<html') || body.contains('<br')) {
        debugPrint("❌ Backend returned HTML/text:\n$body");
        throw Exception("Backend error (PHP output). Check get_user_products.php");
      }

      final dynamic decoded = json.decode(body);
      if (decoded is! Map) {
        throw Exception("Invalid JSON format");
      }

      final data = decoded as Map<String, dynamic>;

      if (!mounted) return;

      if (data["status"] == "success") {
        final list = (data["products"] is List) ? data["products"] as List : [];

        setState(() {
          myProducts = list;
          loading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          loading = false;
          errorMessage = data["message"]?.toString() ?? "Failed to load products";
          myProducts = [];
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading my products: $e");
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = e.toString().replaceFirst("Exception: ", "");
        myProducts = [];
      });
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

  Future<void> _deleteProduct(int productId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          "Delete Product",
          style: AppTheme.textStyleTitle,
        ),
        content: Text(
          "Are you sure you want to delete this product? This action cannot be undone.",
          style: AppTheme.textStyleBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final userId = await _getUserId();
      if (userId == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please login to delete products"),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }

      final String base = AppConfig.baseUrl.endsWith('/')
          ? AppConfig.baseUrl
          : '${AppConfig.baseUrl}/';

      final uri = Uri.parse("${base}delete_product.php");

      final response = await http
          .post(
            uri,
            headers: {
              "Accept": "application/json",
            },
            body: {
              "product_id": productId.toString(),
              "user_id": userId.toString(),
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception("Request timeout"),
          );

      if (!mounted) return;

      if (response.statusCode != 200) {
        throw Exception("Server returned status ${response.statusCode}");
      }

      final body = response.body.trim();
      if (body.isEmpty) {
        throw Exception("Empty response from server");
      }

      if (body.contains('<!DOCTYPE') || body.contains('<html')) {
        throw Exception("Server returned HTML error");
      }

      final dynamic decoded = json.decode(body);
      if (decoded is! Map) {
        throw Exception("Invalid JSON format");
      }

      final data = decoded as Map<String, dynamic>;

      if (data["status"] == "success") {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"]?.toString() ?? "Product deleted successfully"),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );

        // Refresh the products list
        _loadMyProducts();
      } else {
        throw Exception(data["message"]?.toString() ?? "Failed to delete product");
      }
    } catch (e) {
      debugPrint("❌ Error deleting product: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString().replaceFirst("Exception: ", "")}"),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String base = AppConfig.baseUrl.endsWith('/')
        ? AppConfig.baseUrl
        : '${AppConfig.baseUrl}/';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        title: const Text("My Products", style: AppTheme.textStyleTitle),
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

          if (loading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: AppTheme.paddingPage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        color: AppTheme.errorRed,
                        size: AppTheme.iconSizeXLarge),
                    const SizedBox(height: AppTheme.spacingLarge),
                    Text(
                      errorMessage!,
                      style: AppTheme.textStyleBodySecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),
                    ElevatedButton(
                      onPressed: _loadMyProducts,
                      style: AppTheme.primaryButtonStyle,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            )
          else if (myProducts.isEmpty)
            Center(
              child: Text(
                "No products yet",
                style: AppTheme.textStyleSubtitle.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            )
          else
            Padding(
              padding: AppTheme.paddingPage,
              child: GridView.builder(
                itemCount: myProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppTheme.spacingMedium,
                  mainAxisSpacing: AppTheme.spacingMedium,
                  childAspectRatio: 0.80,
                ),
                itemBuilder: (context, index) {
                  final item = myProducts[index] as Map;

                  // ✅ صورة أولى من images
                  String imageUrl = "";
                  final images = item["images"];

                  if (images is List && images.isNotEmpty) {
                    final name = images.first.toString().trim();
                    if (name.isNotEmpty) {
                      imageUrl = "${base}uploads/products/$name";
                    }
                  } else if (item["image"] != null) {
                    final name = item["image"].toString().trim();
                    if (name.isNotEmpty) {
                      imageUrl = "${base}uploads/products/$name";
                    }
                  }

                  final price = double.tryParse(item["price"]?.toString() ?? "0") ?? 0;

                  final status = item["status"]?.toString() ?? "";
                  final type = item["type"]?.toString() ?? "";

                  return _ProductCard(
                    productId: int.tryParse(item["id"]?.toString() ?? "0") ?? 0,
                    title: item["title"]?.toString() ?? "",
                    price: price.toStringAsFixed(2),
                    status: status,
                    type: type,
                    imageUrl: imageUrl,
                    statusColor: _statusColor(status),
                    typeColor: _typeColor(type),
                    onDelete: () => _deleteProduct(int.tryParse(item["id"]?.toString() ?? "0") ?? 0),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final int productId;
  final String title;
  final String price;
  final String status;
  final String type;
  final String imageUrl;
  final Color statusColor;
  final Color typeColor;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.productId,
    required this.title,
    required this.price,
    required this.status,
    required this.type,
    required this.imageUrl,
    required this.statusColor,
    required this.typeColor,
    required this.onDelete,
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 80,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 80,
                          width: double.infinity,
                          color: AppTheme.surfaceSecondary,
                          child: const Icon(Icons.image_not_supported,
                              color: AppTheme.textTertiary, size: 40),
                        ),
                      )
                    : Container(
                        height: 80,
                        width: double.infinity,
                        color: AppTheme.surfaceSecondary,
                        child: const Icon(Icons.image,
                            color: AppTheme.textTertiary),
                      ),
              ),
              // Delete button (trash icon) in top-right corner
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.textStyleBodySmall
                .copyWith(fontWeight: AppTheme.fontWeightBold),
          ),

          const SizedBox(height: AppTheme.spacingTiny),

          Text(
            "$price ₪",
            style: AppTheme.textStylePrice
                .copyWith(fontSize: AppTheme.fontSizeBodySmall),
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
              const SizedBox(width: 10),
              Text(
                type,
                style: TextStyle(
                  color: typeColor.withOpacity(0.9),
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
