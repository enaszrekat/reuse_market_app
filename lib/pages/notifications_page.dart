import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final String baseUrl = "http://10.100.11.28/market_app/";
  bool loading = true;
  List notifications = [];
  int myId = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    myId = int.tryParse(prefs.getString("user_id") ?? "0") ?? 0;
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => loading = true);

    try {
      final res = await http.get(
        Uri.parse("${baseUrl}get_notifications.php?user_id=$myId"),
      );

      final data = json.decode(res.body);
      if (data["status"] == "success") {
        notifications = data["notifications"] ?? [];
        _markAllAsRead();
      }
    } catch (_) {}

    setState(() => loading = false);
  }

  Future<void> _markAllAsRead() async {
    try {
      await http.post(
        Uri.parse("${baseUrl}mark_notifications_read.php"),
        body: {"user_id": myId.toString()},
      );
    } catch (_) {}
  }

  String _formatTime(String t) {
    try {
      final d = DateTime.parse(t);
      return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1412),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1412),
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3DDC97)),
            )
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No notifications yet",
                    style: TextStyle(color: Colors.white54, fontSize: 15),
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF3DDC97),
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (_, i) {
                      final n = notifications[i];
                      final bool unread =
                          n["is_read"].toString() == "0";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: unread
                              ? const Color(0xFF1C2622)
                              : const Color(0xFF141B18),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: unread
                                ? const Color(0xFF3DDC97)
                                    .withOpacity(0.4)
                                : Colors.white12,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin:
                                  const EdgeInsets.only(top: 6, right: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: unread
                                    ? const Color(0xFF3DDC97)
                                    : Colors.transparent,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n["title"] ?? "",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: unread
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    n["body"] ?? "",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13.5,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatTime(n["created_at"] ?? ""),
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
