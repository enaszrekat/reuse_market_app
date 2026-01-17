import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'services/notification_service.dart';
import 'localization/app_localizations.dart';

// Pages
import 'login_page.dart';
import 'register_page.dart';
import 'admin/AdminLoginPage.dart';
import 'admin/admin_dashboard_new.dart';
import 'pages/main_layout.dart';
import 'pages/my_products_page.dart';
import 'pages/chat_page.dart';
import 'pages/sell_product_page.dart';
import 'pages/trade_product_page.dart';
import 'pages/donate_item_page.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      navigatorKey: NotificationService.navigatorKey,

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
        "/login": (_) => LoginPage(onLangChange: changeLang),
        "/register": (_) => RegisterPage(onLangChange: changeLang),
        "/home": (_) => MainLayout(onLangChange: changeLang),
        "/my-products": (_) => const MyProductsPage(),
        "/admin-login": (_) =>
            AdminLoginPage(onLangChange: changeLang),
        "/admin-dashboard": (_) =>
            AdminDashboardPage(onLangChange: changeLang),
        "/sell-product": (_) => const SellProductPage(),
        "/trade-product": (_) => const TradeProductPage(),
        "/donate-item": (_) => const DonateItemPage(),
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

      home: LoginPage(onLangChange: changeLang),
    );
  }
}
