import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'chat_page.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final String baseUrl = "http://10.100.11.28/market_app/";
  final TextEditingController _search = TextEditingController();

  List conversations = [];
  List filtered = [];
  bool loading = true;
  int myId = 0;

  @override
  void initState() {
    super.initState();
    _loadInbox();
    _search.addListener(_filter);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadInbox() async {
    final prefs = await SharedPreferences.getInstance();
    myId = int.tryParse(prefs.getString("user_id") ?? "0") ?? 0;

    try {
      final res = await http.get(
        Uri.parse("${baseUrl}get_conversations.php?user_id=$myId"),
      );

      final data = json.decode(res.body);

      if (data["status"] == "success") {
        setState(() {
          conversations = data["conversations"] ?? [];
          filtered = conversations;
          loading = false;
        });
      } else {
        loading = false;
      }
    } catch (_) {
      loading = false;
    }
  }

  void _filter() {
    final q = _search.text.toLowerCase();
    if (q.isEmpty) {
      setState(() => filtered = conversations);
      return;
    }

    setState(() {
      filtered = conversations.where((c) {
        return (c["other_user_name"] ?? "")
                .toString()
                .toLowerCase()
                .contains(q) ||
            (c["last_message"] ?? "")
                .toString()
                .toLowerCase()
                .contains(q) ||
            (c["product_title"] ?? "")
                .toString()
                .toLowerCase()
                .contains(q);
      }).toList();
    });
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "";
    try {
      final dt = DateTime.parse(dateTime);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
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
          "Inbox",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3DDC97)),
            )
          : Column(
              children: [
                _searchBar(),
                Expanded(
                  child: filtered.isEmpty
                      ? _empty()
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) =>
                              _conversationTile(filtered[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _search,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search chats...",
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon:
              const Icon(Icons.search, color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF151E1B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _conversationTile(Map c) {
    final int unread =
        int.tryParse(c["unread_count"]?.toString() ?? "0") ?? 0;

    return Slidable(
      key: ValueKey(c["conversation_id"]),
      endActionPane: ActionPane(
        motion: const StretchMotion(), // ✅ التعديل الوحيد
        children: [
          SlidableAction(
            onPressed: (_) => _archive(c),
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archive',
          ),
          SlidableAction(
            onPressed: (_) => _delete(c),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(
                productId: int.parse(c["product_id"].toString()),
                receiverId:
                    int.parse(c["other_user_id"].toString()),
                receiverName: c["other_user_name"] ?? "User",
                productTitle: c["product_title"] ?? "",
              ),
            ),
          ).then((_) => _loadInbox());
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: unread > 0
                ? const Color(0xFF1A2421)
                : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: Color(0xFF1F2A26)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3DDC97),
                      Color(0xFF1DBF73),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    (c["other_user_name"] ?? "U")
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c["other_user_name"] ?? "",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            unread > 0 ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c["last_message"] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            unread > 0 ? Colors.white : Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(c["last_message_time"]),
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white38),
                  ),
                  const SizedBox(height: 6),
                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3DDC97),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        unread > 99 ? "99+" : unread.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _archive(Map c) async {
    await http.post(
      Uri.parse("${baseUrl}archive_conversation.php"),
      body: {
        "conversation_id": c["conversation_id"].toString(),
        "user_id": myId.toString(),
      },
    );
    _loadInbox();
  }

  Future<void> _delete(Map c) async {
    await http.post(
      Uri.parse("${baseUrl}delete_conversation.php"),
      body: {
        "conversation_id": c["conversation_id"].toString(),
        "user_id": myId.toString(),
      },
    );
    _loadInbox();
  }

  Widget _empty() {
    return const Center(
      child: Text(
        "No conversations yet",
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
