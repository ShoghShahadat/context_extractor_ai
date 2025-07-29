import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class GeminiService {
  final String? _apiKey;

  GeminiService() : _apiKey = dotenv.env['GEMINI_API_KEY'];

  GenerativeModel _getModel({bool forJson = true}) {
    if (_apiKey == null) {
      throw Exception("GEMINI_API_KEY not found in .env file");
    }
    return GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey!,
      generationConfig: GenerationConfig(
        responseMimeType: forJson ? "application/json" : "text/plain",
        temperature: 0.1, // کاهش دما برای پاسخ قطعی‌تر در تحلیل فایل
      ),
    );
  }

  /// <<< قابلیت جدید و کلیدی: تحلیل هوشمند برای یافتن فایل‌های مرتبط >>>
  /// این متد جایگزین متد قبلی می‌شود که فقط به دنبال Screen می‌گشت.
  Future<List<String>> findRelevantFiles({
    required String directoryTree,
    required String userFocus,
  }) async {
    try {
      final model = _getModel(forJson: true);
      final prompt = _buildFileFinderPrompt(directoryTree, userFocus);
      final content = [Content.text(prompt)];

      debugPrint(
          "Sending architecture-agnostic prompt to Gemini for file finding...");
      final response = await model.generateContent(content);

      if (response.text != null) {
        debugPrint("Received relevant file list from Gemini: ${response.text}");
        final decodedJson = json.decode(response.text!);

        if (decodedJson is Map<String, dynamic> &&
            decodedJson.containsKey('relevant_files') &&
            decodedJson['relevant_files'] is List) {
          // تبدیل لیست dynamic به لیست String
          return List<String>.from(decodedJson['relevant_files']);
        } else {
          throw Exception(
              "پاسخ هوش مصنوعی ساختار مورد انتظار (لیست فایل‌ها) را نداشت.");
        }
      } else {
        throw Exception("هوش مصنوعی جمنای یک پاسخ خالی برگرداند.");
      }
    } catch (e) {
      debugPrint("Error finding relevant files with Gemini: $e");
      rethrow;
    }
  }

  /// تولید مقدمه هوشمند و جامع برای هوش مصنوعی بعدی
  Future<String> generateAiHeader({
    required String directoryTree,
    required String userGoal,
    required String pubspecContent,
    required List<String> aiSuggestedFiles,
    required List<String> finalSelectedFiles,
  }) async {
    try {
      final model = _getModel(forJson: false);
      final prompt = _buildHeaderPrompt(
        directoryTree: directoryTree,
        userGoal: userGoal,
        pubspecContent: pubspecContent,
        aiSuggestedFiles: aiSuggestedFiles,
        finalSelectedFiles: finalSelectedFiles,
      );
      final content = [Content.text(prompt)];

      debugPrint(
          "Sending V3.1 (Direct) prompt to Gemini for AI header generation...");
      final response = await model.generateContent(content);
      debugPrint("Received V3.1 detailed AI header from Gemini.");

      return response.text ?? '# Error: Could not generate AI header.\n';
    } catch (e) {
      debugPrint("Error generating V3.1 AI header: $e");
      return '# Error: An exception occurred while generating the AI header.\n';
    }
  }

  /// <<< پرامپت جدید: مهندسی شده برای یافتن فایل‌ها به صورت معماری-آزاد >>>
  String _buildFileFinderPrompt(String directoryTree, String userFocus) {
    return """
    You are a highly experienced Senior Software Architect and an expert in code analysis. Your task is to act as an intelligent file finder for a developer.
    The developer has provided you with their entire project's directory structure and a description of their current focus or task.
    Your mission is to identify ALL files that are relevant to the user's focus, regardless of the project's specific architecture (MVC, MVVM, Clean Architecture, feature-based, etc.).

    **Analysis Rules:**
    1.  **Understand the Goal:** Deeply analyze the user's focus: "$userFocus".
    2.  **Scan the Entire Tree:** Examine the full directory tree provided below.
    3.  **Identify Core Files:** Find the core files related to the focus. This could be UI files (screens, widgets, views), logic files (controllers, viewmodels, blocs, providers), or business logic files.
    4.  **Identify Related Dependencies:** Find all dependencies of those core files. This includes:
        * **Services:** API services, data services, etc.
        * **Models:** Data transfer objects (DTOs), domain models.
        * **Repositories:** Data access layers.
        * **Bindings/Injectors:** Dependency injection files.
        * **Routes:** Navigation and routing files.
        * **Utilities:** Helper functions or utility classes used by the core files.
    5.  **Be Comprehensive:** It is better to include a file that might be slightly related than to miss a critical one.
    6.  **Output Format:** Your output MUST be a valid JSON object with a single key "relevant_files", which is an array of strings. Each string must be a full path from the project root as it appears in the directory tree. Do not include any other text or markdown.

    **User's Current Focus:** "$userFocus"

    **Project Directory Tree:**
    ```
    $directoryTree
    ```

    **Example JSON Output:**
    ```json
    {
      "relevant_files": [
        "lib/presentation/screens/profile_screen.dart",
        "lib/presentation/controllers/profile_controller.dart",
        "lib/core/models/user_profile.dart",
        "lib/core/services/user_service.dart",
        "lib/core/bindings/profile_binding.dart"
      ]
    }
    ```

    Now, analyze the provided project structure and user focus, and generate the JSON output of all relevant file paths.
    """;
  }

  /// <<< پرامپت جدید: مهندسی شده برای تولید سند زمینه نسخه ۳.۰ >>>
  /// <<< اصلاح کامل: پرامپت مستقیم و قالب-محور برای تزریق داده‌ها >>>
  String _buildHeaderPrompt({
    required String directoryTree,
    required String userGoal,
    required String pubspecContent,
    required List<String> aiSuggestedFiles,
    required List<String> finalSelectedFiles,
  }) {
    // آماده‌سازی رشته‌ها برای تزریق در قالب
    final aiFilesString = aiSuggestedFiles.map((f) => '# - $f').join('\n');
    final finalFilesString = finalSelectedFiles.map((f) => '# - $f').join('\n');
    final indentedPubspec =
        pubspecContent.split('\n').map((line) => "#   $line").join('\n');
    final indentedTree =
        directoryTree.split('\n').map((line) => "# $line").join('\n');

    // دستورالعمل بسیار ساده و مستقیم برای هوش مصنوعی
    // به همراه یک قالب خام که فقط باید پر شود.
    return """
You are an AI assistant. Your ONLY task is to fill in the placeholders in the following template with the provided data.
Once you've completed the template, provide it along with your final analysis for the next AI to review.

Explanation:
This is part of a project that the user intends to develop. Since the project is quite extensive, the user has extracted the relevant files with the help of AI.

Your task is to provide detailed instructions for the next AI that will review these files so it won't get confused. You should also explain the parts of the project whose files have not been sent to the AI, so it doesn’t get lost.

Additionally, you need to describe the user's goal and explain why these particular files were selected. In other words, clarify the purpose of these files and why the user has chosen them for analysis.

These explanations and the completed information will be used by the final AI to help analyze the project, receive the code, and assist in its development.



**DATA TO INJECT:**
- [USER_GOAL]: $userGoal
- [PUBSPEC_CONTENT]:
$indentedPubspec
- [AI_SUGGESTED_FILES]:
$aiFilesString
- [FINAL_SELECTED_FILES]:
$finalFilesString
- [DIRECTORY_TREE]:
$indentedTree

**TEMPLATE TO COMPLETE:**
############################################################
# AI CONTEXT DOCUMENT - V3.2 - DIRECT INJECTION
############################################################

### SECTION 1: USER'S MISSION
# The user's primary goal is:
# "$userGoal"

### SECTION 2: PROJECT DEPENDENCIES
# The full content of `pubspec.yaml` is provided for dependency analysis:
#
$indentedPubspec

### SECTION 3: CONTEXT SELECTION PROCESS
# To generate this context, an AI architect first analyzed the user's goal and suggested the following files:
#
# AI-Suggested Files:
$aiFilesString
#
# The user then reviewed these suggestions and confirmed the final list of files below.

### SECTION 4: FINAL AND DEFINITIVE FILE MANIFEST
# The following files, and ONLY these files, are provided for your analysis. This is the single source of truth.
#
# Final User-Selected Files:
$finalFilesString

### SECTION 5: FULL ARCHITECTURAL BLUEPRINT
# For complete architectural awareness, the full, unfiltered directory tree of the project is provided below.
# Use this to understand the project's structure, but base your code analysis ONLY on the files listed in Section 4.
#
# Full Project Directory Tree:
$indentedTree

### SECTION 6: FINAL INSTRUCTIONS
# Your task is to fulfill the user's goal: "$userGoal".
# Base your entire analysis, response, and code generation *only* on the files provided in the final manifest (Section 4).

############################################################
# END OF AI CONTEXT DOCUMENT
############################################################
""";
  }
}
