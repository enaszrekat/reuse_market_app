import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import '../config.dart';
import '../theme/app_theme.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        title: const Text("Shopping Cart", style: AppTheme.textStyleTitle),
        centerTitle: true,
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: AppTheme.iconSizeXLarge * 1.67,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: AppTheme.spacingXLarge),
                  Text(
                    "Your cart is empty",
                    style: AppTheme.textStyleSubtitle.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  Text(
                    "Add products to get started",
                    style: AppTheme.textStyleBodySmall,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: AppTheme.paddingPage,
                  itemCount: cartService.items.length,
                  itemBuilder: (context, index) {
                    final item = cartService.items[index];
                    return _CartItemCard(item: item);
                  },
                ),
              ),
              _CartTotal(cartService: cartService),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final base = AppConfig.baseUrl.endsWith('/') 
        ? AppConfig.baseUrl 
        : '${AppConfig.baseUrl}/';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: AppTheme.paddingCard,
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl.startsWith('http')
                          ? item.imageUrl
                          : "${base}uploads/products/${item.imageUrl}",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: AppTheme.surfaceSecondary,
                        child: const Icon(
                          Icons.image,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: AppTheme.surfaceSecondary,
                      child: const Icon(
                        Icons.image,
                        color: AppTheme.textTertiary,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTheme.textStyleBody.copyWith(fontWeight: AppTheme.fontWeightSemiBold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingTiny),
                  Text(
                    "${item.price} ₪",
                    style: AppTheme.textStylePrice,
                  ),
                  const SizedBox(height: 8),
                  // Quantity Controls
                  Row(
                    children: [
                      // Decrease Button
                      InkWell(
                        onTap: () {
                          cartService.updateQuantity(
                            item.productId,
                            item.quantity - 1,
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            border: Border.all(
                              color: AppTheme.primaryGreen,
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.remove,
                            color: AppTheme.primaryGreen,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      // Quantity Display
                      Text(
                        "${item.quantity}",
                        style: AppTheme.textStyleBody.copyWith(fontWeight: AppTheme.fontWeightSemiBold),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      // Increase Button
                      InkWell(
                        onTap: () {
                          cartService.updateQuantity(
                            item.productId,
                            item.quantity + 1,
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Remove Button
                      InkWell(
                        onTap: () {
                          cartService.removeItem(item.productId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Item removed from cart"),
                              backgroundColor: Color(0xFF3DDC97),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppTheme.errorRed,
                            size: 20,
                          ),
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
}

class _CartTotal extends StatelessWidget {
  final CartService cartService;

  const _CartTotal({required this.cartService});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXLarge),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total:", style: AppTheme.textStyleTitle),
                Text(
                  "${cartService.totalPrice.toStringAsFixed(2)} ₪",
                  style: AppTheme.textStylePrice.copyWith(fontSize: AppTheme.fontSizeHeadline),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CheckoutPage(),
                    ),
                  );
                },
                style: AppTheme.primaryButtonStyle.copyWith(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: AppTheme.spacingLarge)),
                ),
                child: const Text("Checkout", style: AppTheme.textStyleSubtitle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

