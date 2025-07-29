import 'package:get/get.dart';

/// مدلی برای نگهداری اطلاعات تحلیل شده یک صفحه از پروژه.
class ProjectScreen {
  final String screenName;
  final List<String> relatedFiles;
  final RxBool isSelected; // برای استفاده در UI و مدیریت انتخاب کاربر

  ProjectScreen({
    required this.screenName,
    required this.relatedFiles,
  }) : isSelected = false.obs;

  /// یک factory constructor برای ساخت نمونه از JSON.
  factory ProjectScreen.fromJson(Map<String, dynamic> json) {
    // اطمینان از اینکه related_files همیشه یک لیست از رشته‌ها است
    final files = (json['related_files'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        [];

    return ProjectScreen(
      screenName: json['screen_name'] as String? ?? 'Unknown Screen',
      relatedFiles: files,
    );
  }

  /// یک نام خوانا برای نمایش در UI برمی‌گرداند.
  String get displayName {
    try {
      // حذف پیشوند و پسوند برای خوانایی بیشتر
      return screenName
              .split('/')
              .last
              .replaceAll('_screen.dart', '')
              .replaceAll('_', ' ')
              .capitalizeFirst ??
          screenName;
    } catch (e) {
      return screenName;
    }
  }
}
