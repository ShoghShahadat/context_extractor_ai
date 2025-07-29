import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class GeminiService {
  final List<String> _apiKeys = [
    "AIzaSyBwXo5GlQbgS6cUWd53yDcg1wFjE8bNg0o",
    "AIzaSyBtFUS6aAbg0yrP26EUUpq3e-LOEnE8nbc",
    "AIzaSyDl3q_1XE-Z5tcqUwohRwDT4O8Fqil08YM",
    "AIzaSyB_1KD_P5TIRhupFRdgM0gW-zbFu_9zHzo",
    "AIzaSyDy3883QLDktFvIBBG3t3HGsnV8tmSQmY4",
    "AIzaSyB3JrrU_EuljbkeSmvZmf9ui0cLg1FCOFQ",
    "AIzaSyBmWBm6brVvDvFELtMtlgbmbO2dtM9it1g",
    "AIzaSyBj_hHcr4DBRJC9I5qAaeDMnvlWymu_k6c",
    "AIzaSyDAXiL6g-_JmWH9R27rnz59mibeEO1DVaY",
    "AIzaSyAnVGp0EXkdtBTX8BpbVFuQ2krIl74fyR8",
    "AIzaSyDn8U_agAOIQ8oQUgsdHnQzYiHzx0WQUJY",
    "AIzaSyBwgzmLb1yHBkILyrBmvGX0DrUPCKqHBXM",
  ];

  int _currentKeyIndex = 0;

  GeminiService() {
    if (_apiKeys.isNotEmpty) {
      debugPrint(
          '✅ ${_apiKeys.length} API keys loaded successfully from code.');
    } else {
      debugPrint("❌ FATAL: No Gemini API keys found in the hardcoded list.");
    }
  }

  GenerativeModel _getModel() {
    if (_apiKeys.isEmpty) throw Exception("هیچ کلید API برای جمنای یافت نشد.");
    final currentKey = _apiKeys[_currentKeyIndex];
    return GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: currentKey,
      generationConfig: GenerationConfig(
        responseMimeType: "application/json",
        temperature: 0.1,
      ),
    );
  }

  GenerativeModel _getTextModel() {
    if (_apiKeys.isEmpty) throw Exception("هیچ کلید API برای جمنای یافت نشد.");
    final currentKey = _apiKeys[_currentKeyIndex];
    return GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: currentKey,
      generationConfig: GenerationConfig(
        responseMimeType: "text/plain",
        temperature: 0.1,
      ),
    );
  }

  void _moveToNextKey() {
    if (_apiKeys.isNotEmpty) {
      _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    }
  }

  Future<String> _generateWithRetry(String prompt,
      {bool forJson = true}) async {
    if (_apiKeys.isEmpty) {
      throw Exception("هیچ کلید API برای استفاده وجود ندارد.");
    }

    for (int i = 0; i < _apiKeys.length; i++) {
      final keyToTryIndex = _currentKeyIndex;
      try {
        debugPrint(
            "Attempt #${i + 1}/${_apiKeys.length}: Using API key at index $keyToTryIndex.");

        final model = forJson ? _getModel() : _getTextModel();
        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);

        if (response.text == null) {
          throw Exception("پاسخ خالی از AI دریافت شد.");
        }

        debugPrint(
            "✅ Request successful with API key at index: $keyToTryIndex");
        return response.text!;
      } on GenerativeAIException catch (e) {
        // <<< اصلاح کلیدی: افزودن خطای 503 (سرور مشغول) به لیست خطاهای قابل تکرار >>>
        if (e.message.contains('API key not valid') ||
            e.message.contains('quota') ||
            e.message.contains('503')) {
          debugPrint(
              "❌ API key at index $keyToTryIndex failed (Retriable Error): ${e.message}");
          _moveToNextKey(); // رفتن به کلید بعدی
          continue; // ادامه حلقه برای تلاش مجدد
        } else {
          debugPrint("A non-retriable error occurred: ${e.message}");
          throw Exception("خطای غیرقابل تکرار از سرویس AI: ${e.message}");
        }
      } catch (e) {
        debugPrint("An unexpected error occurred: $e");
        rethrow;
      }
    }

    throw Exception("تمام کلیدهای API به دلیل محدودیت یا خطا ناموفق بودند.");
  }

  Future<List<String>> findRelevantFiles({
    required String fullProjectContent,
    required String userFocus,
  }) async {
    final prompt =
        _buildFullSourceFileFinderPrompt(fullProjectContent, userFocus);
    final responseText = await _generateWithRetry(prompt, forJson: true);

    final sanitizedJsonString = responseText.replaceAll(r'\', r'\\');
    final decodedJson = json.decode(sanitizedJsonString);

    if (decodedJson is Map<String, dynamic> &&
        decodedJson.containsKey('relevant_files') &&
        decodedJson['relevant_files'] is List) {
      return List<String>.from(decodedJson['relevant_files']);
    } else {
      throw Exception(
          "پاسخ هوش مصنوعی ساختار مورد انتظار (لیست فایل‌ها) را نداشت.");
    }
  }

  Future<String> generateAiHeader({
    required String directoryTree,
    required String userGoal,
    required String pubspecContent,
    required List<String> aiSuggestedFiles,
    required List<String> finalSelectedFiles,
    required String fullProjectContent,
  }) async {
    final prompt = _buildHeaderPromptV2(
      directoryTree: directoryTree,
      userGoal: userGoal,
      pubspecContent: pubspecContent,
      aiSuggestedFiles: aiSuggestedFiles,
      finalSelectedFiles: finalSelectedFiles,
      fullProjectContent: fullProjectContent,
    );
    return _generateWithRetry(prompt, forJson: false);
  }

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
