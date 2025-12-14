import 'dart:ui';
import 'package:flutter/material.dart';

class RegisterStep2 extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const RegisterStep2({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<RegisterStep2> createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  final country = TextEditingController();
  final city = TextEditingController();
  final street = TextEditingController();
  final house = TextEditingController();

  String? pickupPoint;

  final List<String> pickupPointsIsrael = [
    "Tel Aviv – מרכז העיר",
    "Jerusalem – محطة القطار",
    "Haifa – مجمع غرנד كانيون",
    "Nazareth – محطة الرئيسية",
    "Jaffa – ميناء يافا",
    "Eilat – مركز التسوق",
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              "Address Information",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            input("Country", country),
            const SizedBox(height: 16),

            input("City", city),
            const SizedBox(height: 16),

            input("Street / Neighborhood", street),
            const SizedBox(height: 16),

            input("House Number", house),
            const SizedBox(height: 24),

            // Pickup Point Dropdown
            Text(
              "Pick-up Point",
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: Colors.black.withOpacity(0.7),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  value: pickupPoint,
                  hint: Text(
                    "Choose your nearest point",
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  items: pickupPointsIsrael.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => pickupPoint = value);
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back
                ElevatedButton(
                  onPressed: widget.onBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Back", style: TextStyle(fontSize: 16)),
                ),

                // Next
                ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.25),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Next", style: TextStyle(fontSize: 16)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget input(String label, TextEditingController c) {
    return TextField(
      controller: c,
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
}

// Glass container reusable (نفس Step 1)
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
