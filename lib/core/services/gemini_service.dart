import 'package:context_extractor_ai/core/models/chat_message.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

// <<< جدید: یک کلاس برای نگهداری پاسخ ساختاریافته از AI >>>
class AiFileSelectionResponse {
  final List<String> relevantFiles;
  final String rationale;

  AiFileSelectionResponse(
      {required this.relevantFiles, required this.rationale});

  factory AiFileSelectionResponse.fromJson(Map<String, dynamic> json) {
    return AiFileSelectionResponse(
      relevantFiles: List<String>.from(json['relevant_files'] ?? []),
      rationale: json['rationale'] as String? ?? 'تحلیلی ارائه نشد.',
    );
  }
}

class GeminiService {
  final List<String> _apiKeys = [
    "AIzaSyBwXo5GlQbgS6cUWd53yDcg1wFjE8bNg0o",
    "AIzaSyBtFUS6aAbg0yrP26EUUpq3e-LOEnE8nbc",
    "AIzaSyDl3q_1XE-Z5tcqUwohRwDT4O8Fqil08YM",
    "AIzaSyAxEwehsoZSNWKFBoU34R8bj_abr5XSAVs",
    "AIzaSyB_1KD_P5TIRhupFRdgM0gW-zbFu_9zHzo",
    "AIzaSyDy3883QLDktFvIBBG3t3HGsnV8tmSQmY4",
    "AIzaSyB3JrrU_EuljbkeSmvZmf9ui0cLg1FCOFQ",
    "AIzaSyBmWBm6brVvDvFELtMtlgbmbO2dtM9it1g",
    "AIzaSyC_YdOMeNNNsbOA9RlonOW5aKfY-zldQE4",
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
      model: 'gemini-2.0-flash',
      apiKey: currentKey,
      generationConfig: GenerationConfig(
        responseMimeType: "application/json",
        temperature: 0.2, // کمی افزایش دما برای خلاقیت در تحلیل
      ),
    );
  }

  GenerativeModel _getTextModel() {
    if (_apiKeys.isEmpty) throw Exception("هیچ کلید API برای جمنای یافت نشد.");
    final currentKey = _apiKeys[_currentKeyIndex];
    return GenerativeModel(
      model: 'gemini-2.0-flash',
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

    debugPrint("===================== PROMPT SENT TO AI =====================");
    debugPrint(prompt);
    debugPrint("=============================================================");

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
            "==================== RAW RESPONSE FROM AI ====================");
        debugPrint(response.text!);
        debugPrint(
            "==============================================================");

        debugPrint(
            "✅ Request successful with API key at index: $keyToTryIndex");
        return response.text!;
      } on GenerativeAIException catch (e) {
        if (e.message.contains('API key not valid') ||
            e.message.contains('quota') ||
            e.message.contains('503')) {
          debugPrint(
              "❌ API key at index $keyToTryIndex failed (Retriable Error): ${e.message}");
          _moveToNextKey();
          continue;
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

  /// <<< اصلاح شده: این متد اکنون یک آبجکت کامل پاسخ را برمی‌گرداند >>>
  Future<AiFileSelectionResponse> findRelevantFiles({
    required Map<String, String> projectImports,
    required String userFocus,
    required List<ChatMessage>
        chatHistory, // <<< جدید: تاریخچه چت برای زمینه بهتر
  }) async {
    final prompt = _buildImportBasedFileFinderPrompt(
        projectImports, userFocus, chatHistory);
    final responseText = await _generateWithRetry(prompt, forJson: true);

    final cleanJsonString =
        responseText.replaceAll(RegExp(r'```(json)?'), '').trim();

    try {
      final decodedJson = json.decode(cleanJsonString);
      return AiFileSelectionResponse.fromJson(decodedJson);
    } catch (e) {
      debugPrint("JSON Decode Error: $e");
      debugPrint("Received String for decoding: $cleanJsonString");
      throw Exception("خطا در تجزیه پاسخ JSON از هوش مصنوعی.");
    }
  }

  Future<String> generateAiHeader({
    required String directoryTree,
    required String userGoal,
    required String pubspecContent,
    required List<String> aiSuggestedFiles,
    required List<String> finalSelectedFiles,
    required String fullProjectContent,
  }) {
    // این متد فعلا بدون تغییر باقی می‌ماند
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

  /// <<< اصلاح شده: پرامپت اکنون تاریخچه چت را دریافت می‌کند و درخواست تحلیل (rationale) دارد >>>
  String _buildImportBasedFileFinderPrompt(Map<String, String> projectImports,
      String userFocus, List<ChatMessage> chatHistory) {
    final importsData = projectImports.entries.map((entry) {
      if (entry.value.trim().isEmpty) {
        return 'File: "${entry.key}"\n(No imports or exports)';
      }
      return 'File: "${entry.key}"\n---\n${entry.value}\n---';
    }).join('\n\n');

    final historyString = chatHistory.map((msg) {
      return "${msg.sender.name}: ${msg.text}";
    }).join('\n');

    return """
    You are a world-class Senior Software Architect specializing in dependency analysis. You are acting as an intelligent assistant for a developer.
    The developer has provided you with a dependency map of their project. You also have the history of your conversation.

    Your mission is twofold:
    1.  **Analyze and Select:** Based on the user's latest request and the conversation history, identify ALL files relevant to the task by analyzing the dependency graph.
    2.  **Explain Your Reasoning:** Provide a concise, professional, and insightful explanation (`rationale`) for your selection. Explain *why* you chose those specific files based on the user's goal and the project structure.

    **Analysis Rules:**
    1.  **Context is Key:** Use the entire `Conversation History` to understand the user's evolving goal. The latest message is the primary focus, but the history provides context.
    2.  **Dependency Analysis:** Use the `Project Dependency Map` to trace connections between files.
    3.  **Naming Conventions:** Use file names as a strong hint (e.g., `form_controller.dart` is relevant to "forms").
    4.  **Comprehensive Selection:** Include every file in the logical chain. It's better to be slightly over-inclusive than to miss a critical dependency.
    5.  **Output Format:** Your output MUST be a valid JSON object with two keys:
        * `"relevant_files"`: An array of strings, where each string is a full file path.
        * `"rationale"`: A string containing your analysis and reasoning, written in clear Persian.

    **Conversation History:**
    ```
    $historyString
    ```
    
    **User's Latest Request:** "$userFocus"

    **Project Dependency Map (File Path -> Imports/Exports):**
    ```
    $importsData
    ```

    **Example JSON Output:**
    ```json
    {
      "relevant_files": [
        "lib/presentation/screens/forms/user_form_screen.dart",
        "lib/presentation/controllers/forms/user_form_controller.dart",
        "lib/presentation/widgets/custom_text_field.dart"
      ],
      "rationale": "برای پیاده‌سازی فرم‌ها، فایل صفحه اصلی `user_form_screen.dart` به عنوان رابط کاربری، `user_form_controller.dart` برای مدیریت منطق و وضعیت، و `custom_text_field.dart` به عنوان ویجت ورودی مشترک، ضروری هستند. این سه فایل هسته اصلی این قابلیت را تشکیل می‌دهند."
    }
    ```

    Now, perform a deep analysis and generate the JSON output.
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
