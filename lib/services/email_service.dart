import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // من EmailJS
  static const String serviceId = 'service_5u0ykof';
  static const String templateId = 'template_6scg8ov'; // أو dvgap49 إذا هذا اللي عندك
  static const String publicKey = 'oBcFdW8yBphAyH_js';

  static Future<bool> sendEmail({
    required String toEmail,
    required String name,
    required String language,
  }) async {
    String subject;
    String message;

    switch (language) {
      case "ar":
        subject = "مرحبا بك في منصتنا يا $name";
        message = "شكراً لتسجيلك يا $name! تم إنشاء حسابك بنجاح 🌸";
        break;

      case "he":
        subject = "ברוך הבא, $name!";
        message = "תודה שנרשמת $name! החשבון שלך נוצר בהצלחה 😊";
        break;

      default:
        subject = "Welcome, $name!";
        message =
            "Thank you for signing up, $name! Your account has been created 🎉";
        break;
    }

    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    final response = await http.post(
      url,
      headers: {
        "origin": "http://localhost",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "service_id": serviceId,
        "template_id": templateId,
        "user_id": publicKey,
        "template_params": {
          "to_email": toEmail, // لازم نفس الاسم اللي في التيمبليت {{to_email}}
          "name": name,        // عشان {{name}} في التيمبليت
          "subject": subject,  // عشان {{subject}}
          "message": message,  // عشان {{message}}
        }
      }),
    );

    print("EMAILJS STATUS: ${response.statusCode}");
    print("EMAILJS BODY: ${response.body}");

    return response.statusCode == 200;
  }
}
