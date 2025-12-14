import 'package:flutter/material.dart';

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> myProducts = [
    {
      "name": "Elegant Dress",
      "price": "80₪",
      "image": "https://i.imgur.com/Jy9sU0W.jpeg",
      "status": "Approved",
    },
    {
      "name": "Gold Necklace",
      "price": "120₪",
      "image": "https://i.imgur.com/dYcYQ7M.jpeg",
      "status": "Pending",
    },
    {
      "name": "Jacket",
      "price": "60₪",
      "image": "https://i.imgur.com/4YQeHn8.jpeg",
      "status": "Rejected",
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color statusColor(String s) {
    switch (s) {
      case "Approved":
        return Colors.greenAccent;
      case "Pending":
        return Colors.amberAccent;
      case "Rejected":
        return Colors.redAccent;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D0D0D),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "My Products",
          style: TextStyle(
            color: Color(0xffD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // شبكتين
            childAspectRatio: 0.75,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
          ),
          itemCount: myProducts.length,
          itemBuilder: (context, i) {
            final p = myProducts[i];

            return GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18)),
                      child: Image.network(
                        p["image"],
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      p["name"],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      p["price"],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xffD4AF37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor(p["status"]).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: statusColor(p["status"]), width: 1),
                      ),
                      child: Text(
                        p["status"],
                        style: TextStyle(
                          color: statusColor(p["status"]),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
