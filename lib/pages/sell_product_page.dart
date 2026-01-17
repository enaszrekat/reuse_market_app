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

class SellProductPage extends StatefulWidget {
  const SellProductPage({super.key});

  @override
  State<SellProductPage> createState() => _SellProductPageState();
}

class _SellProductPageState extends State<SellProductPage> {
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
  // اختيار الصور
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
  // رفع المنتج
  // =============================
  Future<void> uploadProduct() async {
    // ✅ Prevent multiple simultaneous requests
    if (loading) return;

    // ✅ Validate form fields
    if (_title.text.isEmpty ||
        _price.text.isEmpty ||
        _location.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    // ✅ Set loading state
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");

      if (userId == null || userId <= 0) {
        if (mounted) {
          setState(() => loading = false);
        }
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
        "type": "sell",
      });

      // الصور
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

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timeout - please try again");
        },
      );
      
      final responseCode = response.statusCode;
      final responseBody = await response.stream.bytesToString().timeout(
        const Duration(seconds: 5),
        onTimeout: () => "",
      );

      // ✅ Check if response is successful
      if (responseCode >= 200 && responseCode < 300) {
        // ✅ Try to parse JSON response
        bool isSuccess = false;
        String? errorMessage;
        
        if (responseBody.isNotEmpty && !responseBody.trim().startsWith('<')) {
          try {
            final data = json.decode(responseBody);
            if (data is Map) {
              if (data["status"] == "success") {
                isSuccess = true;
              } else if (data["status"] == "error") {
                errorMessage = data["message"]?.toString() ?? "Operation failed";
              }
            }
          } catch (e) {
            // ✅ If JSON parsing fails but HTTP is 200, assume success
            debugPrint("JSON parse warning (assuming success): $e");
            isSuccess = true;
          }
        } else {
          // ✅ Empty or HTML response but HTTP 200 - assume success
          isSuccess = true;
        }
        
        if (isSuccess) {
          // ✅ CRITICAL: Reset loading state FIRST, before any other operations
          if (mounted) {
            setState(() => loading = false);
          }
          
          // ✅ Reset form
          _title.clear();
          _price.clear();
          _desc.clear();
          _location.clear();
          imagePaths.clear();
          imageBytes.clear();
          
          // ✅ Show success message (non-blocking)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Product submitted successfully!"),
                backgroundColor: Color(0xFF3DDC97),
                duration: Duration(seconds: 2),
              ),
            );
          }
          
          // ✅ Navigate to success page after a short delay
          // Use Future.delayed to ensure UI is responsive before navigation
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ProductSentSuccessPage(),
              ),
            );
          }
        } else {
          // ✅ Backend returned error in JSON (but HTTP 200)
          // ✅ CRITICAL: Reset loading state BEFORE showing error
          if (mounted) {
            setState(() => loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage ?? "Failed to submit product"),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        // ✅ HTTP error status
        String errorMsg = "Server returned status code: $responseCode";
        
        // ✅ Try to get error message from JSON
        if (responseBody.isNotEmpty && !responseBody.trim().startsWith('<')) {
          try {
            final data = json.decode(responseBody);
            if (data is Map && data["message"] != null) {
              errorMsg = data["message"].toString();
            }
          } catch (e) {
            debugPrint("Could not parse error response: $e");
          }
        }
        
        // ✅ CRITICAL: Reset loading state BEFORE showing error
        if (mounted) {
          setState(() => loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("UPLOAD ERROR => $e");
      
      // ✅ CRITICAL: Always reset loading state on error
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit product: ${e.toString().replaceAll("Exception: ", "")}"),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // ✅ CRITICAL: Ensure loading is ALWAYS reset, even if something unexpected happens
      // This is a safety net - loading should already be false in all cases above
      // But we reset it unconditionally here to prevent UI freeze
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // =============================
  // UI (BUILD) — الحل النهائي
  // =============================
  @override
  Widget build(BuildContext context) {
    final noImages =
        (kIsWeb && imageBytes.isEmpty) ||
        (!kIsWeb && imagePaths.isEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        title: const Text(
          "Sell Product",
          style: TextStyle(color: Color(0xFF3DDC97)),
        ),
        backgroundColor: const Color(0xFF0E0E0E),
        foregroundColor: const Color(0xFF3DDC97),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// ===== المحتوى القابل للتمرير =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImages,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.white24),
                        ),
                        child: noImages
                            ? const Center(
                                child: Text(
                                  "Tap to select product images",
                                  style: TextStyle(
                                      color: Colors.white70),
                                ),
                              )
                            : _previewImages(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _input("Product Name", _title),
                    const SizedBox(height: 12),
                    _input("Price", _price,
                        type: TextInputType.number),
                    const SizedBox(height: 12),
                    _input("Description", _desc, maxLines: 3),
                    const SizedBox(height: 12),
                    _input("Location", _location),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            /// ===== زر الإرسال (ثابت + لا يختفي) =====
            Padding(
              padding: const EdgeInsets.all(20),
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
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
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
  // Widgets
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
