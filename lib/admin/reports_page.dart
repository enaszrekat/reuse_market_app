import 'package:flutter/material.dart';
import '../main.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final t = AppLocalizations(locale);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment:
          isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          t.t("reports"),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A3F35),
          ),
        ),

        const SizedBox(height: 30),

        // Summary Cards
        Row(
          children: [
            reportCard(
              context,
              titleAr: "إجمالي المستخدمين",
              titleHe: "סה\"כ משתמשים",
              titleEn: "Total Users",
              value: "124",
            ),
            const SizedBox(width: 20),
            reportCard(
              context,
              titleAr: "إجمالي المنتجات",
              titleHe: "סה\"כ מוצרים",
              titleEn: "Total Products",
              value: "88",
            ),
            const SizedBox(width: 20),
            reportCard(
              context,
              titleAr: "مشاكل معلّقة",
              titleHe: "תקלות פתוחות",
              titleEn: "Pending Issues",
              value: "12",
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Fake chart bar (simple for now)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.12),
                blurRadius: 15,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                locale.languageCode == "ar"
                    ? "مخطط النشاط"
                    : locale.languageCode == "he"
                        ? "גרף פעילות"
                        : "Activity Chart",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B5F46),
                ),
              ),
              const SizedBox(height: 20),

              // Fake bar chart
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  bar(60),
                  bar(120),
                  bar(80),
                  bar(140),
                  bar(90),
                  bar(50),
                  bar(110),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget reportCard(
    BuildContext context, {
    required String titleAr,
    required String titleHe,
    required String titleEn,
    required String value,
  }) {
    final locale = Localizations.localeOf(context);

    String title;
    switch (locale.languageCode) {
      case "ar":
        title = titleAr;
        break;
      case "he":
        title = titleHe;
        break;
      default:
        title = titleEn;
    }

    return Container(
      width: 200,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3F35),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              color: Color(0xFF6B5F46),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget bar(double height) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF6B5F46),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
