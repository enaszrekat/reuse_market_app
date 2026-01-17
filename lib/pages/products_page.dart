import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';
import '../components/premium_logo.dart';
import 'product_details_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List products = [];
  bool loading = true;
  String? errorMessage;
  int unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadUnreadNotificationsCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh notification count when page becomes visible
    _loadUnreadNotificationsCount();
  }

  Future<void> _loadUnreadNotificationsCount() async {
    final count = await _getUnreadNotificationsCount();
    if (mounted) {
      setState(() {
        unreadNotificationsCount = count;
      });
    }
  }

  Future<int> _getUnreadNotificationsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id") ?? 0;
      if (userId == 0) return 0;

      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}get_unread_notifications.php?user_id=$userId"),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response("", 408),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = json.decode(response.body);
        if (data["status"] == "success") {
          return data["unread"] ?? 0;
        }
      }
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    }
    return 0;
  }

  Future<void> _loadProducts() async {
    try {
      final url = Uri.parse(
        AppConfig.baseUrl.endsWith('/')
            ? '${AppConfig.baseUrl}get_products.php'
            : '${AppConfig.baseUrl}/get_products.php',
      );

      final res = await http.get(url);

      if (res.statusCode != 200) {
        throw Exception("Server returned ${res.statusCode}");
      }

      // ✅ Validate response is not empty and not HTML
      if (res.body.isEmpty || res.body.trim().isEmpty) {
        throw Exception("Empty response from server");
      }

      // ✅ Check for HTML errors (like <br /> tags)
      if (res.body.trim().startsWith('<') || 
          res.body.contains('<!DOCTYPE') || 
          res.body.contains('<html') ||
          res.body.contains('<br')) {
        throw Exception("Server returned HTML error instead of JSON. Check backend PHP files.");
      }

      final data = json.decode(res.body);

      if (!mounted) return;

      if (data['status'] == 'success') {
        setState(() {
          products = data['products'] ?? [];
          loading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          loading = false;
          errorMessage = data['message'] ?? 'Failed to load products';
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: PremiumLogo(
          height: 35,
          showSubtitle: false,
          compact: true,
        ),
        actions: [
          // Notification Bell Icon
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: AppTheme.primaryGreen),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notifications');
                  // Refresh notification count after returning from notifications page
                  _loadUnreadNotificationsCount();
                },
                tooltip: "Notifications",
              ),
              if (unreadNotificationsCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: AppTheme.errorRed,
                    child: Text(
                      unreadNotificationsCount > 99 ? "99+" : unreadNotificationsCount.toString(),
                      style: const TextStyle(fontSize: AppTheme.fontSizeTiny, color: Colors.white),
                    ),
                  ),
                )
            ],
          ),
          // Shopping Cart Icon
          Consumer<CartService>(
            builder: (_, cart, __) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: AppTheme.primaryGreen),
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                  tooltip: "Shopping Cart",
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: AppTheme.errorRed,
                      child: Text(
                        cart.itemCount.toString(),
                        style: const TextStyle(fontSize: AppTheme.fontSizeTiny, color: Colors.white),
                      ),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: AppTheme.errorRed, size: AppTheme.iconSizeXLarge),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(errorMessage!, style: AppTheme.textStyleBodySecondary),
            const SizedBox(height: AppTheme.spacingLarge),
            ElevatedButton(
              onPressed: _loadProducts,
              style: AppTheme.primaryButtonStyle,
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Text("No products", style: AppTheme.textStyleBodySecondary),
      );
    }

    return GridView.builder(
      padding: AppTheme.paddingPage,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        crossAxisSpacing: AppTheme.spacingLarge,
        mainAxisSpacing: AppTheme.spacingLarge,
        childAspectRatio: 0.65,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _productCard(products[i]),
    );
  }

  Widget _productCard(Map item) {
    final base = AppConfig.baseUrl.endsWith('/')
        ? AppConfig.baseUrl
        : '${AppConfig.baseUrl}/';

    String imageUrl = '';

    if (item['images'] is List && item['images'].isNotEmpty) {
      imageUrl = '${base}uploads/products/${item['images'][0]}';
    } else if (item['image'] != null) {
      imageUrl = '${base}uploads/products/${item['image']}';
    }

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsPage(product: item),
        ),
      ),
      child: Container(
        decoration: AppTheme.productCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: AppTheme.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.textStyleBodySmall.copyWith(
                      fontWeight: AppTheme.fontWeightSemiBold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  // Row 1: Type badge and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Type badge (SELL)
                      if (item['type'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSmall,
                            vertical: AppTheme.spacingTiny,
                          ),
                          decoration: AppTheme.badgeDecoration,
                          child: Text(
                            (item['type'] ?? '').toString().toUpperCase(),
                            style: AppTheme.textStyleBadge,
                          ),
                        ),
                      // Price (if available)
                      if (item['price'] != null)
                        Builder(
                          builder: (context) {
                            final price = double.tryParse(item['price'].toString()) ?? 0.0;
                            if (price > 0) {
                              return Text(
                                "${price.toStringAsFixed(2)} ₪",
                                style: AppTheme.textStylePrice.copyWith(fontSize: AppTheme.fontSizeBodySmall),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                    ],
                  ),
                  // Row 2: Seller info
                  const SizedBox(height: AppTheme.spacingTiny),
                  Builder(
                    builder: (context) {
                      // Try to get seller name first
                      String sellerInfo = '';
                      if (item['owner_name'] != null && item['owner_name'].toString().trim().isNotEmpty) {
                        sellerInfo = 'by ${item['owner_name']}';
                      } else if (item['owner_username'] != null && item['owner_username'].toString().trim().isNotEmpty) {
                        sellerInfo = 'by ${item['owner_username']}';
                      } else if (item['user_id'] != null) {
                        // Fallback to user ID
                        final userId = int.tryParse(item['user_id'].toString()) ?? 0;
                        if (userId > 0) {
                          sellerInfo = 'by User #$userId';
                        }
                      }
                      
                      if (sellerInfo.isNotEmpty) {
                        return Text(
                          sellerInfo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.textStyleCaption,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  // Add to Cart Button
                  Consumer<CartService>(
                    builder: (context, cartService, child) {
                      // ✅ Safely parse all numeric fields
                      final productId = int.tryParse(item["id"]?.toString() ?? "") ?? 0;
                      final productOwnerId = int.tryParse(item["user_id"]?.toString() ?? "") ?? 0;
                      final price = double.tryParse(item['price']?.toString() ?? "0") ?? 0.0;
                      final isInCart = cartService.isInCart(productId);
                      
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (isInCart) {
                              // Navigate to cart if already in cart
                              Navigator.pushNamed(context, "/cart");
                              return;
                            }

                            final success = await cartService.addItem(
                              productId: productId,
                              title: item["title"]?.toString() ?? "",
                              imageUrl: imageUrl,
                              price: price,
                              productOwnerId: productOwnerId,
                            );

                            if (success) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Product added to cart!"),
                                    backgroundColor: Color(0xFF3DDC97),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Cannot add your own product to cart"),
                                    backgroundColor: Colors.redAccent,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInCart
                                ? AppTheme.primaryGreen.withOpacity(0.3)
                                : AppTheme.primaryGreen,
                            foregroundColor: isInCart ? AppTheme.primaryGreen : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              side: BorderSide(
                                color: isInCart ? AppTheme.primaryGreen : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            minimumSize: const Size(0, 32),
                          ),
                          icon: Icon(
                            isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                            size: AppTheme.iconSizeSmall,
                          ),
                          label: Text(
                            isInCart ? "In Cart" : "Add to Cart",
                            style: AppTheme.textStyleCaption.copyWith(
                              fontWeight: AppTheme.fontWeightSemiBold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 100,
      color: AppTheme.surfaceSecondary,
      child: const Icon(Icons.image, color: AppTheme.textTertiary),
    );
  }
}
