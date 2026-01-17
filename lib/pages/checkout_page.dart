import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import '../config.dart';
import '../theme/app_theme.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        title: const Text("Checkout", style: AppTheme.textStyleTitle),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.primaryGreen),
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(height: AppTheme.spacingXLarge),
                  const Text(
                    "Your cart is empty",
                    style: AppTheme.textStyleSubtitle,
                  ),
                  const SizedBox(height: AppTheme.spacingXLarge),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: AppTheme.primaryButtonStyle,
                    child: const Text("Back to Cart"),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: AppTheme.paddingPage,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cart Items Section
                const Text("Order Items", style: AppTheme.textStyleTitle),
                const SizedBox(height: AppTheme.spacingLarge),
                ...cartService.items.map((item) => _CheckoutItemCard(item: item)),
                const SizedBox(height: AppTheme.spacingXLarge),
                
                // Buyer Info Form Section
                const Text("Buyer Information", style: AppTheme.textStyleTitle),
                const SizedBox(height: AppTheme.spacingLarge),
                _BuyerInfoForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  addressController: _addressController,
                  cityController: _cityController,
                  notesController: _notesController,
                ),
                const SizedBox(height: 24),
                
                // Total Section
                Container(
                  padding: AppTheme.paddingPage,
                  decoration: AppTheme.cardDecoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total:", style: AppTheme.textStyleTitle),
                      Text(
                        "${cartService.totalPrice.toStringAsFixed(2)} ₪",
                        style: AppTheme.textStylePrice.copyWith(fontSize: AppTheme.fontSizeHeadline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXLarge),
                
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleConfirmOrder(context, cartService),
                    style: AppTheme.primaryButtonStyle.copyWith(
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: AppTheme.spacingLarge)),
                    ),
                    child: const Text("Confirm Order", style: AppTheme.textStyleSubtitle),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _handlePayNow(context, cartService),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLarge),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: const Text("Pay Now", style: AppTheme.textStyleSubtitle),
                  ),
                ),
                const SizedBox(height: 40), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleConfirmOrder(BuildContext context, CartService cartService) async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields correctly"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text("Confirm Order", style: AppTheme.textStyleTitle),
        content: Text(
          "Are you sure you want to confirm this order?\n\nTotal: ${cartService.totalPrice.toStringAsFixed(2)} ₪",
          style: AppTheme.textStyleBodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppTheme.primaryButtonStyle,
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Order confirmed successfully!"),
          backgroundColor: AppTheme.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
      // Optionally clear cart and go back
      // cartService.clearCart();
      // Navigator.pop(context);
    }
  }

  Future<void> _handlePayNow(BuildContext context, CartService cartService) async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields correctly"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show payment dialog
    final paid = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text("Payment", style: AppTheme.textStyleTitle),
        content: Text(
          "Payment integration coming soon!\n\nFor now, this is a demo.\n\nTotal: ${cartService.totalPrice.toStringAsFixed(2)} ₪",
          style: AppTheme.textStyleBodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppTheme.primaryButtonStyle,
            child: const Text("Simulate Payment"),
          ),
        ],
      ),
    );

    if (paid == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Payment successful! Order placed."),
          backgroundColor: AppTheme.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
      // Optionally clear cart and go back
      // cartService.clearCart();
      // Navigator.popUntil(context, (route) => route.isFirst);
    }
  }
}

class _CheckoutItemCard extends StatelessWidget {
  final CartItem item;

  const _CheckoutItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final base = AppConfig.baseUrl.endsWith('/') 
        ? AppConfig.baseUrl 
        : '${AppConfig.baseUrl}/';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      padding: AppTheme.paddingCard,
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl.isNotEmpty
                ? Image.network(
                    item.imageUrl.startsWith('http')
                        ? item.imageUrl
                        : "${base}uploads/products/${item.imageUrl}",
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: AppTheme.surfaceSecondary,
                      child: const Icon(
                        Icons.image,
                        color: AppTheme.textTertiary,
                        size: 24,
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: AppTheme.surfaceSecondary,
                    child: const Icon(
                      Icons.image,
                      color: AppTheme.textTertiary,
                      size: 24,
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
                  "Qty: ${item.quantity} × ${item.price.toStringAsFixed(2)} ₪",
                  style: AppTheme.textStyleBodySmall,
                ),
              ],
            ),
          ),
          // Item Total
          Text(
            "${item.totalPrice.toStringAsFixed(2)} ₪",
            style: AppTheme.textStylePrice,
          ),
        ],
      ),
    );
  }
}

class _BuyerInfoForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController notesController;

  const _BuyerInfoForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.cityController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        padding: AppTheme.paddingPage,
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name *",
                hintText: "Enter your full name",
                prefixIcon: Icon(Icons.person, color: AppTheme.primaryGreen),
              ),
              style: AppTheme.textStyleBody,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Name is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Email
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email *",
                hintText: "Enter your email",
                prefixIcon: Icon(Icons.email, color: AppTheme.primaryGreen),
              ),
              style: AppTheme.textStyleBody,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Email is required";
                }
                if (!value.contains('@')) {
                  return "Please enter a valid email";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Phone Number
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number *",
                hintText: "Enter your phone number",
                prefixIcon: Icon(Icons.phone, color: AppTheme.primaryGreen),
              ),
              style: AppTheme.textStyleBody,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Phone number is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Address (multiline)
            TextFormField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Address *",
                hintText: "Enter your address",
                prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryGreen),
              ),
              style: AppTheme.textStyleBody,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Address is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // City (optional)
            TextFormField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: "City",
                hintText: "Enter your city (optional)",
                prefixIcon: Icon(Icons.location_city, color: AppTheme.primaryGreen),
              ),
              style: AppTheme.textStyleBody,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Notes (optional)
            TextFormField(
              controller: notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Notes",
                hintText: "Additional notes (optional)",
                prefixIcon: Icon(Icons.note, color: AppTheme.primaryGreen),
              ),
              style: AppTheme.textStyleBody,
            ),
          ],
        ),
      ),
    );
  }
}


