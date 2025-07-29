import 'package:get/get.dart';

/// مدلی برای نگهداری اطلاعات تحلیل شده یک صفحه از پروژه.
class ProjectScreen {
  final String screenName;
  final List<String> relatedFiles;
  final String explanation;
  final RxBool isSelected;
  final RxBool isExpanded = false.obs; // <<< جدید: برای مدیریت باز/بسته بودن

  ProjectScreen({
    required this.screenName,
    required this.relatedFiles,
    required this.explanation,
  }) : isSelected = false.obs;

  /// یک factory constructor برای ساخت نمونه از JSON.
  factory ProjectScreen.fromJson(Map<String, dynamic> json) {
    final files = (json['related_files'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        [];

    return ProjectScreen(
      screenName: json['screen_name'] as String? ?? 'Unknown Screen',
      relatedFiles: files,
      explanation:
          json['explanation'] as String? ?? 'توضیحی توسط هوش مصنوعی ارائه نشد.',
    );
  }

  /// یک نام خوانا برای نمایش در UI برمی‌گرداند.
  String get displayName {
    try {
      return screenName
              .split('/')
              .last
              .replaceAll('_screen.dart', '')
              .replaceAll(r'\', '/') // اطمینان از اسلش یکسان
              .split('/')
              .last
              .replaceAll('_', ' ')
              .capitalizeFirst ??
          screenName;
    } catch (e) {
      return screenName;
    }
  }
}
