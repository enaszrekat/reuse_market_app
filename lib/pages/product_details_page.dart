import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'chat_page.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map product;

  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  static const String baseUrl = "http://10.100.11.28/market_app/";

  @override
  Widget build(BuildContext context) {
    final imageUrl = product["image"] != null && product["image"] != ""
        ? "${baseUrl}uploads/products/${product["image"]}"
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0E1412),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1412),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3DDC97)),
        title: const Text(
          "Product Details",
          style: TextStyle(
            color: Color(0xFF3DDC97),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 🖼️ Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: imageUrl == null
                        ? Container(
                            color: const Color(0xFF1C2622),
                            child: const Icon(
                              Icons.image,
                              size: 60,
                              color: Color(0xFF3DDC97),
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),

                const SizedBox(height: 26),

                // 🏷️ Title
                Text(
                  product["title"] ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                // 🔖 Type
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3DDC97).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    (product["type"] ?? "").toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF3DDC97),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 💰 Price
                if (product["price"] != null &&
                    product["price"].toString() != "0")
                  Text(
                    "${product["price"]} ₪",
                    style: const TextStyle(
                      color: Color(0xFF3DDC97),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                const SizedBox(height: 28),

                // 📝 Description Title
                const Text(
                  "Description",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 10),

                // 📝 Description Text
                Text(
                  product["description"] ?? "No description provided",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 💬 Message Button (Primary Action)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3DDC97),
                foregroundColor: Colors.black,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text(
                "Send Message",
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => _openChat(context),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 Create / Get Conversation
  Future<void> _openChat(BuildContext context) async {
    const myUserId = 11; // ⚠️ لاحقًا من SharedPreferences

    try {
      final response = await http.post(
        Uri.parse("${baseUrl}create_or_get_conversation.php"),
        body: {
          "user_id": myUserId.toString(),
          "owner_id": product["user_id"].toString(),
          "product_id": product["id"].toString(),
        },
      );

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              productId: int.parse(product["id"].toString()),
              receiverId: int.parse(product["user_id"].toString()),
              receiverName: product["user_name"] ?? "User",
              productTitle: product["title"] ?? "",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Chat error: $e");
    }
  }
}
