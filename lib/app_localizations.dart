// 🌍 نظام الترجمة
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // LOGIN PAGE
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'welcome': 'Welcome Back!',
      'no_account': "Don't have an account?",
      'register': 'Register',
      'admin_login': 'Admin Login',
      'home_title': 'Main Menu',
      'sell_product': 'Sell Product',
      'trade_product': 'Trade Product',
      'donate_item': 'Donate Item',
      'welcome_back': 'Welcome back!',
      'choose_action': 'Choose an action',

      // REGISTER PAGE
      'register_title': 'Create Account',
      'step1': 'Step 1 of 3 — Basic Info',
      'step2': 'Step 2 of 3 — Address',
      'step3': 'Step 3 of 3 — Preferences',

      'full_name': 'Full Name',
      'country': 'Country',
      'city': 'City',
      'street': 'Street',
      'house_number': 'House Number',
      'pickup_point': 'Choose pickup point',

      'sell_products': 'Sell Products',
      'trade_products': 'Trade Products',
      'donate_items': 'Donate Items',
      'home_delivery': 'Home Delivery',
      'bio': 'Short Bio',

      'next': 'Next',
      'back': 'Back',
      'create_account': 'Create Account',
    },

    'ar': {
      // LOGIN PAGE
      'login': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'welcome': 'أهلاً بعودتك!',
      'no_account': 'ليس لديك حساب؟',
      'register': 'إنشاء حساب',
      'admin_login': 'دخول الأدمن',
      'home_title': 'القائمة الرئيسية',
      'sell_product': 'بيع منتج',
      'trade_product': 'تبديل منتج',
      'donate_item': 'تبرع بمنتج',
      'welcome_back': 'مرحباً بعودتك!',
      'choose_action': 'اختر ما تريد فعله',

      // REGISTER PAGE
      'register_title': 'إنشاء حساب',
      'step1': 'الخطوة 1 من 3 — المعلومات الأساسية',
      'step2': 'الخطوة 2 من 3 — العنوان',
      'step3': 'الخطوة 3 من 3 — التفضيلات',

      'full_name': 'الاسم الكامل',
      'country': 'الدولة',
      'city': 'المدينة',
      'street': 'الشارع',
      'house_number': 'رقم المنزل',
      'pickup_point': 'اختر نقطة استلام',

      'sell_products': 'بيع منتجات',
      'trade_products': 'تبديل منتجات',
      'donate_items': 'التبرع بأشياء',
      'home_delivery': 'توصيل للمنزل',
      'bio': 'نبذة قصيرة',

      'next': 'التالي',
      'back': 'رجوع',
      'create_account': 'إنشاء حساب',
    },

    'he': {
      // LOGIN PAGE
      'login': 'התחברות',
      'email': 'אימייל',
      'password': 'סיסמה',
      'welcome': 'ברוך שובך!',
      'no_account': 'אין לך חשבון?',
      'register': 'הרשמה',
      'admin_login': 'התחברות אדמין',
      'home_title': 'תפריט ראשי',
      'sell_product': 'מכירת מוצר',
      'trade_product': 'החלפת מוצר',
      'donate_item': 'תרומת פריט',
      'welcome_back': 'ברוך שובך!',
      'choose_action': 'בחר פעולה',

      // REGISTER PAGE
      'register_title': 'יצירת חשבון',
      'step1': 'שלב 1 מתוך 3 — מידע בסיסי',
      'step2': 'שלב 2 מתוך 3 — כתובת',
      'step3': 'שלב 3 מתוך 3 — העדפות',

      'full_name': 'שם מלא',
      'country': 'מדינה',
      'city': 'עיר',
      'street': 'רחוב',
      'house_number': 'מספר בית',
      'pickup_point': 'בחר נקודת איסוף',

      'sell_products': 'מכירת מוצרים',
      'trade_products': 'החלפת מוצרים',
      'donate_items': 'תרומת פריטים',
      'home_delivery': 'משלוח לבית',
      'bio': 'תיאור קצר',

      'next': 'הבא',
      'back': 'חזרה',
      'create_account': 'צור חשבון',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocDelegate();
}
