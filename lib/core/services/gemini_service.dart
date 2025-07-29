import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../models/project_analysis.dart';

class GeminiService {
  final String? _apiKey;

  GeminiService() : _apiKey = dotenv.env['GEMINI_API_KEY'];

  GenerativeModel _getModel({bool forJson = true}) {
    if (_apiKey == null) {
      throw Exception("GEMINI_API_KEY not found in .env file");
    }
    return GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey!,
      generationConfig: GenerationConfig(
        responseMimeType: forJson ? "application/json" : "text/plain",
        temperature: 0.2,
      ),
    );
  }

  /// تحلیل ساختار پروژه و استخراج صفحات و فایل‌های مرتبط.
  Future<List<ProjectScreen>> analyzeProjectStructure(
      String directoryTree, String pubspecContent) async {
    try {
      final model = _getModel(forJson: true);
      final prompt = _buildAnalysisPrompt(directoryTree, pubspecContent);
      final content = [Content.text(prompt)];

      debugPrint("Sending smart prompt to Gemini for analysis...");
      final response = await model.generateContent(content);

      if (response.text != null) {
        debugPrint(
            "Received smart analysis from Gemini. Response text: ${response.text}");
        final decodedJson = json.decode(response.text!);

        // <<< اصلاح کلیدی: بررسی دقیق و مقاوم پاسخ JSON >>>
        if (decodedJson is Map<String, dynamic> &&
            decodedJson.containsKey('screens') &&
            decodedJson['screens'] is List) {
          final List<dynamic> screensJson = decodedJson['screens'];
          return screensJson
              .map((json) => ProjectScreen.fromJson(json))
              .toList();
        } else {
          // اگر پاسخ ساختار مورد انتظار را نداشت
          throw Exception(
              "پاسخ هوش مصنوعی ساختار مورد انتظار (لیست صفحات) را نداشت. لطفاً پرامپت یا ورودی را بررسی کنید.");
        }
      } else {
        throw Exception("هوش مصنوعی جمنای یک پاسخ خالی برگرداند.");
      }
    } catch (e) {
      debugPrint("Error analyzing project with Gemini: $e");
      // ارسال مجدد خطا برای نمایش به کاربر
      rethrow;
    }
  }

  /// <<< قابلیت جدید: تولید مقدمه هوشمند برای هوش مصنوعی بعدی >>>
  Future<String> generateAiHeader(
      List<ProjectScreen> selectedScreens, String directoryTree) async {
    try {
      final model = _getModel(forJson: false); // درخواست خروجی متنی
      final prompt = _buildHeaderPrompt(selectedScreens, directoryTree);
      final content = [Content.text(prompt)];

      debugPrint("Sending prompt to Gemini for AI header generation...");
      final response = await model.generateContent(content);
      debugPrint("Received AI header from Gemini.");

      return response.text ?? '# Error: Could not generate AI header.\n';
    } catch (e) {
      debugPrint("Error generating AI header: $e");
      return '# Error: An exception occurred while generating the AI header.\n';
    }
  }

  String _buildAnalysisPrompt(String directoryTree, String pubspecContent) {
    return """
    You are an expert Flutter developer and code architect. Your task is to analyze the provided Flutter project structure and identify all the main screens and their related files.
    For each screen, you MUST provide a brief explanation in PERSIAN about why you grouped those files together.

    **Analysis Rules:**
    1.  A "Screen" is a Dart file located in the `lib/presentation/screens/` directory.
    2.  "Related Files" for a screen include:
        * Its specific controller(s) from the `lib/controllers/` directory.
        * Its specific binding(s) from the `lib/core/bindings/` directory.
        * Any custom widgets from `lib/presentation/widgets/` that are likely used by this screen (based on naming conventions).
        * Related models from `lib/core/model/` that are likely used by this screen.
        * Related services or repositories from `lib/api/` or `lib/core/services/` that the controller might use.
    3.  Analyze the file names and paths to infer relationships. For example, `login_screen.dart` is related to `login_controller.dart`.
    4.  The output MUST be a valid JSON object. Do not include any text or markdown before or after the JSON object.
    5.  The "explanation" field MUST be in Persian.

    **Project Structure:**
    ```
    $directoryTree
    ```

    **Pubspec Content:**
    ```yaml
    $pubspecContent
    ```

    **Required JSON Output Format:**
    Provide a JSON object with a single key "screens", which is an array of objects. Each object must have two keys: "screen_name" and "related_files".

    **Example JSON Object:**
    ```json
    {
      "screens": [
        {
          "screen_name": "lib/presentation/screens/auth/login_screen.dart",
          "related_files": [
            "lib/controllers/auth/login_controller.dart",
            "lib/controllers/auth/auth_controller.dart",
            "lib/core/bindings/auth_binding.dart"
          ],
          "explanation": "این فایل‌ها به صفحه ورود مرتبط هستند. کنترلر ورود منطق را مدیریت کرده و با سرویس احراز هویت در ارتباط است."
        }
      ]
    }
    ```

    Now, analyze the provided project structure and generate the JSON output.
    """;
  }
}

/// <<< پرامپت جدید و مهندسی شده برای تولید مقدمه >>>
String _buildHeaderPrompt(
    List<ProjectScreen> selectedScreens, String directoryTree) {
  final screenPaths = selectedScreens
      .map((s) => '# - ${s.screenName.replaceAll(r'\', '/')}')
      .join('\n');

  return """
    You are a helpful AI assistant preparing a context file for another AI. Your task is to generate a clean, well-formatted header in English. This header should explain that the following code is a partial subset of a larger project, selected by a user for a specific task.

    **Instructions:**
    1.  Start and end with a clear delimiter: `############################################################`
    2.  Use the title `# AI CONTEXT HEADER - START` and `# AI CONTEXT HEADER - END`.
    3.  Write a friendly greeting to the other AI (e.g., "Hello AI!").
    4.  State that the file contains a partial context for specific features.
    5.  Dynamically list the screens the user selected. The selected screen paths are:
    $screenPaths
    6.  Explain that the complete directory tree is provided below for architectural understanding.
    7.  Include the full directory tree provided here, formatted with a '#' at the beginning of each line.
    Directory Tree:
    $directoryTree
    8.  End the header with a concluding remark like "Please base your analysis on the code provided below."

    Generate only the complete header text, without any other commentary or surrounding text.
    """;
}
