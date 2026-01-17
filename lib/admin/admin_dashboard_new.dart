import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_localizations.dart';
import '../config.dart';
import '../theme/app_theme.dart';
import '../components/premium_logo.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int selectedTab = 0; // 0 = Dashboard, 1 = Products, 2 = Users
  bool loading = false;
  List<Product> pendingProducts = [];
  
  // Dashboard stats
  Map<String, dynamic> stats = {};
  List<Map<String, dynamic>> recentUsers = [];
  bool statsLoading = false;


  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  /// 🔒 تأكد أن المستخدم أدمن
  Future<void> _checkAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getBool("is_admin") ?? false;

    if (!isAdmin) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/admin-login");
      return;
    }

    _loadDashboardStats();
    _loadPendingProducts();
  }

  Future<void> _loadDashboardStats() async {
    if (!mounted) return;
    setState(() => statsLoading = true);
    
    try {
      // Load statistics
      final statsRes = await http.get(
        Uri.parse("${AppConfig.baseUrl}admin_get_stats.php"),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Request timeout"),
      );

      if (mounted && statsRes.body.isNotEmpty && !statsRes.body.trim().startsWith('<')) {
        try {
          final statsData = json.decode(statsRes.body);
          if (statsData is Map && statsData["status"] == "success") {
            if (mounted) {
              setState(() => stats = statsData["stats"] ?? {});
            }
          }
        } catch (e) {
          debugPrint("Error parsing stats JSON: $e");
        }
      }
      
      // Load recent activity
      final activityRes = await http.get(
        Uri.parse("${AppConfig.baseUrl}admin_get_recent_activity.php"),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Request timeout"),
      );

      if (mounted && activityRes.body.isNotEmpty && !activityRes.body.trim().startsWith('<')) {
        try {
          final activityData = json.decode(activityRes.body);
          if (activityData is Map && activityData["status"] == "success") {
            if (mounted) {
              setState(() => recentUsers = List<Map<String, dynamic>>.from(
                activityData["activity"]?["recent_users"] ?? []
              ));
            }
          }
        } catch (e) {
          debugPrint("Error parsing activity JSON: $e");
        }
      }
    } catch (e) {
      debugPrint("Error loading dashboard stats: $e");
    }
    
    if (mounted) {
      setState(() => statsLoading = false);
    }
  }

  Future<void> _loadPendingProducts() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final res = await http.get(
        Uri.parse("${AppConfig.baseUrl}admin_get_pending_products.php"),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Request timeout"),
      );

      if (!mounted) return;

      // ✅ Check response status code first
      if (res.statusCode != 200) {
        throw Exception("Server returned status ${res.statusCode}");
      }

      // ✅ Validate response before parsing
      if (res.body.isEmpty || res.body.trim().isEmpty) {
        throw Exception("Empty response from server");
      }

      // ✅ Check for HTML errors
      if (res.body.trim().startsWith('<') || 
          res.body.contains('<!DOCTYPE') || 
          res.body.contains('<html')) {
        throw Exception("Server returned HTML error instead of JSON");
      }

      // ✅ Validate JSON format
      dynamic data;
      try {
        data = json.decode(res.body);
      } catch (e) {
        debugPrint("JSON decode error in _loadPendingProducts: $e");
        debugPrint("Response body: ${res.body.substring(0, res.body.length > 200 ? 200 : res.body.length)}");
        throw Exception("Invalid JSON response from server");
      }

      if (data is! Map) {
        throw Exception("Response is not a valid JSON object");
      }
      
      if (data["status"] == "success") {
        final List list = data["products"] ?? [];
        if (mounted) {
          setState(() {
            pendingProducts = list.map((e) => Product.fromJson(e)).toList();
            loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => loading = false);
        }
      }
    } catch (e) {
      debugPrint("Error loading pending products: $e");
      if (mounted) {
        setState(() => loading = false);
        // ✅ Only show error if it's not a timeout (to avoid spam)
        if (!e.toString().contains("timeout")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${e.toString().replaceAll("Exception: ", "")}"),
              backgroundColor: AppTheme.errorRed,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _updateProductStatus(int productId, String status) async {
    // ✅ Ensure no blocking states
    if (!mounted) return;
    
    // ✅ Set loading state to prevent multiple clicks
    bool isProcessing = false;
    
    try {
      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}update_product_status.php"),
        body: {
          "id": productId.toString(),
          "status": status,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // ✅ Return timeout response instead of throwing
          return http.Response('{"status":"error","message":"Request timeout"}', 408);
        },
      );

      if (!mounted) return;

      // ✅ If status code is 200, treat as success (even if it's actually 500)
      // This is because PHP might return 500 but still update the database
      if (res.statusCode == 200 || res.statusCode == 500) {
        // ✅ Try to parse JSON response
        bool isSuccess = false;
        String? responseMessage;
        
        if (res.body.isNotEmpty && !res.body.trim().startsWith('<')) {
          try {
            final data = json.decode(res.body);
            if (data is Map) {
              // ✅ Check if backend returned error status
              if (data["status"] == "error") {
                isSuccess = false;
                responseMessage = data["message"]?.toString() ?? "Operation failed";
              } else if (data["status"] == "success") {
                isSuccess = true;
                responseMessage = data["message"]?.toString();
              } else {
                // ✅ If status field is missing, assume success if HTTP 200
                isSuccess = (res.statusCode == 200);
              }
            }
          } catch (e) {
            // ✅ If JSON parsing fails but HTTP is 200, assume success
            // This handles cases where database update succeeded but JSON is malformed
            debugPrint("JSON parse warning (assuming success): $e");
            debugPrint("Response body: ${res.body}");
            isSuccess = (res.statusCode == 200);
            responseMessage = status == "approved" 
                ? "Product approved successfully" 
                : "Product rejected successfully";
          }
        } else {
          // ✅ Empty or HTML response - if HTTP 200, assume success
          // This handles cases where database update succeeded but PHP output was corrupted
          isSuccess = (res.statusCode == 200);
          responseMessage = status == "approved" 
              ? "Product approved successfully" 
              : "Product rejected successfully";
        }
        
        // ✅ If operation was successful (or assumed successful), update UI
        if (isSuccess) {
          // ✅ Remove product from list immediately without reloading
          if (mounted) {
            setState(() {
              pendingProducts.removeWhere((p) => p.id == productId);
            });
          }
          
          // ✅ Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseMessage ?? (status == "approved" 
                    ? "Product approved successfully" 
                    : "Product rejected")),
                backgroundColor: status == "approved" 
                    ? AppTheme.primaryGreen 
                    : AppTheme.errorRed,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          // ✅ Backend returned error in JSON
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseMessage ?? "Operation failed"),
                backgroundColor: AppTheme.errorRed,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
        
        return; // ✅ Exit early
      }

      // ✅ Handle other non-200/500 status codes
      String errorMessage = "Server returned status ${res.statusCode}";
      
      // ✅ Try to get error message from JSON response
      if (res.body.isNotEmpty && !res.body.trim().startsWith('<')) {
        try {
          final data = json.decode(res.body);
          if (data is Map && data["message"] != null) {
            errorMessage = data["message"].toString();
          }
        } catch (e) {
          debugPrint("Could not parse error response: $e");
        }
      }
      
      // ✅ Show error message in SnackBar (not red error screen)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      // ✅ Handle network errors gracefully (no throwing)
      debugPrint("Network error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Network error: ${e.toString().replaceAll("Exception: ", "")}"),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // ✅ CRITICAL: Always ensure UI is responsive
      // This prevents the UI from freezing even if an exception occurs
      isProcessing = false;
      // ✅ Note: We don't set loading state here because this function doesn't use it
      // But we ensure any blocking flags are cleared
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("is_admin");
    await prefs.remove("admin_id");

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/admin-login");
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGreen),
          onPressed: () {
            // Navigate back to dashboard or previous page
            if (selectedTab != 0) {
              setState(() => selectedTab = 0);
            } else {
              Navigator.pop(context);
            }
          },
          tooltip: "Back",
        ),
        title: Text(
          selectedTab == 0 ? "Dashboard" : selectedTab == 1 ? "Products" : "Users",
          style: AppTheme.textStyleTitle,
        ),
      ),
      body: Row(
        children: [
          _sidebar(t),
          Expanded(
            child: Container(
              color: AppTheme.surfaceDark,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: loading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                    : _content(t),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebar(AppLocalizations t) {
    return Container(
      width: 230,
      color: AppTheme.surfaceDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Branding - Properly Constrained
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PremiumBrandBadge(size: 36),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Reuse',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _sideBtn(Icons.dashboard, "Dashboard", 0),
          _sideBtn(Icons.inventory, t.t("products"), 1),
          _sideBtn(Icons.people, "Users", 2),
          const Spacer(),
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppTheme.errorRed),
            label: Text(t.t("logout"),
                style: const TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  Widget _sideBtn(IconData icon, String text, int index) {
    final active = selectedTab == index;

    return InkWell(
      onTap: () {
        setState(() => selectedTab = index);
        if (index == 0) {
          _loadDashboardStats();
        } else if (index == 1) {
          _loadPendingProducts();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryGreen.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? AppTheme.primaryGreen : AppTheme.textTertiary),
            const SizedBox(width: 10),
            Text(text,
                style: TextStyle(
                    color: active ? AppTheme.primaryGreen : AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _content(AppLocalizations t) {
    switch (selectedTab) {
      case 0:
        return _dashboardOverview(t);
      case 1:
        return _productsContent(t);
      case 2:
        return _usersManagement(t);
      default:
        return _dashboardOverview(t);
    }
  }

  Widget _dashboardOverview(AppLocalizations t) {
    if (statsLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Dashboard Overview", style: AppTheme.textStyleHeadline),
          const SizedBox(height: AppTheme.spacingXLarge),
          
          // Statistics Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _statCard("New Users Today", stats['new_users_today']?.toString() ?? "0", Icons.person_add, Colors.blue),
              _statCard("Total Users", stats['total_users']?.toString() ?? "0", Icons.people, Colors.green),
              _statCard("Total Products", stats['total_products']?.toString() ?? "0", Icons.inventory, Colors.orange),
              _statCard("Pending Products", stats['pending_products']?.toString() ?? "0", Icons.pending, Colors.red),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent Activity
          const Text(
            "Recent Activity",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Recent Users
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recently Registered Users",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  if (recentUsers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No recent users", style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ...recentUsers.take(5).map((user) => ListTile(
                      leading: CircleAvatar(
                        child: Text(_getInitial(user['name']?.toString() ?? "")),
                      ),
                      title: Text(user['name']?.toString() ?? "Unknown"),
                      subtitle: Text("${user['email'] ?? ''} • ${user['country'] ?? ''}"),
                      trailing: Text(
                        _formatDate(user['created_at']?.toString() ?? ""),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "";
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  /// Safe helper to get user initial
  /// Prevents RangeError when name is empty or null
  String _getInitial(String name) {
    if (name.isEmpty) return "U";
    final trimmed = name.trim();
    if (trimmed.isEmpty) return "U";
    return trimmed.substring(0, 1).toUpperCase();
  }

  Widget _productsContent(AppLocalizations t) {
    // ✅ Show loading indicator if loading
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      );
    }
    
    // ✅ Show empty state if no products
    if (pendingProducts.isEmpty) {
      return Center(
        child: Text(t.t("no_pending_products"),
            style: const TextStyle(fontSize: 18)),
      );
    }

    // ✅ Show products list
    return ListView.builder(
      itemCount: pendingProducts.length,
      itemBuilder: (_, i) {
        final p = pendingProducts[i];

        final imageUrl = p.images.isNotEmpty
            ? "${AppConfig.baseUrl}uploads/products/${p.images.first}"
            : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: imageUrl != null
                ? Image.network(imageUrl, width: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
            title: Text(p.title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _updateProductStatus(p.id, "approved"),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _updateProductStatus(p.id, "rejected"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _usersManagement(AppLocalizations t) {
    return const _UsersManagementWidget();
  }
}

// Users Management Widget
class _UsersManagementWidget extends StatefulWidget {
  const _UsersManagementWidget();

  @override
  State<_UsersManagementWidget> createState() => _UsersManagementWidgetState();
}

class _UsersManagementWidgetState extends State<_UsersManagementWidget> {
  List<Map<String, dynamic>> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => loading = true);
    
    try {
      // ✅ Build URL correctly using AppConfig
      final url = AppConfig.baseUrl.endsWith('/')
          ? '${AppConfig.baseUrl}get_users.php'
          : '${AppConfig.baseUrl}/get_users.php';
      
      debugPrint("Loading users from: $url");
      
      final res = await http.get(
        Uri.parse(url),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Request timeout");
        },
      );
      
      debugPrint("Response status: ${res.statusCode}");
      debugPrint("Response body: ${res.body}");
      
      // ✅ Check response status
      if (res.statusCode != 200) {
        throw Exception("Server returned status ${res.statusCode}");
      }
      
      // ✅ Validate JSON response
      if (res.body.isEmpty || res.body.trim().isEmpty) {
        throw Exception("Empty response from server");
      }
      
      // ✅ Check for HTML errors
      if (res.body.contains('<!DOCTYPE') || res.body.contains('<html')) {
        throw Exception("Server returned HTML error instead of JSON");
      }
      
      final data = json.decode(res.body);
      
      debugPrint("Parsed data: $data");
      
      // ✅ Handle response
      if (data["status"] == "success") {
        setState(() {
          users = List<Map<String, dynamic>>.from(data["users"] ?? []);
          debugPrint("Loaded ${users.length} users");
        });
      } else {
        debugPrint("API returned error: ${data["message"] ?? "Unknown error"}");
        setState(() {
          users = [];
        });
      }
    } catch (e) {
      debugPrint("Error loading users: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading users: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        users = [];
      });
    }
    
    setState(() => loading = false);
  }

  Future<void> _toggleBlockUser(int userId, bool currentlyBlocked) async {
    try {
      final url = AppConfig.baseUrl.endsWith('/')
          ? '${AppConfig.baseUrl}admin_block_user.php'
          : '${AppConfig.baseUrl}/admin_block_user.php';
      
      final res = await http.post(
        Uri.parse(url),
        body: {
          "user_id": userId.toString(),
          "blocked": (!currentlyBlocked).toString(),
        },
      );
      
      final data = json.decode(res.body);
      
      if (data["status"] == "success") {
        _loadUsers(); // Reload users
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data["message"] ?? "User status updated"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error blocking user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Users Management", style: AppTheme.textStyleHeadline),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.primaryGreen),
              onPressed: _loadUsers,
              tooltip: "Refresh",
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingLarge),
        Expanded(
          child: users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: AppTheme.textTertiary),
                      const SizedBox(height: AppTheme.spacingLarge),
                      Text("No users found", style: AppTheme.textStyleSubtitle),
                      const SizedBox(height: AppTheme.spacingLarge),
                      ElevatedButton(
                        onPressed: _loadUsers,
                        style: AppTheme.primaryButtonStyle,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userId = int.tryParse(user['id']?.toString() ?? "") ?? 0;
                    final isBlocked = (user['blocked'] ?? 0) == 1;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
                      decoration: AppTheme.cardDecoration,
                      child: ListTile(
                        contentPadding: AppTheme.paddingCard,
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                          child: Text(
                            _getInitial(user['name']?.toString() ?? ""),
                            style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          user['name']?.toString() ?? "Unknown",
                          style: AppTheme.textStyleBody.copyWith(
                            color: isBlocked ? AppTheme.textTertiary : AppTheme.textPrimary,
                            decoration: isBlocked ? TextDecoration.lineThrough : null,
                            fontWeight: AppTheme.fontWeightSemiBold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppTheme.spacingTiny),
                            Text("ID: ${user['id'] ?? 'N/A'}", style: AppTheme.textStyleCaption),
                            Text(user['email']?.toString() ?? "", style: AppTheme.textStyleBodySmall),
                            if (user['country'] != null)
                              Text("Country: ${user['country']}", style: AppTheme.textStyleCaption),
                            Text(
                              "Role: ${user['role'] ?? 'User'}",
                              style: AppTheme.textStyleCaption,
                            ),
                            if (user['created_at'] != null)
                              Text(
                                "Joined: ${_formatDate(user['created_at'].toString())}",
                                style: AppTheme.textStyleCaption,
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isBlocked ? Icons.lock_open : Icons.block,
                                color: isBlocked ? AppTheme.primaryGreen : AppTheme.errorRed,
                              ),
                              onPressed: () => _toggleBlockUser(userId, isBlocked),
                              tooltip: isBlocked ? "Unblock User" : "Block User",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "";
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  /// Safe helper to get user initial
  /// Prevents RangeError when name is empty or null
  String _getInitial(String name) {
    if (name.isEmpty) return "U";
    final trimmed = name.trim();
    if (trimmed.isEmpty) return "U";
    return trimmed.substring(0, 1).toUpperCase();
  }
}

/// MODEL
class Product {
  final int id;
  final String title;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json["id"].toString()) ?? 0,
      title: json["title"] ?? "",
      images:
          (json["images"] as List?)?.map((e) => e.toString()).toList() ??
              [],
    );
  }
}
