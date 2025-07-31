import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'settings_service.dart'; // <<< جدید: ایمپورت سرویس تنظیمات
import '../../core/models/chat_message.dart';

// ... (کلاس‌های AiIntent و AiChatResponse بدون تغییر باقی می‌مانند) ...
enum AiIntent {
  findFiles,
  chatReply,
  unknown,
}

class AiChatResponse {
  final AiIntent intent;
  final List<String> relevantFiles;
  final String responseText;

  AiChatResponse({
    required this.intent,
    this.relevantFiles = const [],
    required this.responseText,
  });

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    var intent = AiIntent.unknown;
    final intentString = json['intent'] as String?;
    if (intentString == 'find_files') {
      intent = AiIntent.findFiles;
    } else if (intentString == 'chat_reply') {
      intent = AiIntent.chatReply;
    }

    return AiChatResponse(
      intent: intent,
      relevantFiles: List<String>.from(json['relevant_files'] ?? []),
      responseText: json['response_text'] as String? ??
          'متاسفانه پاسخی برای ارائه ندارم.',
    );
  }
}

class GeminiService extends GetxService {
  // <<< اصلاح: وابستگی به سرویس تنظیمات >>>
  final SettingsService _settingsService = Get.find();

  // <<< اصلاح: لیست کلیدهای API دیگر هاردکد نیست >>>
  late List<String> _apiKeys;
  int _currentKeyIndex = 0;

  @override
  void onInit() {
    super.onInit();
    _loadApiKeys();
  }

