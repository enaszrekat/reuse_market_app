import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final int productId;
  final int receiverId;
  final String receiverName;
  final String productTitle;

  const ChatPage({
    super.key,
    required this.productId,
    required this.receiverId,
    required this.receiverName,
    required this.productTitle,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with WidgetsBindingObserver {
  final String baseUrl = "http://10.100.11.28/market_app/";
  final TextEditingController _msg = TextEditingController();
  final ScrollController _scroll = ScrollController();

  int myId = 0;
  int conversationId = 0;
  List messages = [];
  bool loading = true;

  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initChat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _msg.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // 🟢 App lifecycle → وقف / شغل polling
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pollTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _loadMessages());
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "";
    final dt = DateTime.tryParse(dateTime);
    if (dt == null) return "";
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  bool get _isOnline {
    if (messages.isEmpty) return false;
    final last = messages.last;
    if (last["sender_id"].toString() == myId.toString()) return false;
    final t = DateTime.tryParse(last["created_at"] ?? "");
    if (t == null) return false;
    return DateTime.now().difference(t).inSeconds <= 60;
  }

  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    myId = int.tryParse(prefs.getString("user_id") ?? "0") ?? 0;

    final res = await http.post(
      Uri.parse("${baseUrl}create_or_get_conversation.php"),
      body: {
        "user1_id": myId.toString(),
        "user2_id": widget.receiverId.toString(),
        "product_id": widget.productId.toString(),
      },
    );

    final data = json.decode(res.body);
    if (data["status"] != "success") {
      if (!mounted) return;
      setState(() => loading = false);
      return;
    }

    conversationId =
        int.tryParse(data["conversation_id"].toString()) ?? 0;

    await _loadMessages();
    _markAsRead();
    _startPolling();
  }

  Future<void> _loadMessages() async {
    if (conversationId == 0) return;

    try {
      final res = await http.get(
        Uri.parse(
            "${baseUrl}get_messages.php?conversation_id=$conversationId"),
      );
      final data = json.decode(res.body);

      if (data["status"] == "success") {
        final List newMessages = data["messages"] ?? [];

        if (!mounted) return;

        if (newMessages.length != messages.length) {
          setState(() {
            messages = newMessages;
            loading = false;
          });
        }

        _markAsRead();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients &&
              _scroll.position.maxScrollExtent > 0) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _markAsRead() async {
    if (conversationId == 0 || myId == 0) return;

    try {
      await http.post(
        Uri.parse("${baseUrl}mark_as_read.php"),
        body: {
          "conversation_id": conversationId.toString(),
          "user_id": myId.toString(),
        },
      );
    } catch (_) {}
  }

  Future<void> _send() async {
    final text = _msg.text.trim();
    if (text.isEmpty || conversationId == 0) return;

    _msg.clear();

    setState(() {
      messages = List.from(messages)
        ..add({
          "sender_id": myId,
          "message": text,
          "created_at": DateTime.now().toString(),
          "is_read": 0,
        });
    });

    try {
      final res = await http.post(
        Uri.parse("${baseUrl}send_message.php"),
        body: {
          "conversation_id": conversationId.toString(),
          "sender_id": myId.toString(),
          "message": text,
        },
      );

      final data = json.decode(res.body);
      if (data["status"] != "success" && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Message failed")),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Network error")),
        );
      }
    }
  }

  bool _isSeen(int index) {
    if (index != messages.length - 1) return false;
    return messages[index]["is_read"].toString() == "1";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1412),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1412),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.receiverName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.green : Colors.white38,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Text(
              _isOnline ? "Online" : "Offline",
              style: TextStyle(
                fontSize: 12,
                color: _isOnline ? Colors.green : Colors.white38,
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF3DDC97)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    itemCount: messages.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    itemBuilder: (_, i) {
                      final m = messages[i];
                      final isMe =
                          m["sender_id"].toString() ==
                              myId.toString();

                      return _bubble(
                        text: m["message"] ?? "",
                        isMe: isMe,
                        time: m["created_at"],
                        seen: isMe ? _isSeen(i) : null,
                      );
                    },
                  ),
                ),
                _inputBar(),
              ],
            ),
    );
  }

  Widget _bubble({
    required String text,
    required bool isMe,
    String? time,
    bool? seen,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF3DDC97)
              : const Color(0xFF1C2622),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                isMe ? const Radius.circular(18) : Radius.zero,
            bottomRight:
                isMe ? Radius.zero : const Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                  color: isMe ? Colors.black : Colors.white,
                  fontSize: 14.5),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isMe ? Colors.black54 : Colors.white38,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Icon(
                    seen == true
                        ? Icons.done_all
                        : Icons.done,
                    size: 14,
                    color:
                        seen == true ? Colors.blue : Colors.black54,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        color: const Color(0xFF151E1B),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msg,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle:
                      const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1C2622),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: _send,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3DDC97),
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    const Icon(Icons.send, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
