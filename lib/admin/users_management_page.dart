import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  List<Map<String, dynamic>> users = [
    {
      "name": "Einas",
      "country": "Israel",
      "joined": "2024",
      "avatar": null, // الصورة يرفعها المستخدم
      "trades": 4,
      "sales": 6
    },
    {
      "name": "Sara",
      "country": "Jordan",
      "joined": "2023",
      "avatar": null,
      "trades": 10,
      "sales": 2
    },
  ];

  Future<void> pickImage(int index) async {
    final ImagePicker picker = ImagePicker();

    final XFile? img = await picker.pickImage(source: ImageSource.gallery);

    if (img == null) return;

    final Uint8List bytes = await img.readAsBytes();

    setState(() {
      users[index]["avatar"] = bytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final t = AppLocalizations(locale);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth > 600;

        return GridView.builder(
          padding: const EdgeInsets.all(18),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wide ? 2 : 1,
            childAspectRatio: 1.18,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25,
          ),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _userCard(users[index], index);
          },
        );
      },
    );
  }

  Widget _userCard(Map<String, dynamic> user, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // الخلفية الشفافة
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // -------- Avatar --------
                  GestureDetector(
                    onTap: () => pickImage(index),
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: user["avatar"] == null
                            ? Icon(Icons.camera_alt,
                                color: Colors.white.withOpacity(0.7), size: 40)
                            : Image.memory(
                                user["avatar"],
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    user["name"],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "${user["country"]} • Joined ${user["joined"]}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _stat("Trades", user["trades"]),
                      _stat("Sales", user["sales"]),
                    ],
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.28),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Profile"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
