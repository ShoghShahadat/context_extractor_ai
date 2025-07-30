import 'package:flutter/foundation.dart';

// یک شمارنده برای تعریف فرستنده پیام
enum MessageSender {
  user,
  ai,
}

// کلاسی برای نگهداری اطلاعات یک پیام در تاریخچه چت
class ChatMessage {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  // این فیلد برای نگهداری تحلیل و منطق انتخاب فایل‌ها توسط AI استفاده می‌شود
  final String? rationale;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
    this.rationale,
  });
}
