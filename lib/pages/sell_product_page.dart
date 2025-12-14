import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SellProductPage extends StatefulWidget {
  const SellProductPage({super.key});

  @override
  State<SellProductPage> createState() => _SellProductPageState();
}

class _SellProductPageState extends State<SellProductPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _location = TextEditingController();

  List<String> selectedImagesPaths = [];
  List<Uint8List> selectedImagesBytes = [];

  // ============================
  // ⭐ اختيار صور
  // ============================
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images == null) return;

    selectedImagesPaths.clear();
    selectedImagesBytes.clear();

    for (var img in images) {
      if (kIsWeb) {
        selectedImagesBytes.add(await img.readAsBytes());
      } else {
        selectedImagesPaths.add(img.path);
      }
    }
    setState(() {});
  }

  // ============================
  // ⭐ عرض الصور
  // ============================
  Widget _previewImages() {
    if (kIsWeb) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: selectedImagesBytes.map((img) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(img, width: 120, height: 120, fit: BoxFit.cover),
          );
        }).toList(),
      );
    } else {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: selectedImagesPaths.map((path) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(path), width: 120, height: 120, fit: BoxFit.cover),
          );
        }).toList(),
      );
    }
  }

  // ============================
  // ⭐ رفع المنتج (status = pending)
  // ============================
  Future<void> uploadProduct() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id") ?? "";

    var uri = Uri.parse("http://10.100.11.28/market_app/add_product.php");
    var request = http.MultipartRequest("POST", uri);

    request.fields['user_id'] = userId;
    request.fields['title'] = _title.text;
    request.fields['price'] = _price.text;
    request.fields['description'] = _desc.text;
    request.fields['location'] = _location.text;

    // ❗❗ النوع الصحيح = sell (مش Sell)
    request.fields['type'] = "sell";

    // حالة المنتج
    request.fields['status'] = "pending";

    // الصور
    if (kIsWeb) {
      for (int i = 0; i < selectedImagesBytes.length; i++) {
        request.files.add(
          http.MultipartFile.fromBytes(
            "images[]",
            selectedImagesBytes[i],
            filename: "image_$i.jpg",
          ),
        );
      }
    } else {
      for (var path in selectedImagesPaths) {
        request.files.add(
          await http.MultipartFile.fromPath("images[]", path),
        );
      }
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✔ تم إرسال المنتج وبانتظار موافقة الأدمن")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ حدث خطأ أثناء رفع المنتج")),
      );
    }
  }

  // ============================
  // ⭐ واجهة الصفحة
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Sell Product"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
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
                  border: Border.all(color: Colors.white24),
                ),
                child: (kIsWeb && selectedImagesBytes.isEmpty) ||
                        (!kIsWeb && selectedImagesPaths.isEmpty)
                    ? const Center(
                        child: Text(
                          "اضغط لاختيار صور المنتج",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : _previewImages(),
              ),
            ),

            const SizedBox(height: 20),
            _input("اسم المنتج", _title),
            const SizedBox(height: 12),

            _input("السعر", _price, type: TextInputType.number),
            const SizedBox(height: 12),

            _input("الوصف", _desc, maxLines: 3),
            const SizedBox(height: 12),

            _input("الموقع", _location),
            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: uploadProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text(
                "نشر المنتج (بانتظار موافقة الأدمن)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType type = TextInputType.text}) {
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
