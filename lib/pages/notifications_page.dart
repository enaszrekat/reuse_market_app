import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../theme/app_theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
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
    // ✅ Support both getInt and getString for user_id
    myId = prefs.getInt("user_id") ?? 
           int.tryParse(prefs.getString("user_id") ?? "0") ?? 0;
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      // ✅ Get ALL notifications (read + unread) - WhatsApp behavior
      final res = await http.get(
        Uri.parse("${AppConfig.baseUrl}get_notifications.php?user_id=$myId"),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('{"status":"error","notifications":[]}', 408),
      );

      if (!mounted) return;

      if (res.statusCode == 200 && res.body.isNotEmpty && !res.body.trim().startsWith('<')) {
        try {
          final data = json.decode(res.body);
          if (data["status"] == "success") {
            if (mounted) {
              setState(() {
                notifications = data["notifications"] ?? [];
              });
            }
            // ✅ get_notifications.php already marks as read, but call this as backup
            _markAllAsRead();
          }
        } catch (e) {
          debugPrint("Error parsing notifications JSON: $e");
          if (mounted) {
            setState(() {
              notifications = [];
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            notifications = [];
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading notifications: $e");
      if (mounted) {
        setState(() {
          notifications = [];
        });
      }
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      // ✅ Mark all notifications as read (WhatsApp behavior)
      // This is called as backup, get_notifications.php also marks them
      await http.post(
        Uri.parse("${AppConfig.baseUrl}mark_notifications_read.php"),
        body: {"user_id": myId.toString()},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('{"status":"error"}', 408),
      );
    } catch (e) {
      debugPrint("Error marking notifications as read: $e");
      // ✅ Don't fail if marking as read fails
    }
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
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        title: const Text("Notifications", style: AppTheme.textStyleTitle),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            )
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: AppTheme.textTertiary),
                      const SizedBox(height: AppTheme.spacingLarge),
                      Text(
                        "No notifications yet",
                        style: AppTheme.textStyleSubtitle.copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primaryGreen,
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: AppTheme.paddingPage,
                    itemCount: notifications.length,
                    itemBuilder: (_, i) {
                      final n = notifications[i];
                      final bool unread = (n["is_read"]?.toString() == "0") || 
                                        (n["seen"]?.toString() == "0");

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
                        padding: AppTheme.paddingCard,
                        decoration: BoxDecoration(
                          color: unread ? AppTheme.surfaceSecondary : AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          border: Border.all(
                            color: unread
                                ? AppTheme.primaryGreen.withOpacity(0.4)
                                : AppTheme.primaryGreen.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(top: 6, right: AppTheme.spacingLarge),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: unread ? AppTheme.primaryGreen : Colors.transparent,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n["title"]?.toString() ?? n["message"]?.toString() ?? "Notification",
                                    style: AppTheme.textStyleBodySmall.copyWith(
                                      fontWeight: unread ? AppTheme.fontWeightBold : AppTheme.fontWeightSemiBold,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingSmall),
                                  Text(
                                    n["body"]?.toString() ?? n["message"]?.toString() ?? "",
                                    style: AppTheme.textStyleBodySmall.copyWith(height: 1.4),
                                  ),
                                  const SizedBox(height: AppTheme.spacingSmall),
                                  Text(
                                    _formatTime(n["created_at"]?.toString() ?? ""),
                                    style: AppTheme.textStyleCaption,
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
