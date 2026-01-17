import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

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
        Timer.periodic(const Duration(seconds: 3), (_) {
      _loadMessages();
    });
  }

  // ===============================
  // INIT CHAT (مضمون 100%)
  // ===============================
  Future<void> _initChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ✅ استخدام getInt بدلاً من getString لأن login_page.dart يستخدم setInt
      myId = prefs.getInt("user_id") ?? 0;

      if (myId == 0) {
        if (mounted) {
          setState(() => loading = false);
        }
        return;
      }

      debugPrint("ChatPage: Initializing chat - myId=$myId, receiverId=${widget.receiverId}, productId=${widget.productId}");
      
      // ✅ التحقق من أن receiverId صحيح
      if (widget.receiverId == 0 || widget.receiverId == myId) {
        throw Exception("Invalid receiver ID");
      }

      // ✅ إنشاء/الحصول على المحادثة مع التحقق من الاتساق
      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}create_or_get_conversation.php"),
        body: {
          "user1_id": myId.toString(),
          "user2_id": widget.receiverId.toString(),
          "product_id": widget.productId.toString(),
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Request timeout");
        },
      );

      debugPrint("ChatPage: API Response Status: ${res.statusCode}");
      debugPrint("ChatPage: API Response Body: ${res.body}");

      if (res.statusCode != 200) {
        throw Exception("Server returned status code: ${res.statusCode}");
      }

      // ✅ معالجة JSON بشكل آمن
      Map<String, dynamic> data;
      try {
        data = json.decode(res.body) as Map<String, dynamic>;
      } catch (jsonError) {
        debugPrint("ChatPage: JSON Decode Error: $jsonError");
        throw Exception("Invalid response from server");
      }

      if (data["status"] == "success") {
        conversationId =
            int.tryParse(data["conversation_id"]?.toString() ?? "") ?? 0;

        debugPrint("ChatPage: Conversation ID: $conversationId");

        if (conversationId == 0) {
          debugPrint("ChatPage: Warning - conversation_id is 0");
          if (mounted) {
            setState(() => loading = false);
          }
          return;
        }

        // ✅ تحميل الرسائل مع معالجة الأخطاء
        try {
          await _loadMessages().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint("ChatPage: _loadMessages timeout");
              // لا نرمي خطأ هنا، فقط نكمل
            },
          );
        } catch (loadError) {
          debugPrint("ChatPage: Error loading messages: $loadError");
          // نكمل حتى لو فشل تحميل الرسائل
        }

        _startPolling();

        if (mounted) {
          setState(() => loading = false);
        }
      } else {
        final errorMessage = data["message"]?.toString() ?? 
                           data["error"]?.toString() ?? 
                           "Failed to create conversation";
        debugPrint("ChatPage: API Error: $errorMessage");
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint("ChatPage: Error in _initChat: $e");
      
      // ✅ عرض رسالة خطأ للمستخدم
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load conversation: ${e.toString()}"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // ✅ التأكد من إيقاف التحميل دائماً (حتى في حالة الخطأ)
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ===============================
  // LOAD MESSAGES (يدعم الدمج بدلاً من الاستبدال)
  // ===============================
  Future<void> _loadMessages({bool merge = false}) async {
    if (conversationId == 0) return;

    try {
      final res = await http.get(
        Uri.parse(
            "${AppConfig.baseUrl}get_messages.php?conversation_id=$conversationId"),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Request timeout");
        },
      );

      debugPrint("ChatPage: get_messages API Response Status: ${res.statusCode}");
      debugPrint("ChatPage: get_messages API Response Body Length: ${res.body.length}");

      if (res.statusCode < 200 || res.statusCode >= 300) {
        debugPrint("ChatPage: get_messages returned status ${res.statusCode}");
        return;
      }

      Map<String, dynamic>? data;
      try {
        if (res.body.isNotEmpty && res.body.trim().isNotEmpty) {
          final decoded = json.decode(res.body);
          if (decoded is Map<String, dynamic>) {
            data = decoded;
          }
        }
      } catch (jsonError) {
        debugPrint("ChatPage: JSON decode error in _loadMessages: $jsonError");
        return;
      }

      if (data != null && data["status"] == "success") {
        final List newMessages = data["messages"] ?? [];

        if (!mounted) return;

        if (merge) {
          // ✅ دمج الرسائل الجديدة مع الموجودة (بدون استبدال)
          setState(() {
            // ✅ إنشاء خريطة للرسائل الموجودة لتجنب التكرار
            final existingMessageKeys = <String>{};
            for (var msg in messages) {
              // ✅ استخدام معرف فريد للرسالة (إن وجد) أو محتوى الرسالة + المرسل + الوقت
              final msgId = msg["id"]?.toString() ?? 
                           msg["message_id"]?.toString() ??
                           "${msg["sender_id"]}_${msg["message"]}_${msg["created_at"]}";
              existingMessageKeys.add(msgId);
            }
            
            // ✅ إضافة الرسائل الجديدة التي لا توجد في القائمة
            for (var newMsg in newMessages) {
              final msgId = newMsg["id"]?.toString() ?? 
                           newMsg["message_id"]?.toString() ??
                           "${newMsg["sender_id"]}_${newMsg["message"]}_${newMsg["created_at"]}";
              
              if (!existingMessageKeys.contains(msgId)) {
                messages.add(newMsg);
                existingMessageKeys.add(msgId);
              }
            }
            
            // ✅ ترتيب الرسائل حسب الوقت
            messages.sort((a, b) {
              final timeA = DateTime.tryParse(a["created_at"]?.toString() ?? "") ?? DateTime(1970);
              final timeB = DateTime.tryParse(b["created_at"]?.toString() ?? "") ?? DateTime(1970);
              return timeA.compareTo(timeB);
            });
          });
        } else {
          // ✅ استبدال القائمة بالكامل (السلوك الافتراضي)
          setState(() {
            messages = newMessages;
          });
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.jumpTo(
              _scroll.position.maxScrollExtent,
            );
          }
        });
      } else {
        debugPrint("ChatPage: get_messages failed: ${data?["message"] ?? "Unknown error"}");
      }
    } catch (e) {
      debugPrint("ChatPage: Error in _loadMessages: $e");
      // لا نرمي الخطأ هنا، فقط نسجله
    }
  }

  // ===============================
  // SEND MESSAGE (STRICT BACKEND VALIDATION - NO OPTIMISTIC UI)
  // ===============================
  Future<void> _send() async {
    final text = _msg.text.trim();

    // ✅ STRICT VALIDATION - جميع الحقول مطلوبة
    if (text.isEmpty) {
      debugPrint("ChatPage: ERROR - Message text is empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot send empty message")),
      );
      return;
    }

    if (conversationId == 0) {
      debugPrint("ChatPage: ERROR - conversationId is 0");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Invalid conversation ID")),
      );
      return;
    }

    if (myId == 0) {
      debugPrint("ChatPage: ERROR - myId is 0");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User not logged in")),
      );
      return;
    }

    if (widget.receiverId == 0) {
      debugPrint("ChatPage: ERROR - receiverId is 0");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Invalid receiver ID")),
      );
      return;
    }

    if (widget.productId == 0) {
      debugPrint("ChatPage: ERROR - productId is 0");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Invalid product ID")),
      );
      return;
    }

    // ✅ حفظ النص مؤقتاً قبل الإرسال
    final messageText = text;
    
    // ✅ مسح حقل الإدخال (لكن لا نضيف الرسالة للقائمة حتى نؤكد الحفظ)
    _msg.clear();

    try {
      debugPrint("========================================");
      debugPrint("ChatPage: SENDING MESSAGE TO BACKEND");
      debugPrint("  sender_id: $myId");
      debugPrint("  receiver_id: ${widget.receiverId} (seller)");
      debugPrint("  product_id: ${widget.productId}");
      debugPrint("  message: $messageText");
      debugPrint("  message_length: ${messageText.length}");
      debugPrint("========================================");

      // ✅ إرسال جميع البيانات المطلوبة للسيرفر (كما يتوقعها send_message.php)
      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}send_message.php"),
        body: {
          "sender_id": myId.toString(),
          "receiver_id": widget.receiverId.toString(), // البائع (صاحب المنتج)
          "product_id": widget.productId.toString(), // معرف المنتج
          "message": messageText,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Request timeout - backend did not respond");
        },
      );

      debugPrint("ChatPage: send_message API Response Status: ${res.statusCode}");
      debugPrint("ChatPage: send_message API Response Body (raw): ${res.body}");
      debugPrint("ChatPage: send_message API Response Body Length: ${res.body.length}");

      // ✅ STRICT VALIDATION - HTTP status must be 200
      if (res.statusCode != 200) {
        debugPrint("ChatPage: ERROR - Server returned non-200 status: ${res.statusCode}");
        throw Exception("Server returned status code: ${res.statusCode}. Message was NOT saved.");
      }

      // ✅ STRICT VALIDATION - Response body must not be empty
      if (res.body.isEmpty || res.body.trim().isEmpty) {
        debugPrint("ChatPage: ERROR - Response body is empty");
        throw Exception("Backend returned empty response. Cannot verify if message was saved.");
      }

      // ✅ STRICT VALIDATION - Must parse JSON successfully
      Map<String, dynamic> data;
      try {
        final decoded = json.decode(res.body);
        if (decoded is! Map<String, dynamic>) {
          debugPrint("ChatPage: ERROR - Response is not a JSON object");
          debugPrint("ChatPage: Response type: ${decoded.runtimeType}");
          debugPrint("ChatPage: Response value: $decoded");
          throw Exception("Invalid response format from backend. Expected JSON object but got: ${decoded.runtimeType}");
        }
        data = decoded;
        debugPrint("ChatPage: JSON parsed successfully: $data");
      } catch (jsonError) {
        debugPrint("ChatPage: ERROR - JSON Decode Error: $jsonError");
        debugPrint("ChatPage: Full response body (first 1000 chars): ${res.body.length > 1000 ? res.body.substring(0, 1000) : res.body}");
        debugPrint("ChatPage: Response body length: ${res.body.length}");
        debugPrint("ChatPage: Response headers: ${res.headers}");
        
        // ✅ Check if response might be HTML error page
        if (res.body.contains('<!DOCTYPE') || res.body.contains('<html')) {
          throw Exception("Backend returned HTML instead of JSON. This usually means a PHP error occurred. Check backend error logs.");
        }
        
        // ✅ Check if response might be a plain text error
        if (res.body.trim().isNotEmpty && !res.body.trim().startsWith('{') && !res.body.trim().startsWith('[')) {
          throw Exception("Backend returned plain text instead of JSON: ${res.body.substring(0, 200)}");
        }
        
        throw Exception("Backend returned invalid JSON: $jsonError. Response: ${res.body.substring(0, 200)}");
      }

      // ✅ STRICT VALIDATION - Must have explicit success status
      final status = data["status"]?.toString().toLowerCase() ?? "";
      final messageId = data["message_id"]?.toString() ?? data["id"]?.toString();
      final errorMessage = data["message"]?.toString() ?? data["error"]?.toString();

      if (status != "success") {
        debugPrint("ChatPage: ERROR - Backend returned error status: $status");
        debugPrint("ChatPage: Error message: $errorMessage");
        throw Exception(errorMessage ?? "Backend returned error status: $status. Message was NOT saved.");
      }

      // ✅ STRICT VALIDATION - Verify message was actually saved
      debugPrint("ChatPage: Backend confirmed success. Message ID: $messageId");
      
      // ✅ Wait for database write to complete
      await Future.delayed(const Duration(milliseconds: 300));
      
      // ✅ VERIFY MESSAGE EXISTS IN DATABASE by reloading messages
      debugPrint("ChatPage: Verifying message exists in database...");
      await _loadMessages(merge: false); // Replace to get fresh data
      
      // ✅ Check if message exists in the loaded messages
      final messageExists = messages.any((m) => 
        (m["message"]?.toString() == messageText || 
         m["content"]?.toString() == messageText ||
         m["text"]?.toString() == messageText) &&
        (m["sender_id"]?.toString() == myId.toString() ||
         m["sender_id"] == myId)
      );
      
      if (!messageExists) {
        debugPrint("ChatPage: ERROR - Message not found in database after reload");
        debugPrint("ChatPage: Loaded ${messages.length} messages");
        debugPrint("ChatPage: Searching for message: '$messageText'");
        for (var msg in messages) {
          debugPrint("ChatPage:   - Message: ${msg["message"]}, Sender: ${msg["sender_id"]}");
        }
        throw Exception("Message was not saved to database. Backend returned success but message is missing.");
      }

      debugPrint("ChatPage: SUCCESS - Message confirmed in database");
      debugPrint("ChatPage: Message exists in ${messages.length} total messages");

      // ✅ Only now add message to UI (after backend confirmation)
      if (mounted) {
        // Scroll to bottom to show the new message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.animateTo(
              _scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }

    } catch (e) {
      debugPrint("========================================");
      debugPrint("ChatPage: ERROR SENDING MESSAGE");
      debugPrint("  Error: $e");
      debugPrint("  Message was NOT saved to database");
      debugPrint("========================================");
      
      // ✅ Restore message text to input field
      if (mounted) {
        _msg.text = messageText;
      }
      
      // ✅ Show error message
      if (mounted) {
        String errorMsg = "Failed to send message";
        
        if (e.toString().contains("timeout")) {
          errorMsg = "Connection timeout. Message was not saved";
        } else if (e.toString().contains("SocketException") || 
                   e.toString().contains("Failed host lookup")) {
          errorMsg = "Internet connection error. Message was not saved";
        } else if (e.toString().contains("NOT saved") || 
                   e.toString().contains("not found in database")) {
          errorMsg = "Failed to save message to database";
        } else if (e.toString().isNotEmpty) {
          errorMsg = "Error: ${e.toString()}";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "";
    final dt = DateTime.tryParse(dateTime);
    if (dt == null) return "";
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E0E),
        elevation: 0,
        title: Text(
          widget.receiverName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3DDC97),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final m = messages[i];
                      final isMe =
                          m["sender_id"].toString() ==
                              myId.toString();

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin:
                              const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFF3DDC97)
                                : const Color(0xFF1C2622),
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                m["message"] ?? "",
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(
                                    m["created_at"]),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isMe
                                      ? Colors.black54
                                      : Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _inputBar(),
              ],
            ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(12, 8, 12, 12),
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
                    borderRadius:
                        BorderRadius.circular(18),
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
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Icon(Icons.send,
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
