import 'package:flutter/material.dart';
import '../../main.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  final _searchController = TextEditingController();

  int selectedUser = -1;

  // 🔥 بيانات وهمية مؤقتًا (قبل قاعدة البيانات)
  final List<Map<String, dynamic>> users = [
    {
      "name": "Sarah Ahmed",
      "email": "sarah@app.com",
      "role": "User",
      "joined": "2024-01-05",
      "avatar": "https://i.pravatar.cc/150?img=47",
    },
    {
      "name": "Omar Khaled",
      "email": "omar@app.com",
      "role": "Seller",
      "joined": "2024-02-12",
      "avatar": "https://i.pravatar.cc/150?img=12",
    },
    {
      "name": "Maya Cohen",
      "email": "maya@app.com",
      "role": "User",
      "joined": "2024-03-03",
      "avatar": "https://i.pravatar.cc/150?img=23",
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Row(
      children: [
        // -----------------------------------------------------------
        // Left Side: Table
        // -----------------------------------------------------------
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                "Users Management",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3B3B3B),
                ),
              ),

              const SizedBox(height: 25),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search users...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() {}),
                ),
              ),

              const SizedBox(height: 30),

              // Users Table
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(18),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, i) {
                      final u = users[i];
                      final match = u["name"]
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()) ||
                          u["email"]
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase());

                      if (!match) return const SizedBox();

                      return GestureDetector(
                        onTap: () => setState(() => selectedUser = i),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: selectedUser == i
                                ? Colors.white.withOpacity(0.65)
                                : Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(u["avatar"]),
                                radius: 24,
                              ),

                              const SizedBox(width: 18),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u["name"],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      u["email"],
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Role
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.brown.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  u["role"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 25),

        // -----------------------------------------------------------
        // Right Side: User Profile Sidebar
        // -----------------------------------------------------------
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: selectedUser == -1
                ? const Center(
                    child: Text(
                      "Select a user from the list",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : buildProfile(users[selectedUser]),
          ),
        ),
      ],
    );
  }

  Widget buildProfile(Map<String, dynamic> u) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(u["avatar"]),
          radius: 45,
        ),
        const SizedBox(height: 20),
        Text(
          u["name"],
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          u["email"],
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            u["role"],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 30),

        // Actions
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text("Edit User"),
        ),

        const SizedBox(height: 14),

        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text("Delete User"),
        ),
      ],
    );
  }
}
