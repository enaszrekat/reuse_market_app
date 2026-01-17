import 'package:flutter/material.dart';

// استيراد الصفحات
import 'sell_product_page.dart';
import 'trade_product_page.dart';
import 'donate_item_page.dart';

class AddProductSheet extends StatelessWidget {
  const AddProductSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // الخط الصغير فوق
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const Text(
            "Add Product",
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          _item(
            context,
            icon: Icons.sell,
            title: "Sell Product",
            page: const SellProductPage(),
          ),

          const SizedBox(height: 16),

          _item(
            context,
            icon: Icons.sync_alt,
            title: "Trade Product",
            page: const TradeProductPage(),
          ),

          const SizedBox(height: 16),

          _item(
            context,
            icon: Icons.volunteer_activism,
            title: "Donate Product",
            page: const DonateItemPage(),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // إغلاق الـ BottomSheet

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.greenAccent.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.greenAccent, size: 28),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
