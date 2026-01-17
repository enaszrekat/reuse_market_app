import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'product_sent_success_page.dart';
import '../config.dart';
import '../theme/app_theme.dart';

class TradeProductPage extends StatefulWidget {
  const TradeProductPage({super.key});

  @override
  State<TradeProductPage> createState() => _TradeProductPageState();
}

class _TradeProductPageState extends State<TradeProductPage> {
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();

  List<String> imagePaths = [];
  List<Uint8List> imageBytes = [];

  bool loading = false;

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _desc.dispose();
    _location.dispose();
    super.dispose();
  }

  // =============================
  // Pick Images (EXACT SAME as SELL)
  // =============================
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isEmpty) return;

    imagePaths.clear();
    imageBytes.clear();

    for (var img in images) {
      if (kIsWeb) {
        imageBytes.add(await img.readAsBytes());
      } else {
        imagePaths.add(img.path);
      }
    }

    setState(() {});
  }

  // =============================
  // Upload Product (EXACT SAME as SELL, only type differs)
  // =============================
  Future<void> uploadProduct() async {
    if (loading) return;

    if (_title.text.isEmpty ||
        _price.text.isEmpty ||
        _location.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");

      if (userId == null || userId <= 0) {
        throw Exception("User not logged in");
      }

      final base = AppConfig.baseUrl.endsWith('/') 
          ? AppConfig.baseUrl 
          : '${AppConfig.baseUrl}/';
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("${base}add_product.php"),
      );

      request.fields.addAll({
        "user_id": userId.toString(),
        "title": _title.text.trim(),
        "price": _price.text.trim(),
        "description": _desc.text.trim(),
        "location": _location.text.trim(),
        "type": "exchange", // ✅ Only difference: type is "exchange"
      });

      // Images (EXACT SAME as SELL)
      if (kIsWeb) {
        for (int i = 0; i < imageBytes.length; i++) {
          request.files.add(
            http.MultipartFile.fromBytes(
              "images[]",
              imageBytes[i],
              filename: "image_$i.jpg",
            ),
          );
        }
      } else {
        for (var path in imagePaths) {
          request.files.add(
            await http.MultipartFile.fromPath("images[]", path),
          );
        }
      }

      final response = await request.send();
      final responseCode = response.statusCode;
      final responseBody = await response.stream.bytesToString();

      // ✅ Same validation and success handling as SELL
      if (responseCode >= 200 && responseCode < 300) {
        // ✅ Reset form before navigation
        _title.clear();
        _price.clear();
        _desc.clear();
        _location.clear();
        imagePaths.clear();
        imageBytes.clear();
        
        // ✅ Show success message
        if (mounted) {
          setState(() => loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Product submitted successfully!"),
              backgroundColor: AppTheme.primaryGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        // ✅ Navigate to success page after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductSentSuccessPage(),
            ),
          );
        }
      } else {
        throw Exception("Server returned status code: $responseCode. Response: $responseBody");
      }
    } catch (e) {
      debugPrint("UPLOAD ERROR => $e");
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit product: ${e.toString()}"),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // ✅ Ensure loading is always reset, even if navigation happens or early return
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // =============================
  // UI (BUILD) - EXACT SAME as SELL
  // =============================
  @override
  Widget build(BuildContext context) {
    final noImages =
        (kIsWeb && imageBytes.isEmpty) ||
        (!kIsWeb && imagePaths.isEmpty);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text(
          "Trade Product",
          style: AppTheme.textStyleTitle,
        ),
        backgroundColor: AppTheme.backgroundDark,
        foregroundColor: AppTheme.primaryGreen,
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// ===== Scrollable Content =====
            Expanded(
              child: SingleChildScrollView(
                padding: AppTheme.paddingPage,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImages,
                      child: Container(
                        width: double.infinity,
                        padding: AppTheme.paddingCard,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSecondary,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                        ),
                        child: noImages
                            ? const Center(
                                child: Text(
                                  "Click to add images",
                                  style: AppTheme.textStyleBodySecondary,
                                ),
                              )
                            : _previewImages(),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),
                    _input("Product Name", _title),
                    const SizedBox(height: AppTheme.spacingMedium),
                    _input("Price", _price,
                        type: TextInputType.number),
                    const SizedBox(height: AppTheme.spacingMedium),
                    _input("Description", _desc, maxLines: 3),
                    const SizedBox(height: AppTheme.spacingMedium),
                    _input("Location", _location),
                    const SizedBox(height: AppTheme.spacingLarge),
                  ],
                ),
              ),
            ),

            /// ===== Submit Button (Fixed, doesn't scroll) =====
            Padding(
              padding: AppTheme.paddingPage,
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : uploadProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.amber.withOpacity(0.6),
                    disabledForegroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                        )
                      : const Text(
                          "Publish Product (Pending Admin Approval)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // Widgets (EXACT SAME as SELL)
  // =============================
  Widget _previewImages() {
    final images = kIsWeb ? imageBytes : imagePaths;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: images.map((img) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: kIsWeb
              ? Image.memory(
                  img as Uint8List,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(img as String),
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
        );
      }).toList(),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      style: AppTheme.textStyleBody,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.textStyleBodySecondary,
        filled: true,
        fillColor: AppTheme.surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
        ),
      ),
    );
  }
}
