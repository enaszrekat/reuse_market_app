import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// صفحات
import 'admin/AdminLoginPage.dart';
import 'admin/admin_dashboard_new.dart';
import 'register_page.dart';
import 'login_page.dart';
import 'pages/main_layout.dart';
import 'pages/my_products_page.dart';

// الصفحات الجديدة
import 'pages/sell_product_page.dart';
import 'pages/trade_product_page.dart';
import 'pages/donate_item_page.dart';

// -------------------------------------------------------------
// 🔥 تغيير عنوان نافذة التطبيق
// -------------------------------------------------------------
void setWindowTitle(String title) {
  if (kIsWeb) return;
  try {
    SystemChannels.platform.invokeMethod(
      'SystemNavigator.setApplicationSwitcherDescription',
      {"label": title},
    );
  } catch (e) {}
}

// -------------------------------------------------------------
// 🌍 نظام الترجمة
// -------------------------------------------------------------
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'no_account': "Don't have an account?",
      'register': 'Register',
      'admin_login': 'Admin Login',
      'full_name': 'Full Name',
      'country': 'Country',
      'city': 'City',
      'street': 'Street',
      'house_number': 'House Number',
      'pickup_point': 'Pickup Location',
      'sell_products': 'Sell Products',
      'trade_products': 'Trade Products',
      'donate_items': 'Donate Items',
      'home_delivery': 'Home Delivery',
      'bio': 'Short Bio',
      'next': 'Next',
      'back': 'Back',
      'create_account': 'Create Account',
      'step1': 'Step 1 — Basic Info',
      'step2': 'Step 2 — Address',
      'step3': 'Step 3 — Preferences',

      // ⭐ HomePage keys
      'sell_product': 'Sell a Product',
      'trade_product': 'Trade a Product',
      'donate_item': 'Donate an Item',
      'choose_action': 'Choose an action',
      'welcome_back': 'Welcome back!',
    },

    'ar': {
      'login': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'no_account': 'ليس لديك حساب؟',
      'register': 'إنشاء حساب',
      'admin_login': 'دخول الأدمن',
      'full_name': 'الاسم الكامل',
      'country': 'الدولة',
      'city': 'المدينة',
      'street': 'الشارع',
      'house_number': 'رقم المنزل',
      'pickup_point': 'نقطة التسليم',
      'sell_products': 'بيع منتجات',
      'trade_products': 'تبديل منتجات',
      'donate_items': 'التبرع بعناصر',
      'home_delivery': 'توصيل للمنزل',
      'bio': 'نبذة قصيرة',
      'next': 'التالي',
      'back': 'رجوع',
      'create_account': 'إنشاء حساب',
      'step1': 'الخطوة 1 — معلومات أساسية',
      'step2': 'الخطوة 2 — العنوان',
      'step3': 'الخطوة 3 — التفضيلات',

      // ⭐ HomePage keys
      'sell_product': 'بيع منتج',
      'trade_product': 'تبديل منتج',
      'donate_item': 'التبرع بعنصر',
      'choose_action': 'اختر إجراء',
      'welcome_back': 'أهلاً بعودتك!',
    },

    'he': {
      'login': 'התחברות',
      'email': 'אימייל',
      'password': 'סיסמה',
      'no_account': 'אין לך חשבון?',
      'register': 'הרשמה',
      'admin_login': 'התחברות מנהל',
      'full_name': 'שם מלא',
      'country': 'מדינה',
      'city': 'עיר',
      'street': 'רחוב',
      'house_number': 'מספר בית',
      'pickup_point': 'נקודת איסוף',
      'sell_products': 'מכירת מוצרים',
      'trade_products': 'החלפת מוצרים',
      'donate_items': 'תרומת פריטים',
      'home_delivery': 'משלוח עד הבית',
      'bio': 'ביוגרפיה קצרה',
      'next': 'הבא',
      'back': 'חזרה',
      'create_account': 'צור חשבון',
      'step1': 'שלב 1 — מידע בסיסי',
      'step2': 'שלב 2 — כתובת',
      'step3': 'שלב 3 — העדפות',

      // ⭐ HomePage keys
      'sell_product': 'מכירת מוצר',
      'trade_product': 'החלפת מוצר',
      'donate_item': 'תרומת פריט',
      'choose_action': 'בחר פעולה',
      'welcome_back': 'ברוך שובך!',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocDelegate();
}

class _AppLocDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar', 'he'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(old) => false;
}

// -------------------------------------------------------------
// ROOT APP
// -------------------------------------------------------------
void main() {
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
      locale: _locale,
      debugShowCheckedModeBanner: false,

      routes: {
        "/login": (_) => LoginPage(onLangChange: changeLang),
        "/register": (_) => RegisterPage(onLangChange: changeLang),
        "/home": (_) => MainLayout(onLangChange: changeLang),
        "/my-products": (_) => const MyProductsPage(),
        "/admin-login": (_) => AdminLoginPage(onLangChange: changeLang),

        "/admin-dashboard": (_) =>
            AdminDashboardPage(onLangChange: changeLang),

        // ⭐ الصفحات الجديدة
        "/sell-product": (_) => const SellProductPage(),
        "/trade-product": (_) => const TradeProductPage(),
        "/donate-item": (_) => const DonateItemPage(),
      },

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

      home: LoginPage(onLangChange: changeLang),
    );
  }
}
