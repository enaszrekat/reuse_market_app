import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TradeProductPage extends StatefulWidget {
  const TradeProductPage({super.key});

  @override
  State<TradeProductPage> createState() => _TradeProductPageState();
}

class _TradeProductPageState extends State<TradeProductPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _location = TextEditingController();

  List<String> selectedImagesPaths = [];
  List<Uint8List> selectedImagesBytes = [];

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

  Widget _previewImages() {
    if (kIsWeb) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: selectedImagesBytes
            .map((img) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(img, width: 120, height: 120),
                ))
            .toList(),
      );
    } else {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: selectedImagesPaths
            .map((path) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(path),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ))
            .toList(),
      );
    }
  }

  Future<void> uploadProduct() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id") ?? "";

    // 🔥 استخدمي IP جهازك بدل localhost
    var uri = Uri.parse("http://10.100.11.28/market_app/add_product.php");

    var request = http.MultipartRequest("POST", uri);

    request.fields["user_id"] = userId;
    request.fields["title"] = _title.text;
    request.fields["description"] = _desc.text;
    request.fields["location"] = _location.text;

    // 🔥 لازم تكون Capital حرف E
    request.fields["type"] = "Exchange";

    // رفع الصور
    if (kIsWeb) {
      for (var i = 0; i < selectedImagesBytes.length; i++) {
        request.files.add(http.MultipartFile.fromBytes(
          "images[]",
          selectedImagesBytes[i],
          filename: "img_$i.jpg",
        ));
      }
    } else {
      for (var path in selectedImagesPaths) {
        request.files.add(await http.MultipartFile.fromPath("images[]", path));
      }
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✔ تم إضافة المنتج للتبديل")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ فشل في رفع المنتج")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("تبديل منتج"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImages,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: selectedImagesBytes.isEmpty &&
                        selectedImagesPaths.isEmpty
                    ? const Center(
                        child: Text(
                          "اضغط لاختيار صور",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : _previewImages(),
              ),
            ),
            const SizedBox(height: 20),
            _input("اسم المنتج", _title),
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
                "إضافة المنتج",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c,
      {int maxLines = 1}) {
    return TextField(
      controller: c,
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
