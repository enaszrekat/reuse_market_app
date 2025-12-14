import 'dart:ui';
import 'package:flutter/material.dart';

class RegisterStep1 extends StatefulWidget {
  final VoidCallback onNext;

  const RegisterStep1({super.key, required this.onNext});

  @override
  State<RegisterStep1> createState() => _RegisterStep1State();
}

class _RegisterStep1State extends State<RegisterStep1> {
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();

  String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              "Create Your Account",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Profile Image Picker
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage:
                    imagePath != null ? AssetImage(imagePath!) : null,
                child: imagePath == null
                    ? const Icon(Icons.camera_alt,
                        size: 34, color: Colors.white)
                    : null,
              ),
            ),

            const SizedBox(height: 24),

            input("Full Name", name),
            const SizedBox(height: 16),

            input("Email", email),
            const SizedBox(height: 16),

            input("Password", pass, isPass: true),

            const SizedBox(height: 28),

            // Next Button
            ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.25),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Next",
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget input(String label, TextEditingController c, {bool isPass = false}) {
    return TextField(
      controller: c,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void pickImage() {
    // Placeholder, later we add file picker
  }
}

// Glass container reusable
class GlassContainer extends StatelessWidget {
  final Widget child;
  const GlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
