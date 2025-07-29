/// یک مدل داده سفارشی برای نمایش یک گره در درختواره فایل ما.
/// این کلاس جایگزین کلاس Node از پکیج حذف شده می‌شود.
class TreeNode {
  final String key; // مسیر کامل یا یک شناسه منحصر به فرد
  final String label; // نام فایل یا پوشه برای نمایش
  final String path; // مسیر کامل فایل (برای فایل‌ها)
  final List<TreeNode> children;
  bool isExpanded;
  final bool isFile;

  TreeNode({
    required this.key,
    required this.label,
    required this.path,
    this.children = const [],
    this.isExpanded = false,
    this.isFile = false,
  });
}
