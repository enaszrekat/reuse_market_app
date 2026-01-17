import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'services/notification_service.dart';
import 'services/cart_service.dart';
import 'localization/app_localizations.dart';

// USER PAGES
import 'login_page.dart';
import 'register_page.dart';
import 'pages/main_layout.dart';
import 'pages/my_products_page.dart';
import 'pages/cart_page.dart';
import 'pages/notifications_page.dart';
import 'pages/chat_page.dart';
import 'pages/sell_product_page.dart';
import 'pages/trade_product_page.dart';
import 'pages/donate_item_page.dart';

// ADMIN
import 'admin/AdminLoginPage.dart';
import 'admin/admin_dashboard_new.dart';
import 'admin/admin_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void changeLang(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        navigatorKey: NotificationService.navigatorKey,

      // 🎨 Global Black & Green Theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF3DDC97),
        scaffoldBackgroundColor: const Color(0xFF0E0E0E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3DDC97),
          secondary: Color(0xFF3DDC97),
          surface: Color(0xFF0E1412),
          background: Color(0xFF0E0E0E),
          error: Colors.redAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0E0E0E),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF3DDC97)),
          titleTextStyle: TextStyle(
            color: Color(0xFF3DDC97),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF151E1B),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3DDC97),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C2622),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF3DDC97).withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3DDC97), width: 2),
          ),
          hintStyle: const TextStyle(color: Colors.white38),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white54),
        ),
      ),

      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('he'),
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routes: {
        // ================= USER =================
        "/login": (_) => LoginPage(onLangChange: changeLang),
        "/register": (_) => RegisterPage(onLangChange: changeLang),
        "/home": (_) => MainLayout(onLangChange: (_) {}), // English only after login
        "/my-products": (_) => const MyProductsPage(),
        "/cart": (_) => const CartPage(),
        "/notifications": (_) => const NotificationsPage(),
        "/sell-product": (_) => const SellProductPage(),
        "/trade-product": (_) => const TradeProductPage(),
        "/donate-item": (_) => const DonateItemPage(),

        // ================= ADMIN =================
        "/admin-login": (_) => const AdminLoginPage(),

        "/admin-dashboard": (_) => AdminGuard(
              child: const AdminDashboardPage(),
            ),

        // ================= CHAT =================
        "/chat": (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map;

          return ChatPage(
            productId: int.tryParse(args["product_id"].toString()) ?? 0,
            receiverId:
                int.tryParse(args["receiver_id"].toString()) ?? 0,
            receiverName: args["receiver_name"] ?? "",
            productTitle: args["product_title"] ?? "",
          );
        },
      },

      // START PAGE
      home: LoginPage(onLangChange: changeLang),
      ),
    );
  }
}
