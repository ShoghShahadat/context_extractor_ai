import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../models/project_analysis.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception("GEMINI_API_KEY not found in .env file");
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: "application/json",
        temperature: 0.2, // خلاقیت کمتر برای دقت بیشتر
      ),
    );
  }

  /// تحلیل ساختار پروژه و استخراج صفحات و فایل‌های مرتبط با استفاده از Gemini.
  Future<List<ProjectScreen>> analyzeProjectStructure(
      String directoryTree, String pubspecContent) async {
    try {
      final prompt = _buildPrompt(directoryTree, pubspecContent);
      final content = [Content.text(prompt)];

      debugPrint("Sending prompt to Gemini...");
      final response = await _model.generateContent(content);

      if (response.text != null) {
        debugPrint("Received response from Gemini.");
        //解析 کردن پاسخ JSON و تبدیل آن به لیست مدل‌های ProjectScreen
        final decodedJson = json.decode(response.text!);
        final List<dynamic> screensJson = decodedJson['screens'];
        return screensJson.map((json) => ProjectScreen.fromJson(json)).toList();
      } else {
        throw Exception("Gemini returned an empty response.");
      }
    } catch (e) {
      debugPrint("Error analyzing project with Gemini: $e");
      // در صورت بروز خطا، یک لیست خالی برمی‌گردانیم تا برنامه متوقف نشود
      return [];
    }
  }

  /// متد خصوصی برای ساخت پرامپت مهندسی شده.
  String _buildPrompt(String directoryTree, String pubspecContent) {
    return """
    You are an expert Flutter developer and code architect. Your task is to analyze the provided Flutter project structure and identify all the main screens and their related files.

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
            "lib/core/bindings/auth_binding.dart",
            "lib/core/model/user.dart"
          ]
        }
      ]
    }
    ```

    Now, analyze the provided project structure and generate the JSON output.
    """;
  }
}
