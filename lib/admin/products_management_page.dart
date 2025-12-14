// lib/admin/products_management_page.dart
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../main.dart';
import '../models/product.dart';

class ProductsManagementPage extends StatefulWidget {
  const ProductsManagementPage({super.key});

  @override
  State<ProductsManagementPage> createState() =>
      _ProductsManagementPageState();
}

class _ProductsManagementPageState extends State<ProductsManagementPage> {
  // ----------------------------- Fake Data مبدئيًا -----------------------------
  late List<Product> allProducts;

  // فلاتر "Magic"
  double? maxPrice;
  ProductCategory? selectedCategory;
  ProductStatus? selectedStatus;
  String? selectedColorName;
  int? selectedDateFilterIndex; // 0: اليوم, 1: آخر 7 أيام, 2: آخر 30 يوم

  @override
  void initState() {
    super.initState();
    _seedProducts();
  }

  void _seedProducts() {
    final now = DateTime.now();

    allProducts = [
      Product(
        id: 1,
        titleEn: 'Golden Headphones',
        titleAr: 'سماعات ذهبية',
        titleHe: 'אוזניות זהב',
        descEn: 'Premium wireless headphones with noise cancelling.',
        descAr: 'سماعات لاسلكية فاخرة مع عزل ضوضاء.',
        descHe: 'אוזניות אלחוטיות יוקרתיות עם ביטול רעשים.',
        price: 320.0,
        category: ProductCategory.electronics,
        status: ProductStatus.available,
        colorName: 'Gold',
        imageUrl:
            'https://images.pexels.com/photos/3394664/pexels-photo-3394664.jpeg?auto=compress&cs=tinysrgb&w=800',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Product(
        id: 2,
        titleEn: 'Beige Sofa',
        titleAr: 'كنبة بيج',
        titleHe: 'ספה בצבע בז׳',
        descEn: 'Modern beige sofa, perfect for living rooms.',
        descAr: 'كنبة مودرن بيج مناسبة لغرفة المعيشة.',
        descHe: 'ספה מודרנית בצבע בז׳ לסלון.',
        price: 870.0,
        category: ProductCategory.home,
        status: ProductStatus.reserved,
        colorName: 'Beige',
        imageUrl:
            'https://images.pexels.com/photos/1571453/pexels-photo-1571453.jpeg?auto=compress&cs=tinysrgb&w=800',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Product(
        id: 3,
        titleEn: 'Smart Watch',
        titleAr: 'ساعة ذكية',
        titleHe: 'שעון חכם',
        descEn: 'Minimal gold smart watch with health tracking.',
        descAr: 'ساعة ذكية ذهبية بتصميم بسيط مع تتبع صحي.',
        descHe: 'שעון חכם זהוב עם מעקב בריאות.',
        price: 450.0,
        category: ProductCategory.electronics,
        status: ProductStatus.available,
        colorName: 'Champagne',
        imageUrl:
            'https://images.pexels.com/photos/2773940/pexels-photo-2773940.jpeg?auto=compress&cs=tinysrgb&w=800',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Product(
        id: 4,
        titleEn: 'Luxury Perfume',
        titleAr: 'عطر فاخر',
        titleHe: 'בושם יוקרתי',
        descEn: 'Soft oriental fragrance for special evenings.',
        descAr: 'عطر شرقي ناعم للأمسيات الخاصة.',
        descHe: 'בושם אוריינטלי רך לערבים מיוחדים.',
        price: 230.0,
        category: ProductCategory.beauty,
        status: ProductStatus.sold,
        colorName: 'Amber',
        imageUrl:
            'https://images.pexels.com/photos/965989/pexels-photo-965989.jpeg?auto=compress&cs=tinysrgb&w=800',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Product(
        id: 5,
        titleEn: 'Silk Beige Scarf',
        titleAr: 'شال حرير بيج',
        titleHe: 'צעיף משי בצבע בז׳',
        descEn: 'Silky smooth scarf with warm tones.',
        descAr: 'شال حريري ناعم بألوان دافئة.',
        descHe: 'צעיף משי רך בגוונים חמים.',
        price: 95.0,
        category: ProductCategory.fashion,
        status: ProductStatus.available,
        colorName: 'Cream',
        imageUrl:
            'https://images.pexels.com/photos/3738084/pexels-photo-3738084.jpeg?auto=compress&cs=tinysrgb&w=800',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Product(
        id: 6,
        titleEn: 'Wooden Toy Set',
        titleAr: 'مجموعة ألعاب خشبية',
        titleHe: 'סט צעצועי עץ',
        descEn: 'Natural wooden toys for kids.',
        descAr: 'ألعاب خشبية طبيعية للأطفال.',
        descHe: 'צעצועי עץ טבעיים לילדים.',
        price: 60.0,
        category: ProductCategory.toys,
        status: ProductStatus.available,
        colorName: 'Natural Wood',
        imageUrl:
            'https://images.pexels.com/photos/3662667/pexels-photo-3662667.jpeg?auto=compress&cs=tinysrgb&w=800',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  // ----------------------------- Helpers -----------------------------

  List<Product> getFilteredProducts() {
    final now = DateTime.now();

    return allProducts.where((p) {
      if (maxPrice != null && p.price > maxPrice!) return false;
      if (selectedCategory != null && p.category != selectedCategory) {
        return false;
      }
      if (selectedStatus != null && p.status != selectedStatus) {
        return false;
      }
      if (selectedColorName != null &&
          selectedColorName!.isNotEmpty &&
          p.colorName != selectedColorName) {
        return false;
      }

      if (selectedDateFilterIndex != null) {
        final diff = now.difference(p.createdAt).inDays;
        switch (selectedDateFilterIndex) {
          case 0: // اليوم
            if (diff > 0) return false;
            break;
          case 1: // آخر 7 أيام
            if (diff > 7) return false;
            break;
          case 2: // آخر 30
            if (diff > 30) return false;
            break;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final t = AppLocalizations(locale);
    final isRtl = ['ar', 'he'].contains(locale.languageCode);

    final products = getFilteredProducts();

    return Column(
      crossAxisAlignment:
          isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // -------------------- العنوان --------------------
        Text(
          t.t("products"),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A3F35),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          locale.languageCode == 'ar'
              ? "إدارة المنتجات، الفلاتر السحرية، و Beauty Mode ✨"
              : locale.languageCode == 'he'
                  ? "ניהול מוצרים, Magic Filters ו- Beauty Mode ✨"
                  : "Manage products, Magic Filters and Beauty Mode ✨",
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8B7E70),
          ),
        ),

        const SizedBox(height: 24),

        // -------------------- شريط الفلاتر (Magic Filters) --------------------
        _buildMagicFiltersBar(locale, isRtl),

        const SizedBox(height: 24),

        // -------------------- الشبكة + جدول (mix grid / table) --------------------
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showGrid = constraints.maxWidth > 1000;

              if (products.isEmpty) {
                return Center(
                  child: Text(
                    locale.languageCode == 'ar'
                        ? "لا توجد منتجات مطابقة للفلاتر."
                        : locale.languageCode == 'he'
                            ? "אין מוצרים מתאימים למסננים."
                            : "No products match the current filters.",
                    style: const TextStyle(
                      color: Color(0xFF8B7E70),
                      fontSize: 16,
                    ),
                  ),
                );
              }

              if (showGrid) {
                // شبكة بطاقات + جدول صغير تحت
                return Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 4 / 3,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, i) {
                          return _buildProductCard(
                            context: context,
                            product: products[i],
                            locale: locale,
                            isRtl: isRtl,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 1,
                      child: _buildMiniTable(locale, products),
                    ),
                  ],
                );
              } else {
                // شاشة ضيقة → فقط List + جدول بسيط
                return Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildProductCard(
                              context: context,
                              product: products[i],
                              locale: locale,
                              isRtl: isRtl,
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildMiniTable(locale, products),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Magic Filters Bar  (فقاعات تتحرك + فلاتر حقيقية)
  // ---------------------------------------------------------------------------
  Widget _buildMagicFiltersBar(Locale locale, bool isRtl) {
    final textDir = isRtl ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDir,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.6),
          border: Border.all(color: Colors.white.withOpacity(0.9)),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment:
              isRtl ? WrapAlignment.end : WrapAlignment.start,
          children: [
            _bubbleFilter(
              label: locale.languageCode == 'ar'
                  ? "≤ 200₪"
                  : locale.languageCode == 'he'
                      ? "עד 200₪"
                      : "≤ 200₪",
              active: maxPrice == 200,
              onTap: () {
                setState(() {
                  maxPrice = maxPrice == 200 ? null : 200;
                });
              },
            ),
            _bubbleFilter(
              label: locale.languageCode == 'ar'
                  ? "≤ 500₪"
                  : locale.languageCode == 'he'
                      ? "עד 500₪"
                      : "≤ 500₪",
              active: maxPrice == 500,
              onTap: () {
                setState(() {
                  maxPrice = maxPrice == 500 ? null : 500;
                });
              },
            ),
            _bubbleFilter(
              label: _labelForCategory(locale, ProductCategory.electronics),
              active: selectedCategory == ProductCategory.electronics,
              onTap: () {
                setState(() {
                  selectedCategory =
                      selectedCategory == ProductCategory.electronics
                          ? null
                          : ProductCategory.electronics;
                });
              },
            ),
            _bubbleFilter(
              label: _labelForCategory(locale, ProductCategory.fashion),
              active: selectedCategory == ProductCategory.fashion,
              onTap: () {
                setState(() {
                  selectedCategory =
                      selectedCategory == ProductCategory.fashion
                          ? null
                          : ProductCategory.fashion;
                });
              },
            ),
            _bubbleFilter(
              label: _labelForCategory(locale, ProductCategory.beauty),
              active: selectedCategory == ProductCategory.beauty,
              onTap: () {
                setState(() {
                  selectedCategory =
                      selectedCategory == ProductCategory.beauty
                          ? null
                          : ProductCategory.beauty;
                });
              },
            ),
            _bubbleFilter(
              label: _labelForStatus(locale, ProductStatus.available),
              active: selectedStatus == ProductStatus.available,
              onTap: () {
                setState(() {
                  selectedStatus =
                      selectedStatus == ProductStatus.available
                          ? null
                          : ProductStatus.available;
                });
              },
            ),
            _bubbleFilter(
              label: _labelForStatus(locale, ProductStatus.reserved),
              active: selectedStatus == ProductStatus.reserved,
              onTap: () {
                setState(() {
                  selectedStatus =
                      selectedStatus == ProductStatus.reserved
                          ? null
                          : ProductStatus.reserved;
                });
              },
            ),
            _bubbleFilter(
              label: locale.languageCode == 'ar'
                  ? "اليوم"
                  : locale.languageCode == 'he'
                      ? "היום"
                      : "Today",
              active: selectedDateFilterIndex == 0,
              onTap: () {
                setState(() {
                  selectedDateFilterIndex =
                      selectedDateFilterIndex == 0 ? null : 0;
                });
              },
            ),
            _bubbleFilter(
              label: locale.languageCode == 'ar'
                  ? "آخر 7 أيام"
                  : locale.languageCode == 'he'
                      ? "7 ימים אחרונים"
                      : "Last 7 days",
              active: selectedDateFilterIndex == 1,
              onTap: () {
                setState(() {
                  selectedDateFilterIndex =
                      selectedDateFilterIndex == 1 ? null : 1;
                });
              },
            ),
            _bubbleFilter(
              label: locale.languageCode == 'ar'
                  ? "ألوان بيج"
                  : locale.languageCode == 'he'
                      ? "גווני בז׳"
                      : "Beige tones",
              active: selectedColorName != null,
              onTap: () {
                setState(() {
                  selectedColorName =
                      selectedColorName == null ? "Beige" : null;
                });
              },
            ),

            // زر Reset
            _bubbleFilter(
              label: locale.languageCode == 'ar'
                  ? "إعادة تعيين"
                  : locale.languageCode == 'he'
                      ? "איפוס"
                      : "Reset",
              active: false,
              onTap: () {
                setState(() {
                  maxPrice = null;
                  selectedCategory = null;
                  selectedStatus = null;
                  selectedColorName = null;
                  selectedDateFilterIndex = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _labelForCategory(Locale locale, ProductCategory c) {
    switch (c) {
      case ProductCategory.electronics:
        return locale.languageCode == 'ar'
            ? 'إلكترونيات'
            : locale.languageCode == 'he'
                ? 'אלקטרוניקה'
                : 'Electronics';
      case ProductCategory.fashion:
        return locale.languageCode == 'ar'
            ? 'أزياء'
            : locale.languageCode == 'he'
                ? 'אופנה'
                : 'Fashion';
      case ProductCategory.home:
        return locale.languageCode == 'ar'
            ? 'منزل'
            : locale.languageCode == 'he'
                ? 'בית'
                : 'Home';
      case ProductCategory.beauty:
        return locale.languageCode == 'ar'
            ? 'تجميل'
            : locale.languageCode == 'he'
                ? 'טיפוח'
                : 'Beauty';
      case ProductCategory.toys:
        return locale.languageCode == 'ar'
            ? 'ألعاب'
            : locale.languageCode == 'he'
                ? 'צעצועים'
                : 'Toys';
    }
  }

  String _labelForStatus(Locale locale, ProductStatus s) {
    switch (s) {
      case ProductStatus.available:
        return locale.languageCode == 'ar'
            ? 'متاح'
            : locale.languageCode == 'he'
                ? 'זמין'
                : 'Available';
      case ProductStatus.reserved:
        return locale.languageCode == 'ar'
            ? 'محجوز'
            : locale.languageCode == 'he'
                ? 'שמורה'
                : 'Reserved';
      case ProductStatus.sold:
        return locale.languageCode == 'ar'
            ? 'مباع'
            : locale.languageCode == 'he'
                ? 'נמכר'
                : 'Sold';
    }
  }

  Widget _bubbleFilter({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 220),
        tween: Tween(begin: 1.0, end: active ? 1.05 : 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: active
                ? const LinearGradient(
                    colors: [
                      Color(0xFFFFE5C2),
                      Color(0xFFDFC0A3),
                    ],
                  )
                : const LinearGradient(
                    colors: [
                      Color(0xFFFDF7EC),
                      Color(0xFFEDE2D3),
                    ],
                  ),
            boxShadow: [
              if (active)
                BoxShadow(
                  color: const Color(0xFF9C6F48).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.bubble_chart,
                    size: 16,
                    color: Color(0xFF6B5F46),
                  ),
                ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A3F35),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // بطاقة المنتج + Beauty Mode
  // ---------------------------------------------------------------------------
  Widget _buildProductCard({
    required BuildContext context,
    required Product product,
    required Locale locale,
    required bool isRtl,
  }) {
    final title = product.titleFor(locale);
    final desc = product.descFor(locale);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.78),
                Colors.white.withOpacity(0.92),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // صورة المنتج مع انعكاس بسيط
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: Hero(
                          tag: 'product_image_${product.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // layer خفيف لضبط الجو اللوني
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.0),
                                          Colors.white.withOpacity(0.06),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Opacity(
                        opacity: 0.45,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFFBCA894),
                                Color(0x00BCA894),
                              ],
                              radius: 1.4,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // تفاصيل المنتج
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: isRtl
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4A3F35),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8B7E70),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        alignment: isRtl
                            ? WrapAlignment.end
                            : WrapAlignment.start,
                        children: [
                          _tagChip(product.categoryLabel(locale)),
                          _tagChip(product.statusLabel(locale),
                              bg: const Color(0xFFEDE2D3)),
                          _tagChip(product.colorName,
                              bg: const Color(0xFFF7EEE3)),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        textDirection:
                            isRtl ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          Text(
                            "${product.price.toStringAsFixed(0)} ₪",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6B5F46),
                            ),
                          ),
                          const Spacer(),
                          // زر Beauty Mode
                          TextButton.icon(
                            onPressed: () {
                              _openBeautyMode(context, product, locale);
                            },
                            icon: const Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: Color(0xFF9C6F48),
                            ),
                            label: Text(
                              locale.languageCode == 'ar'
                                  ? "Beauty Mode"
                                  : locale.languageCode == 'he'
                                      ? "מצב יופי"
                                      : "Beauty Mode",
                              style: const TextStyle(
                                color: Color(0xFF9C6F48),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tagChip(String text, {Color bg = const Color(0xFFF3E8DD)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF4A3F35),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Beauty Mode Bottom Sheet
  // ---------------------------------------------------------------------------
  void _openBeautyMode(BuildContext context, Product product, Locale locale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _BeautyModeSheet(product: product, locale: locale);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // جدول صغير تحت الشبكة
  // ---------------------------------------------------------------------------
  Widget _buildMiniTable(Locale locale, List<Product> products) {
    final isRtl = ['ar', 'he'].contains(locale.languageCode);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              locale.languageCode == 'ar'
                  ? "جدول سريع"
                  : locale.languageCode == 'he'
                      ? "טבלה מהירה"
                      : "Quick table",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF4A3F35),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.brown.withOpacity(0.1)),
                itemBuilder: (context, i) {
                  final p = products[i];
                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          p.titleFor(locale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A3F35),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "${p.price.toStringAsFixed(0)} ₪",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B7E70),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          p.statusLabel(locale),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8B7E70),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ Beauty Mode Sheet ============================

class _BeautyModeSheet extends StatefulWidget {
  final Product product;
  final Locale locale;

  const _BeautyModeSheet({
    required this.product,
    required this.locale,
  });

  @override
  State<_BeautyModeSheet> createState() => _BeautyModeSheetState();
}

class _BeautyModeSheetState extends State<_BeautyModeSheet> {
  double _softGlow = 0.4; // 0 .. 1
  double _warmth = 0.2; // -1 .. 1

  @override
  Widget build(BuildContext context) {
    final isRtl = ['ar', 'he'].contains(widget.locale.languageCode);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.9,
        builder: (context, controller) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(26),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.white.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ListView(
                  controller: controller,
                  children: [
                    Center(
                      child: Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.brown.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            color: Colors.amber.shade700, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          widget.locale.languageCode == 'ar'
                              ? "وضع التجميل للمنتج"
                              : widget.locale.languageCode == 'he'
                                  ? "מצב יופי למוצר"
                                  : "Beauty mode for product",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A3F35),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.product.titleFor(widget.locale),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8B7E70),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              widget.product.imageUrl,
                              fit: BoxFit.cover,
                            ),
                            // layer للدفء
                            Container(
                              color: _warmthColor().withOpacity(0.18),
                            ),
                            // layer للسوفت جلو
                            IgnorePointer(
                              ignoring: true,
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10 * _softGlow,
                                  sigmaY: 10 * _softGlow,
                                ),
                                child: Container(
                                  color: Colors.white
                                      .withOpacity(0.1 * _softGlow),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _sliderSection(
                      titleAr: "نعومة وإضاءة",
                      titleHe: "רכות והארה",
                      titleEn: "Soft glow",
                      value: _softGlow,
                      onChanged: (v) => setState(() => _softGlow = v),
                    ),
                    const SizedBox(height: 12),
                    _sliderSection(
                      titleAr: "دفء الألوان",
                      titleHe: "חום הצבעים",
                      titleEn: "Color warmth",
                      min: -1,
                      max: 1,
                      value: _warmth,
                      onChanged: (v) => setState(() => _warmth = v),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment:
                          isRtl ? Alignment.centerLeft : Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B5F46),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        icon: const Icon(Icons.check),
                        label: Text(
                          widget.locale.languageCode == 'ar'
                              ? "اعتماد الشكل"
                              : widget.locale.languageCode == 'he'
                                  ? "אישור המראה"
                                  : "Apply look",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _warmthColor() {
    // -1 → أزرق بسيط / +1 → ذهبي دافئ
    if (_warmth >= 0) {
      return const Color(0xFFFFE0B2)
          .withOpacity(min(1.0, 0.2 + _warmth * 0.8));
    } else {
      return const Color(0xFFB3E5FC)
          .withOpacity(min(1.0, 0.2 + (-_warmth) * 0.8));
    }
  }

  Widget _sliderSection({
    required String titleAr,
    required String titleHe,
    required String titleEn,
    double min = 0,
    double max = 1,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final locale = widget.locale;
    String title;
    if (locale.languageCode == 'ar') {
      title = titleAr;
    } else if (locale.languageCode == 'he') {
      title = titleHe;
    } else {
      title = titleEn;
    }

    return Column(
      crossAxisAlignment: ['ar', 'he'].contains(locale.languageCode)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4A3F35),
            fontWeight: FontWeight.w600,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: const Color(0xFF9C6F48),
          inactiveColor: const Color(0xFFE0D1C2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
