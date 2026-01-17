// هذا الملف يشتغل على كل المنصات بدون كراش
import 'package:flutter/material.dart';

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> init() async {
    // لا شيء (Windows / Web)
  }
}
