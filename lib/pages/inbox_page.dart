import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'chat_page.dart';
import '../config.dart';
import '../theme/app_theme.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
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
    // ✅ استخدام getInt بدلاً من getString لأن login_page.dart يستخدم setInt
    myId = prefs.getInt("user_id") ?? 0;

    if (myId == 0) {
      setState(() => loading = false);
      return;
    }

    try {
      debugPrint("InboxPage: Loading conversations for user_id=$myId");
      
      final res = await http.get(
        Uri.parse("${AppConfig.baseUrl}get_conversations.php?user_id=$myId"),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Request timeout");
        },
      );

      debugPrint("InboxPage: API Response Status: ${res.statusCode}");
      debugPrint("InboxPage: API Response Body: ${res.body}");

      if (res.statusCode < 200 || res.statusCode >= 300) {
        debugPrint("InboxPage: Server returned status ${res.statusCode}");
        setState(() => loading = false);
        return;
      }

      Map<String, dynamic>? data;
      try {
        if (res.body.isNotEmpty && res.body.trim().isNotEmpty) {
          data = json.decode(res.body) as Map<String, dynamic>;
        }
      } catch (jsonError) {
        debugPrint("InboxPage: JSON decode error: $jsonError");
        setState(() => loading = false);
        return;
      }

      if (data != null && data["status"] == "success") {
        final List conversationsList = data["conversations"] ?? [];
        debugPrint("InboxPage: Loaded ${conversationsList.length} conversations");
        
        // ✅ إثراء البيانات بآخر رسالة إذا لم تكن موجودة
        final enrichedConversations = await _enrichConversationsWithLastMessage(conversationsList);
        
        setState(() {
          conversations = enrichedConversations;
          filtered = conversations;
          loading = false;
        });
      } else {
        debugPrint("InboxPage: API returned error: ${data?["message"] ?? "Unknown error"}");
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("InboxPage: Error loading inbox: $e");
      setState(() => loading = false);
    }
  }

  // ===============================
  // ENRICH CONVERSATIONS WITH LAST MESSAGE
  // ===============================
  Future<List> _enrichConversationsWithLastMessage(List conversationsList) async {
    final List enriched = [];
    
    for (var conv in conversationsList) {
      final conversationId = int.tryParse(conv["conversation_id"]?.toString() ?? "") ?? 0;
      
      // ✅ إنشاء نسخة من المحادثة للتحسين
      final enrichedConv = Map<String, dynamic>.from(conv);
      
      // ✅ محاولة استخراج آخر رسالة من حقول مختلفة (للتوافق مع تنسيقات مختلفة)
      String? lastMessage = conv["last_message"]?.toString() ?? 
                           conv["latest_message"]?.toString() ?? 
                           conv["message"]?.toString() ?? 
                           conv["text"]?.toString();
      
      String? lastMessageTime = conv["last_message_time"]?.toString() ?? 
                               conv["latest_message_time"]?.toString() ?? 
                               conv["last_message_timestamp"]?.toString() ?? 
                               conv["updated_at"]?.toString() ?? 
                               conv["last_activity"]?.toString();
      
      // ✅ إذا كانت آخر رسالة موجودة بالفعل، استخدمها
      if (lastMessage != null && lastMessage.isNotEmpty &&
          lastMessageTime != null && lastMessageTime.isNotEmpty) {
        enrichedConv["last_message"] = lastMessage;
        enrichedConv["last_message_time"] = lastMessageTime;
        debugPrint("InboxPage: Conversation $conversationId already has last message: $lastMessage");
        enriched.add(enrichedConv);
        continue;
      }
      
      // ✅ إذا لم تكن موجودة، احصل على آخر رسالة من API
      if (conversationId > 0) {
        try {
          debugPrint("InboxPage: Fetching last message for conversation $conversationId");
          
          // ✅ محاولة الحصول على آخر رسالة (بدون limit أولاً، ثم نأخذ الأولى)
          final msgRes = await http.get(
            Uri.parse("${AppConfig.baseUrl}get_messages.php?conversation_id=$conversationId"),
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception("Request timeout");
            },
          );
          
          if (msgRes.statusCode >= 200 && msgRes.statusCode < 300) {
            try {
              if (msgRes.body.isNotEmpty && msgRes.body.trim().isNotEmpty) {
                final msgData = json.decode(msgRes.body) as Map<String, dynamic>;
                
                if (msgData["status"] == "success") {
                  final List messages = msgData["messages"] ?? [];
                  
                  if (messages.isNotEmpty) {
                    // ✅ ترتيب الرسائل حسب الوقت (الأحدث أولاً)
                    messages.sort((a, b) {
                      final timeA = DateTime.tryParse(a["created_at"]?.toString() ?? 
                                                     a["timestamp"]?.toString() ?? "") ?? DateTime(1970);
                      final timeB = DateTime.tryParse(b["created_at"]?.toString() ?? 
                                                     b["timestamp"]?.toString() ?? "") ?? DateTime(1970);
                      return timeB.compareTo(timeA); // DESC order
                    });
                    
                    // ✅ أخذ آخر رسالة (الأحدث)
                    final lastMsg = messages.first;
                    
                    // ✅ تحديث بيانات المحادثة
                    enrichedConv["last_message"] = lastMsg["message"] ?? 
                                                   lastMsg["text"] ?? 
                                                   lastMsg["content"] ?? "";
                    enrichedConv["last_message_time"] = lastMsg["created_at"] ?? 
                                                       lastMsg["timestamp"] ?? 
                                                       lastMsg["date"] ?? "";
                    
                    debugPrint("InboxPage: Enriched conversation $conversationId with last message: ${enrichedConv["last_message"]}");
                    enriched.add(enrichedConv);
                    continue;
                  }
                }
              }
            } catch (e) {
              debugPrint("InboxPage: Error parsing last message for conversation $conversationId: $e");
            }
          }
        } catch (e) {
          debugPrint("InboxPage: Error fetching last message for conversation $conversationId: $e");
        }
      }
      
      // ✅ إذا فشل الحصول على آخر رسالة، استخدم البيانات الأصلية مع قيم افتراضية
      if (enrichedConv["last_message"] == null || enrichedConv["last_message"].toString().isEmpty) {
        enrichedConv["last_message"] = "No messages yet";
      }
      if (enrichedConv["last_message_time"] == null || enrichedConv["last_message_time"].toString().isEmpty) {
        enrichedConv["last_message_time"] = DateTime.now().toIso8601String();
      }
      
      enriched.add(enrichedConv);
    }
    
    return enriched;
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
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        title: const Text("Inbox", style: AppTheme.textStyleTitle),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
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
      padding: EdgeInsets.fromLTRB(AppTheme.spacingLarge, AppTheme.spacingSmall, AppTheme.spacingLarge, AppTheme.spacingMedium),
      child: TextField(
        controller: _search,
        style: AppTheme.textStyleBody,
        decoration: InputDecoration(
          hintText: "Search chats...",
          hintStyle: AppTheme.textStyleBodySmall,
          prefixIcon: const Icon(Icons.search, color: AppTheme.textTertiary),
          filled: true,
          fillColor: AppTheme.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
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
        onTap: () async {
          await Navigator.push(
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
          );
          // ✅ إعادة تحميل الصندوق الوارد بعد العودة من المحادثة
          // هذا يضمن تحديث آخر رسالة وعدد الرسائل غير المقروءة
          if (mounted) {
            _loadInbox();
          }
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
      Uri.parse("${AppConfig.baseUrl}archive_conversation.php"),
      body: {
        "conversation_id": c["conversation_id"].toString(),
        "user_id": myId.toString(),
      },
    );
    _loadInbox();
  }

  Future<void> _delete(Map c) async {
    await http.post(
      Uri.parse("${AppConfig.baseUrl}delete_conversation.php"),
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
