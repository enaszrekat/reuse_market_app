// lib/models/product.dart
import 'package:flutter/material.dart';

enum ProductCategory {
  electronics,
  fashion,
  home,
  beauty,
  toys,
}

enum ProductStatus {
  available,
  reserved,
  sold,
}

class Product {
  final int id;
  final String titleEn;
  final String titleAr;
  final String titleHe;

  final String descEn;
  final String descAr;
  final String descHe;

  final double price;
  final ProductCategory category;
  final ProductStatus status;
  final String colorName;
  final String imageUrl;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.titleHe,
    required this.descEn,
    required this.descAr,
    required this.descHe,
    required this.price,
    required this.category,
    required this.status,
    required this.colorName,
    required this.imageUrl,
    required this.createdAt,
  });

  // 🔤 ترجمة الاسم حسب اللغة
  String titleFor(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return titleAr;
      case 'he':
        return titleHe;
      default:
        return titleEn;
    }
  }

  // 🔤 ترجمة الوصف حسب اللغة
  String descFor(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return descAr;
      case 'he':
        return descHe;
      default:
        return descEn;
    }
  }

  // 🏷️ نص الفئة
  String categoryLabel(Locale locale) {
    switch (category) {
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

  // 🟢 نص الحالة
  String statusLabel(Locale locale) {
    switch (status) {
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
}
