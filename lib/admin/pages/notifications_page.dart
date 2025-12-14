import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> notifications = [
    {
      "title": "New Message",
      "body": "A buyer contacted you!",
      "icon": Icons.message,
      "time": "2m ago"
    },
    {
      "title": "Product Approved",
      "body": "Your item is now visible to everyone.",
      "icon": Icons.check_circle,
      "time": "10m ago"
    },
    {
      "title": "New Favorite",
      "body": "Someone liked your product!",
      "icon": Icons.favorite,
      "time": "1h ago"
    },
    {
      "title": "Trade Request",
      "body": "You received a new trade request.",
      "icon": Icons.sync_alt,
      "time": "3h ago"
    },
    {
      "title": "Delivery Update",
      "body": "Your order has been shipped.",
      "icon": Icons.local_shipping,
      "time": "Yesterday"
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Notifications",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Color.lerp(
                      const Color(0xFF3D2C18),
                      const Color(0xFF1A140D),
                      _controller.value)!
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },

        child: ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: notifications.length,
          itemBuilder: (context, i) {
            final item = notifications[i];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _notificationCard(
                  item["icon"], item["title"], item["body"], item["time"]),
            );
          },
        ),
      ),
    );
  }

  Widget _notificationCard(
      IconData icon, String title, String body, String time) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.amber.shade300.withOpacity(.2),
            child: Icon(icon, color: Colors.amber.shade300, size: 28),
          ),
          const SizedBox(width: 14),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                      color: Colors.white.withOpacity(.8), fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // TIME
          Text(
            time,
            style: TextStyle(
                color: Colors.white.withOpacity(.6), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
