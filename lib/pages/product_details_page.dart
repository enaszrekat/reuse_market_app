import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'chat_page.dart';
import '../config.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map product;

  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Handle both images array and single image field
    String? imageUrl;
    final base = AppConfig.baseUrl.endsWith('/') 
        ? AppConfig.baseUrl 
        : '${AppConfig.baseUrl}/';
    
    // Try images array first
    if (product["images"] != null && product["images"] is List && (product["images"] as List).isNotEmpty) {
      final firstImage = (product["images"] as List)[0];
      if (firstImage != null && firstImage.toString().trim().isNotEmpty) {
        imageUrl = "${base}uploads/products/${firstImage.toString().trim()}";
      }
    }
    
    // Fallback to single image field
    if (imageUrl == null || imageUrl.isEmpty) {
      final imageName = product["image"];
      if (imageName != null && imageName.toString().trim().isNotEmpty) {
        imageUrl = "${base}uploads/products/${imageName.toString().trim()}";
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryGreen),
        title: const Text("Product Details", style: AppTheme.textStyleTitle),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppTheme.spacingLarge, AppTheme.spacingLarge, AppTheme.spacingLarge, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusXXLarge),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: imageUrl == null
                    ? Container(
                        color: AppTheme.surfaceSecondary,
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: AppTheme.primaryGreen,
                        ),
                      )
                    : Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
            Text(
              product["title"] ?? "",
              style: AppTheme.textStyleHeadline.copyWith(fontSize: AppTheme.fontSizeSubtitle),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            if (product["price"] != null &&
                product["price"].toString() != "0")
              Text(
                "${product["price"]} ₪",
                style: AppTheme.textStylePrice,
              ),
            const SizedBox(height: AppTheme.spacingXLarge),
            Text(
              "Description",
              style: AppTheme.textStyleBodySmall.copyWith(fontWeight: AppTheme.fontWeightSemiBold),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              product["description"]?.toString().isNotEmpty == true
                  ? product["description"]
                  : "No description provided",
              style: AppTheme.textStyleBody.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Consumer<CartService>(
                  builder: (context, cartService, child) {
                    // ✅ Safely parse all numeric fields
                    final productId = int.tryParse(product["id"]?.toString() ?? "") ?? 0;
                    final productOwnerId = int.tryParse(product["user_id"]?.toString() ?? "") ?? 0;
                    final price = double.tryParse(product["price"]?.toString() ?? "0") ?? 0.0;
                    final isInCart = cartService.isInCart(productId);
                    final base = AppConfig.baseUrl.endsWith('/') 
                        ? AppConfig.baseUrl 
                        : '${AppConfig.baseUrl}/';
                    
                    String? imgUrl;
                    if (product["images"] != null && product["images"] is List && (product["images"] as List).isNotEmpty) {
                      imgUrl = "${base}uploads/products/${(product["images"] as List)[0].toString().trim()}";
                    } else if (product["image"] != null && product["image"].toString().trim().isNotEmpty) {
                      imgUrl = "${base}uploads/products/${product["image"].toString().trim()}";
                    }
                    
                    return ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInCart
                            ? AppTheme.primaryGreen.withOpacity(0.3)
                            : AppTheme.primaryGreen,
                        foregroundColor: isInCart ? AppTheme.primaryGreen : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                          side: BorderSide(
                            color: isInCart ? AppTheme.primaryGreen : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(isInCart ? Icons.shopping_cart : Icons.add_shopping_cart),
                      label: Text(isInCart ? "In Cart" : "Add to Cart"),
                      onPressed: () async {
                        if (isInCart) {
                          Navigator.pushNamed(context, "/cart");
                          return;
                        }
                        
                        final success = await cartService.addItem(
                          productId: productId,
                          title: product["title"]?.toString() ?? "",
                          imageUrl: imgUrl ?? "",
                          price: price,
                          productOwnerId: productOwnerId,
                        );
                        
                        if (success) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Product added to cart!"),
                                backgroundColor: AppTheme.primaryGreen,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Cannot add your own product to cart"),
                                backgroundColor: AppTheme.errorRed,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  style: AppTheme.secondaryButtonStyle,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text(
                    "Message",
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => _openChat(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================
  // فتح الشات (متوافق مع PHP 100%)
  // ===============================
  Future<void> _openChat(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ استخدام getInt بدلاً من getString لأن login_page.dart يستخدم setInt
    final myId = prefs.getInt("user_id") ?? 0;
    final productId =
        int.tryParse(product["id"]?.toString() ?? "") ?? 0;
    final sellerId =
        int.tryParse(product["user_id"]?.toString() ?? "") ?? 0;

    // ✅ التحقق من تسجيل الدخول أولاً
    if (myId == 0) {
      // ✅ إذا لم يكن المستخدم مسجل دخول، الانتقال لصفحة تسجيل الدخول
      Navigator.pushNamed(context, "/login");
      return;
    }

    // ✅ التحقق من صحة بيانات المنتج
    if (productId == 0 || sellerId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incomplete data")),
      );
      return;
    }

    // ✅ منع المستخدم من إرسال رسالة لنفسه
    if (myId == sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot send message to yourself")),
      );
      return;
    }

    try {
      debugPrint("Creating conversation: buyerId=$myId, sellerId=$sellerId, productId=$productId");

      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}create_or_get_conversation.php"),
        body: {
          // ✅ استخدام نفس الأسماء المستخدمة في ChatPage
          "user1_id": myId.toString(), // المشتري (المستخدم الحالي)
          "user2_id": sellerId.toString(), // البائع
          "product_id": productId.toString(),
        },
      );

      debugPrint("API Response Status: ${res.statusCode}");
      debugPrint("API Response Body: ${res.body}");

      // ✅ التحقق من حالة الاستجابة
      if (res.statusCode != 200) {
        throw Exception("Server returned status code: ${res.statusCode}");
      }

      // ✅ معالجة JSON بشكل آمن
      Map<String, dynamic> data;
      try {
        data = json.decode(res.body) as Map<String, dynamic>;
      } catch (jsonError) {
        debugPrint("JSON Decode Error: $jsonError");
        throw Exception("Invalid response from server");
      }

      // ✅ التحقق من نجاح العملية
      if (data["status"] == "success") {
        final conversationId = data["conversation_id"];
        debugPrint("Conversation created/retrieved successfully. ID: $conversationId");

        // ✅ الانتقال لصفحة الشات مع تمرير بيانات البائع
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(
                productId: productId,
                receiverId: sellerId,
                receiverName: product["user_name"]?.toString() ?? "User",
                productTitle: product["title"]?.toString() ?? "",
              ),
            ),
          );
        }
      } else {
        // ✅ عرض رسالة الخطأ من السيرفر
        final errorMessage = data["message"]?.toString() ?? 
                           data["error"]?.toString() ?? 
                           "Failed to create conversation";
        debugPrint("API Error: $errorMessage");
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint("Error in _openChat: $e");
      
      String errorMessage = "Failed to open conversation";
      
      if (e.toString().contains("SocketException") || 
          e.toString().contains("Failed host lookup")) {
        errorMessage = "Internet connection error";
      } else if (e.toString().contains("TimeoutException")) {
        errorMessage = "Connection timeout. Please try again";
      } else if (e.toString().isNotEmpty) {
        errorMessage = "Error: ${e.toString()}";
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
