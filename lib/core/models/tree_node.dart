import 'package:get/get.dart';

/// یک مدل داده سفارشی برای نمایش یک گره در درختواره فایل ما.
class TreeNode {
  final String key; // مسیر کامل یا یک شناسه منحصر به فرد
  final String label; // نام فایل یا پوشه برای نمایش
  final String path; // مسیر کامل فایل (برای فایل‌ها)
  final List<TreeNode> children;

  // <<< اصلاح کلیدی: تبدیل وضعیت باز/بسته بودن به یک متغیر واکنشی >>>
  final RxBool isExpanded;

  final bool isFile;

  TreeNode({
    required this.key,
    required this.label,
    required this.path,
    this.children = const [],
    bool initialExpansionState = false, // مقدار اولیه
    this.isFile = false,
  }) : isExpanded = initialExpansionState.obs; // مقداردهی اولیه RxBool
}
