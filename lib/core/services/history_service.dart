import 'package:shared_preferences/shared_preferences.dart';

/// کلید برای ذخیره‌سازی لیست تاریخچه در حافظه دستگاه
const String _historyKey = 'project_history';

/// سرویسی برای مدیریت تاریخچه مسیرهای پروژه‌های انتخاب شده.
class HistoryService {
  late SharedPreferences _prefs;

  /// مقداردهی اولیه سرویس و خواندن اطلاعات از حافظه.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// دریافت لیست تاریخچه مسیرها.
  List<String> getHistory() {
    return _prefs.getStringList(_historyKey) ?? [];
  }

  /// افزودن یک مسیر جدید به تاریخچه.
  ///
  /// اگر مسیر از قبل وجود داشته باشد، آن را به ابتدای لیست منتقل می‌کند.
  Future<void> addPathToHistory(String path) async {
    final List<String> history = getHistory();
    // حذف مسیر فعلی اگر از قبل وجود دارد تا به ابتدا منتقل شود
    history.remove(path);
    // افزودن مسیر جدید به ابتدای لیست
    history.insert(0, path);
    // می‌توانید برای جلوگیری از طولانی شدن لیست، آن را محدود کنید
    // final limitedHistory = history.take(10).toList();
    await _prefs.setStringList(_historyKey, history);
  }

  /// پاک کردن کل تاریخچه.
  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }
}
