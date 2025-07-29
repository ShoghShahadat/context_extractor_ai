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

        if (decodedJson is Map<String, dynamic> &&
            decodedJson.containsKey('screens') &&
            decodedJson['screens'] is List) {
          final List<dynamic> screensJson = decodedJson['screens'];
          return screensJson
              .map((json) => ProjectScreen.fromJson(json))
              .toList();
        } else {
          throw Exception(
              "پاسخ هوش مصنوعی ساختار مورد انتظار (لیست صفحات) را نداشت.");
        }
      } else {
        throw Exception("هوش مصنوعی جمنای یک پاسخ خالی برگرداند.");
      }
    } catch (e) {
      debugPrint("Error analyzing project with Gemini: $e");
      rethrow;
    }
  }

  /// <<< اصلاح کامل: تولید مقدمه هوشمند و جامع برای هوش مصنوعی بعدی >>>
  Future<String> generateAiHeader({
    required List<ProjectScreen> selectedScreens,
    required String directoryTree,
    required String userGoal,
    required String pubspecContent,
  }) async {
    try {
      final model = _getModel(forJson: false);
      final prompt = _buildHeaderPrompt(
        selectedScreens: selectedScreens,
        directoryTree: directoryTree,
        userGoal: userGoal,
        pubspecContent: pubspecContent,
      );
      final content = [Content.text(prompt)];

      debugPrint(
          "Sending prompt to Gemini for DETAILED AI header generation...");
      final response = await model.generateContent(content);
      debugPrint("Received detailed AI header from Gemini.");

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
    2.  "Related Files" for a screen include its specific controller(s), binding(s), and any related models or services based on naming conventions.
    3.  The output MUST be a valid JSON object. Do not include any text or markdown before or after the JSON object.
    4.  The "explanation" field MUST be in Persian.

    **Project Structure:**
    ```
    $directoryTree
    ```

    **Pubspec Content:**
    ```yaml
    $pubspecContent
    ```

    **Required JSON Output Format:**
    ```json
    {
      "screens": [
        {
          "screen_name": "lib/presentation/screens/auth/login_screen.dart",
          "related_files": [
            "lib/controllers/auth/login_controller.dart"
          ],
          "explanation": "این فایل‌ها به صفحه ورود مرتبط هستند."
        }
      ]
    }
    ```

    Now, analyze the provided project structure and generate the JSON output.
    """;
  }

  /// <<< اصلاح کامل: پرامپت مهندسی‌شده و جامع برای تولید سند زمینه >>>
  String _buildHeaderPrompt({
    required List<ProjectScreen> selectedScreens,
    required String directoryTree,
    required String userGoal,
    required String pubspecContent,
  }) {
    final screenPaths = selectedScreens
        .map((s) => '# - ${s.screenName.replaceAll(r'\', '/')}')
        .join('\n');

    return """
    You are an expert AI assistant acting as a "Context Engineer". 
    Your mission is to create a comprehensive, clear, and detailed header for another AI model. 
    This header is CRITICAL for the other AI to understand the context of the code it's about to receive. The code it will see is only a partial subset of a larger project, selected by a human user for a specific task.

    **Your header MUST be structured, detailed, and written in clear English.**

    **Instructions:**

    1.  **Main Title:** Start with a clear, multi-line delimiter and a title.
        Example:
        ############################################################
        # AI CONTEXT HEADER - V2.0 - PREPARED FOR ANALYSIS
        ############################################################

    2.  **Section 1: Project Overview**
        - Greet the AI.
        - Provide a high-level summary of the project. Use the `pubspec.yaml` content and the overall directory structure to infer the project's purpose.
        - Mention the main technologies used (e.g., "This is a Flutter project using the GetX state management...").

    3.  **Section 2: The User's Goal & Mission**
        - This is the most important section.
        - Clearly state the user's objective. The user has provided a specific goal for this task.
        - The user's goal is: "$userGoal"
        - Explain that the following code files have been specifically selected by the user because they believe these files are the most relevant to achieving this goal.

    4.  **Section 3: Provided Context & File Manifest**
        - State explicitly that the context is partial.
        - List the primary "Screen(s)" the user focused on. These are the entry points for their task.
        - The user selected the following screen(s):
    $screenPaths
        - Explain that all related files for these screens (controllers, services, models, etc.) are also included.
        - State that the full directory tree is provided below for complete architectural awareness, even though not all files are included.

    5.  **Section 4: Architectural Blueprint (Directory Tree)**
        - Title this section clearly (e.g., "Full Project Directory Tree:").
        - Include the complete directory tree, with each line prefixed by '# '.
        - Directory Tree:
    $directoryTree

    6.  **Section 5: Final Instructions for the AI**
        - Give a clear, final instruction.
        - Reiterate the user's goal.
        - Instruct the AI to base its entire analysis, response, or code generation *only* on the provided files and the user's goal.
        - Example: "Your task is to analyze the provided code in light of the user's goal: '$userGoal'. Please generate your response based *only* on the context given below."

    7.  **Closing Delimiter:** End with a clear delimiter.
        Example:
        # AI CONTEXT HEADER - END
        ############################################################

    **INPUTS YOU HAVE RECEIVED:**
    - User's Goal: "$userGoal"
    - Selected Screens:
    $screenPaths
    - Full Directory Tree:
    $directoryTree
    - Pubspec Content:
    $pubspecContent

    Now, generate ONLY the header based on these instructions and the provided inputs. Do not add any other text or commentary.
    """;
  }
}
