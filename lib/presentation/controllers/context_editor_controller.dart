import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../../core/models/chat_message.dart';
import '../../core/models/tree_node.dart';
import '../../core/services/file_service.dart';
import '../../core/services/gemini_service.dart';
import '../routes/app_pages.dart';

class ContextEditorController extends GetxController {
  final GeminiService _geminiService = Get.find();
  final FileService _fileService = Get.find();

  // State
  final RxBool isAiFindingFiles = false.obs;
  final RxBool isGeneratingFinalCode = false.obs;
  final RxString statusMessage = 'آماده دریافت حوزه تمرکز شما'.obs;

  // Data from previous screen
  late final String fullProjectContent;
  late final String directoryTree;
  late final String pubspecContent;

  // User Inputs
  late final TextEditingController focusController;
  late final TextEditingController goalController;
  late final TextEditingController chatInputController;

  // TreeView
  final RxList<TreeNode> treeNodes = <TreeNode>[].obs;

  // File Lists
  final RxList<String> aiSuggestedFiles = <String>[].obs;
  final RxList<String> userFinalSelection = <String>[].obs;

  // Chat History
  final RxList<ChatMessage> chatHistory = <ChatMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    fullProjectContent = args['fullProjectContent'];
    directoryTree = args['directoryTree'];
    pubspecContent = args['pubspecContent'];

    focusController = TextEditingController();
    goalController = TextEditingController();
    chatInputController = TextEditingController();

    _buildFileTree();