  void _loadApiKeys() {
    _apiKeys = _settingsService.getApiKeys();
    if (_apiKeys.isNotEmpty) {
      debugPrint('✅ ${_apiKeys.length} API keys loaded from SettingsService.');
    } else {
      debugPrint("❌ WARNING: No Gemini API keys found in settings.");
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
        temperature: 0.1,
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
    // <<< جدید: هر بار کلیدها را مجدداً بارگذاری می‌کنیم تا تغییرات اعمال شوند >>>
    _loadApiKeys();

    if (_apiKeys.isEmpty) {
      throw Exception(
          "هیچ کلید API برای استفاده وجود ندارد. لطفاً از بخش تنظیمات کلید خود را اضافه کنید.");
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

  // ... (متدهای getAiResponse, generateAiHeader, و پرامپت‌ها بدون تغییر باقی می‌مانند) ...
  Future<AiChatResponse> getAiResponse({
    required Map<String, String> projectImports,
    required String userPrompt,
    required List<ChatMessage> chatHistory,
  }) async {
    final prompt =
        _buildIntentDetectionPrompt(projectImports, userPrompt, chatHistory);
    final responseText = await _generateWithRetry(prompt, forJson: true);

    final cleanJsonString =
        responseText.replaceAll(RegExp(r'```(json)?'), '').trim();

    try {
      final decodedJson = json.decode(cleanJsonString);
      return AiChatResponse.fromJson(decodedJson);
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
    required List<String> finalSelectedFiles,
    required String fullProjectContent,
  }) {
    final prompt = _buildHeaderPromptV2(
      directoryTree: directoryTree,
      userGoal: userGoal,
      pubspecContent: pubspecContent,
      finalSelectedFiles: finalSelectedFiles,
      fullProjectContent: fullProjectContent,
    );
    return _generateWithRetry(prompt, forJson: false);
  }

  String _buildIntentDetectionPrompt(Map<String, String> projectImports,
      String userPrompt, List<ChatMessage> chatHistory) {
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
    You are a friendly but extremely meticulous AI software architect. Your primary goal is to help a developer by analyzing their project's dependency graph. You speak Persian.

    **STEP 1: DETERMINE USER INTENT**
    First, analyze the `User's Latest Request` in the context of the `Conversation History` to determine the user's intent. There are two possibilities:
    - `find_files`: The user is asking for help with a coding task, implying a need to find relevant files. (e.g., "add login", "fix the form bug", "فرم ها").
    - `chat_reply`: The user is making small talk, asking a general question, or giving feedback. (e.g., "salam", "thanks", "چطوری؟").

    **STEP 2: EXECUTE BASED ON INTENT**

    **IF `intent` is `find_files`:**
    You must perform a **rigorous and exhaustive dependency analysis**. Your reputation depends on your thoroughness.
    
    **Analysis Protocol:**
    a. **Seed Files:** Identify the initial "seed" files that obviously match the user's request from the `Project Dependency Map`.
    b. **Forward Trace (Recursive):** For each seed file, find all files it `import`s. For each of *those* files, find all files *they* `import`. Continue this process recursively until you can't find any new dependencies. Add all found files to your list.
    c. **Reverse Trace (Crucial):** Search the ENTIRE `Project Dependency Map` again. Find every file that `import`s any of the files you have collected so far (from steps a and b). This is critical for finding files that *use* the core feature.
    d. **Be Exhaustive:** It is better to include a file that might be slightly related than to miss a critical one. Combine all files from steps a, b, and c into a single, de-duplicated list.

    **Response Generation (for `find_files`):**
    - After your analysis is complete, generate a `response_text`.
    - **DO NOT** just list the files. Explain your findings like a helpful colleague. Summarize your process. For example: "برای کار روی فرم‌ها، اول فایل‌های اصلی مثل کنترلر و سرویس رو پیدا کردم. بعدش دیدم که اینا به چندتا مدل و ویجت دیگه هم وصلن، و در نهایت صفحاتی که از این فرم‌ها استفاده می‌کنن رو هم به لیست اضافه کردم تا چیزی از قلم نیفته. این لیست کاملشه، نظرت چیه؟"
    - Your final output MUST be a JSON object with `intent: "find_files"`, the complete `relevant_files` list, and your `response_text`.

    **IF `intent` is `chat_reply`:**
    - Simply generate a friendly, conversational `response_text` in Persian.
    - Your final output MUST be a JSON object with `intent: "chat_reply"`, `relevant_files: []`, and your `response_text`.

    ---
    **CONTEXT FOR YOUR ANALYSIS**

    **Conversation History:**
    ```
    $historyString
    ```
    
    **User's Latest Request:** "$userPrompt"

    **Project Dependency Map (File Path -> Imports/Exports):**
    ```
    $importsData
    ```
    ---
    Now, perform your analysis and generate the response in the correct JSON format.
    """;
  }

  String _buildHeaderPromptV2(
      {required String directoryTree,
      required String userGoal,
      required List<String> finalSelectedFiles,
      required String fullProjectContent,
      required String pubspecContent}) {
    final finalFilesString = finalSelectedFiles.map((f) => '- $f').join('\n');

    return """
    You are a Senior AI Architect. Your task is to generate a comprehensive context document for another AI assistant.
    This document must provide a deep and insightful overview of the user's project and their goal, based on the FULL source code provided.

    **Your Instructions:**
    1.  **Analyze Everything:** You have access to the user's goal, the final list of files they've selected for the task, the project's full directory tree, and the ENTIRE project's source code.
    2.  **Synthesize, Don't Just List:** Do not just repeat the data. Your primary value is to synthesize this information into a coherent, intelligent analysis.
    3.  **Explain the "Why":** Based on your analysis of the full code, explain *why* the user's goal is relevant to the project and *why* the selected files are the correct ones for the job. What is the overall architecture? How do these selected files fit into it?
    4.  **Provide a High-Level Summary:** Give a brief overview of what the project does.
    5.  **Structure the Output:** Fill in the template below with your analysis. Be clear, concise, and professional. The final output should ONLY be the completed markdown template.

    **================ TEMPLATE TO COMPLETE ================**
    # AI CONTEXT DOCUMENT - V4.1 - FULL STRUCTURE ANALYSIS
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

    ### SECTION 3: PROJECT STRUCTURE & FILE MANIFEST
    # To provide complete context for the task, below is the full directory tree of the project, followed by the specific files selected for modification.

    # Full Project Directory Tree:
    # ```
    # $directoryTree
    # ```
    #
    # The following files, and ONLY these files, have been selected for the current task. This is the single source of truth for the next AI.
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
