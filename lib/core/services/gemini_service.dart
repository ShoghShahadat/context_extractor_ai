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
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: forJson ? "application/json" : "text/plain",
        temperature: 0.1,
      ),
    );
  }

  /// تحلیل عمیق کل سورس کد برای یافتن فایل‌های مرتبط
  Future<List<String>> findRelevantFiles({
    required String fullProjectContent,
    required String userFocus,
  }) async {
    try {
      final model = _getModel(forJson: true);
      final prompt =
          _buildFullSourceFileFinderPrompt(fullProjectContent, userFocus);
      final content = [Content.text(prompt)];

      debugPrint(
          "Sending FULL SOURCE prompt to Gemini for deep file analysis...");
      final response = await model.generateContent(content);

      if (response.text != null) {
        debugPrint("Received relevant file list from Gemini: ${response.text}");

        // <<< اصلاح کلیدی: پاکسازی رشته JSON قبل از پارس کردن >>>
        // این کار با جایگزین کردن بک‌اسلش‌های تکی با دوتایی، از خطای فرمت جلوگیری می‌کند.
        final sanitizedJsonString = response.text!.replaceAll(r'\', r'\\');
        final decodedJson = json.decode(sanitizedJsonString);

        if (decodedJson is Map<String, dynamic> &&
            decodedJson.containsKey('relevant_files') &&
            decodedJson['relevant_files'] is List) {
          return List<String>.from(decodedJson['relevant_files']);
        } else {
          throw Exception(
              "پاسخ هوش مصنوعی ساختار مورد انتظار (لیست فایل‌ها) را نداشت.");
        }
      } else {
        throw Exception("هوش مصنوعی جمنای یک پاسخ خالی برگرداند.");
      }
    } catch (e) {
      if (e is GenerativeAIException && e.toString().contains('503')) {
        throw Exception(
            "خطای موقت از سرویس AI: سرورها مشغول هستند. لطفاً چند لحظه بعد دوباره تلاش کنید.");
      }
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
    required String fullProjectContent,
  }) async {
    try {
      final model = _getModel(forJson: false);
      final prompt = _buildHeaderPromptV2(
        directoryTree: directoryTree,
        userGoal: userGoal,
        pubspecContent: pubspecContent,
        aiSuggestedFiles: aiSuggestedFiles,
        finalSelectedFiles: finalSelectedFiles,
        fullProjectContent: fullProjectContent,
      );
      final content = [Content.text(prompt)];

      debugPrint(
          "Sending V4.0 (Full Context) prompt to Gemini for AI header generation...");
      final response = await model.generateContent(content);
      debugPrint("Received V4.0 detailed AI header from Gemini.");

      return response.text ?? '# خطا: امکان تولید هدر AI وجود نداشت.\n';
    } catch (e) {
      if (e is GenerativeAIException && e.toString().contains('503')) {
        return '# خطا: سرور AI مشغول است. لطفاً چند لحظه بعد دوباره تلاش کنید.';
      }
      debugPrint("Error generating V4.0 AI header: $e");
      return '# خطا: یک استثنا در هنگام تولید هدر AI رخ داد: $e\n';
    }
  }

  /// پرامپت تحلیل کل سورس کد برای یافتن فایل‌ها
  String _buildFullSourceFileFinderPrompt(
      String fullProjectContent, String userFocus) {
    return """
    You are a world-class Senior Software Architect with exceptional code analysis capabilities. Your task is to act as an intelligent file finder for a developer.
    The developer has provided you with the ENTIRE source code of their project, formatted as a series of file blocks, along with their current task description.

    Your mission is to identify ALL files that are TRULY relevant to the user's focus by performing a deep analysis of the actual code, not just file names.

    **Analysis Rules:**
    1.  **Deeply Understand the Goal:** Analyze the user's focus: "$userFocus". What is the core intent? What functionality needs to be added, changed, or fixed?
    2.  **Analyze the Full Codebase:** Read and comprehend the provided source code in its entirety. Pay close attention to:
        * `import` and `export` statements to trace dependencies.
        * Class inheritance and implementations.
        * Function calls and method invocations between files.
        * State management logic (e.g., how GetX controllers, services, and UI are connected).
        * Data models and their usage.
        * Routing and navigation logic.
    3.  **Identify the Chain of Relevance:** Based on your code analysis, find the complete chain of relevant files. Start from the most obvious files (like a screen) and trace all its dependencies—controllers, services, models, bindings, utility functions, etc.
    4.  **Be Comprehensive and Accurate:** It is critical to include every file in the logical chain. It's better to include a file that might be slightly related than to miss a critical dependency. Your analysis must be based on the code's content, not just its path or name.
    5.  **Output Format:** Your output MUST be a valid JSON object with a single key "relevant_files", which is an array of strings. Each string must be a full path from the project root as it appears in the `مسیر فایل:` markers. Do not include any other text, explanations, or markdown.

    **User's Current Focus:** "$userFocus"

    **Full Project Source Code:**
    ```
    $fullProjectContent
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

    Now, perform a deep analysis of the provided source code and user focus, and generate the JSON output of all relevant file paths.
    """;
  }

  /// پرامپت تولید هدر با تحلیل کل سورس کد
  String _buildHeaderPromptV2({
    required String directoryTree,
    required String userGoal,
    required String pubspecContent,
    required List<String> aiSuggestedFiles,
    required List<String> finalSelectedFiles,
    required String fullProjectContent,
  }) {
    final finalFilesString = finalSelectedFiles.map((f) => '- $f').join('\n');

    return """
    You are a Senior AI Architect. Your task is to generate a comprehensive context document for another AI assistant.
    This document must provide a deep and insightful overview of the user's project and their goal, based on the FULL source code provided.

    **Your Instructions:**
    1.  **Analyze Everything:** You have access to the user's goal, the final list of files they've selected for the task, and the ENTIRE project's source code.
    2.  **Synthesize, Don't Just List:** Do not just repeat the data. Your primary value is to synthesize this information into a coherent, intelligent analysis.
    3.  **Explain the "Why":** Based on your analysis of the full code, explain *why* the user's goal is relevant to the project and *why* the selected files are the correct ones for the job. What is the overall architecture? How do these selected files fit into it?
    4.  **Provide a High-Level Summary:** Give a brief overview of what the project does.
    5.  **Structure the Output:** Fill in the template below with your analysis. Be clear, concise, and professional. The final output should ONLY be the completed markdown template.

    **User's Goal:**
    "$userGoal"

    **Final List of Files for the Task:**
    ```
    $finalFilesString
    ```

    **Full Project Source Code (for your analysis):**
    ```
    $fullProjectContent
    ```

    **================ TEMPLATE TO COMPLETE ================**
    # AI CONTEXT DOCUMENT - V4.0 - DEEP ANALYSIS
    ############################################################

    ### SECTION 1: PROJECT OVERVIEW
    # [**Your high-level summary of the project's purpose and architecture based on the full code analysis goes here.**]
    # Example: This Flutter project is a utility tool for developers using the GetX framework. It analyzes a project's codebase, uses a generative AI to find relevant files for a task, and then compiles them into a single context file.

    ### SECTION 2: USER'S MISSION & STRATEGY
    # The user's immediate objective is:
    # "$userGoal"
    #
    # [**Your analysis of how this goal fits into the project goes here.**]
    # Example: To achieve this, the user needs to modify the authentication flow. The selected files represent the complete chain of logic for this feature, from the UI (login_screen.dart) to the business logic (auth_controller.dart) and the backend communication (api_service.dart).

    ### SECTION 3: FINAL AND DEFINITIVE FILE MANIFEST
    # The following files, and ONLY these files, have been selected for the task. This is the single source of truth for the next AI.
    #
    # Final User-Selected Files:
    # $finalFilesString

    ### SECTION 4: PROJECT DEPENDENCIES
    # For complete dependency awareness, the project's `pubspec.yaml` is:
    # ```yaml
    # $pubspecContent
    # ```

    ### SECTION 5: FINAL INSTRUCTIONS
    # Your task is to fulfill the user's goal: "$userGoal".
    # Base your entire analysis, response, and code generation *only* on the files provided in the final manifest (Section 3). The overview in Section 1 and 2 is for your understanding.

    ############################################################
    # END OF AI CONTEXT DOCUMENT
    ############################################################
    """;
  }
}