    chatHistory.add(ChatMessage(
      text:
          'سلام! من دستیار هوشمند شما هستم. برای شروع، درخواستت رو بگو تا فایل‌های مرتبط رو برات پیدا کنم.',
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void onClose() {
    focusController.dispose();
    goalController.dispose();
    chatInputController.dispose();
    super.onClose();
  }

  String _normalizePath(String path) {
    String withForwardSlashes = path.replaceAll('\\', '/');
    return withForwardSlashes.replaceAll(RegExp(r'/+'), '/');
  }

  void _buildFileTree() {
    final List<String> paths = directoryTree
        .split('\n')
        .where((line) =>
            line.trim().isNotEmpty && !line.startsWith('نمودار درختی'))
        .map((line) => line.trim())
        .toList();

    final Map<String, TreeNode> nodeMap = {};
    final List<TreeNode> rootNodes = [];

    for (final path in paths) {
      final normalizedPath = _normalizePath(path);
      List<String> parts = normalizedPath.split('/');

      TreeNode? parent;
      String currentPath = '';

      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        currentPath = i == 0 ? part : '$currentPath/$part';

        if (!nodeMap.containsKey(currentPath)) {
          final isFile = i == parts.length - 1;
          final newNode = TreeNode(
            key: currentPath,
            label: part,
            path: isFile ? normalizedPath : '',
            isFile: isFile,
            children: [],
          );
          nodeMap[currentPath] = newNode;

          if (parent == null) {
            rootNodes.add(newNode);
          } else {
            parent.children.add(newNode);
          }
        }
        parent = nodeMap[currentPath];
      }
    }
    treeNodes.value = rootNodes;
  }

  /// <<< اصلاح شده: این متد اکنون پاسخ چندحالته AI را مدیریت می‌کند >>>
  Future<void> _processUserPrompt({required String userPrompt}) async {
    if (userPrompt.trim().isEmpty) {
      return;
    }

    isAiFindingFiles.value = true;
    statusMessage.value = 'در حال فکر کردن...';

    final userMessage = ChatMessage(
        text: userPrompt,
        sender: MessageSender.user,
        timestamp: DateTime.now());
    chatHistory.add(userMessage);

    try {
      final allFilesMap = _fileService.parseProjectContent(fullProjectContent);
      final projectImports = allFilesMap.map(
        (path, content) => MapEntry(path, _fileService.extractImports(content)),
      );

      final aiResponse = await _geminiService.getAiResponse(
        projectImports: projectImports,
        userPrompt: userPrompt,
        chatHistory: chatHistory,
      );

      // افزودن پاسخ AI به تاریخچه
      final aiMessage = ChatMessage(
        text: aiResponse.responseText,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );
      chatHistory.add(aiMessage);

      // بر اساس قصد AI، عملیات مناسب را انجام بده
      if (aiResponse.intent == AiIntent.findFiles) {
        final normalizedRelevantFiles =
            aiResponse.relevantFiles.map(_normalizePath).toList();

        aiSuggestedFiles.assignAll(normalizedRelevantFiles);
        userFinalSelection.assignAll(normalizedRelevantFiles);

        _expandToSelection(treeNodes, userFinalSelection);

        statusMessage.value =
            '${aiResponse.relevantFiles.length} فایل مرتبط پیدا شد. نظرت چیه؟';
      } else {
        // اگر فقط یک پاسخ چت بود، کاری با فایل‌ها نداریم
        statusMessage.value = 'آماده دریافت دستور بعدی شما.';
      }
    } catch (e) {
      statusMessage.value = 'خطا در ارتباط با AI.';
      final errorMessage = ChatMessage(
          text: 'متاسفانه یه مشکلی پیش اومد: $e',
          sender: MessageSender.ai,
          timestamp: DateTime.now());
      chatHistory.add(errorMessage);
      debugPrint('An error occurred in _processUserPrompt: $e');
      Get.snackbar('خطای تحلیل', e.toString());
    } finally {
      isAiFindingFiles.value = false;
    }
  }

  void sendChatMessage() {
    final prompt = chatInputController.text;
    _processUserPrompt(userPrompt: prompt);
    focusController.text = prompt;
    chatInputController.clear();
  }

  void findFilesFromPanel() {
    final prompt = focusController.text;
    _processUserPrompt(userPrompt: prompt);
  }

  void _expandToSelection(List<TreeNode> nodes, List<String> selection) {
    for (var node in nodes) {
      // ابتدا تمام گره‌ها را می‌بندیم تا درخت تمیز شود
      if (!node.isFile) node.isExpanded.value = false;
    }
    for (var node in nodes) {
      bool hasSelectedChild = _nodeContainsSelection(node, selection);
      if (hasSelectedChild) {
        node.isExpanded.value = true;
        _expandToSelection(node.children, selection);
      }
    }
  }

  bool _nodeContainsSelection(TreeNode node, List<String> selection) {
    if (node.isFile) {
      final isSelected = selection.contains(node.path);
      return isSelected;
    }
    for (var child in node.children) {
      if (_nodeContainsSelection(child, selection)) {
        return true;
      }
    }
    return false;
  }

  void onNodeToggled(TreeNode node) {
    if (node.isFile) {
      if (userFinalSelection.contains(node.path)) {
        userFinalSelection.remove(node.path);
      } else {
        userFinalSelection.add(node.path);
      }
    } else {
      node.isExpanded.toggle();
    }
  }

  Future<void> generateFinalCode() async {
    if (goalController.text.trim().isEmpty) {
      Get.snackbar('خطا', 'لطفاً هدف نهایی خود را برای تولید زمینه مشخص کنید.');
      return;
    }
    if (userFinalSelection.isEmpty) {
      Get.snackbar('خطا', 'حداقل یک فایل باید برای تولید زمینه انتخاب شود.');
      return;
    }

    isGeneratingFinalCode.value = true;
    statusMessage.value = 'در حال تولید سند زمینه نهایی...';

    try {
      final String aiHeader = await _geminiService.generateAiHeader(
        directoryTree: directoryTree,
        userGoal: goalController.text.trim(),
        pubspecContent: pubspecContent,
        finalSelectedFiles: userFinalSelection,
        fullProjectContent: fullProjectContent,
      );

      final StringBuffer codeBuffer = StringBuffer();
      codeBuffer.writeln(aiHeader);
      codeBuffer.writeln('\n');

      final sortedSelection = List<String>.from(userFinalSelection)..sort();
      for (var filePath in sortedSelection) {
        final fileContent =
            _fileService.extractFileContent(fullProjectContent, filePath);
        _appendFileToBuffer(codeBuffer, filePath, fileContent);
      }

      Get.toNamed(AppPages.result, arguments: codeBuffer.toString());
    } catch (e) {
      debugPrint('An error occurred in generateFinalCode: $e');
      Get.snackbar('خطا', 'مشکلی در تولید کد رخ داد: $e');
    } finally {
      isGeneratingFinalCode.value = false;
    }
  }

  void _appendFileToBuffer(StringBuffer buffer, String path, String content) {
    buffer.writeln('/------------------------------------');
    buffer.writeln('مسیر فایل: $path');
    buffer.writeln('محتوای فایل:');
    buffer.writeln(content);
    buffer.writeln('------------------------------------/\n');
  }
}
