import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_details_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final String baseUrl = "http://10.100.11.28/market_app/";
  List products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final res = await http.get(Uri.parse("${baseUrl}get_products.php"));
      final data = json.decode(res.body);

      if (!mounted) return;

      setState(() {
        products =
            data["status"] == "success" ? data["products"] ?? [] : [];
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1412),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1412),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Products",
          style: TextStyle(
            color: Color(0xFF3DDC97),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: Color(0xFF3DDC97)),
            onPressed: () {},
          ),
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3DDC97)),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Text(
          "No products available",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.75, // ✅ حل الشريط الأصفر
        ),
        itemBuilder: (context, index) {
          return _productCard(context, products[index]);
        },
      ),
    );
  }

  Widget _productCard(BuildContext context, Map item) {
    final String? imageName = item["image"];
    final String? imageUrl =
        (imageName != null && imageName.isNotEmpty)
            ? "${baseUrl}uploads/products/$imageName"
            : null;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151E1B),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ IMAGE
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: 1.15,
                child: imageUrl == null
                    ? _imagePlaceholder()
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.contain, // ✅ حل عدم ظهور الصور
                        errorBuilder: (_, __, ___) =>
                            _imagePlaceholder(broken: true),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["title"]?.toString() ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3DDC97).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          (item["type"] ?? "").toString().toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF3DDC97),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      if (item["price"] != null &&
                          item["price"].toString() != "0")
                        Text(
                          "${item["price"]} ₪",
                          style: const TextStyle(
                            color: Color(0xFF3DDC97),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder({bool broken = false}) {
    return Container(
      color: const Color(0xFF1C2622),
      child: Icon(
        broken ? Icons.broken_image : Icons.image,
        color: Colors.white38,
        size: 42,
      ),
    );
  }
}
