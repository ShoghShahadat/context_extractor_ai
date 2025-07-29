import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // TreeView
  final RxList<TreeNode> treeNodes = <TreeNode>[].obs;

  // File Lists
  final RxList<String> aiSuggestedFiles = <String>[].obs;
  final RxList<String> userFinalSelection = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    fullProjectContent = args['fullProjectContent'];
    directoryTree = args['directoryTree'];
    pubspecContent = args['pubspecContent'];

    focusController = TextEditingController();
    goalController = TextEditingController();

    _buildFileTree();
  }

  @override
  void onClose() {
    focusController.dispose();
    goalController.dispose();
    super.onClose();
  }

  /// <<< اصلاح کلیدی: تابع کمکی برای یکسان‌سازی فرمت مسیرها >>>
  String _normalizePath(String path) {
    return path.replaceAll(r'\', '/');
  }

  /// <<< اصلاح کامل: بازنویسی منطق ساخت درخت برای دقت و پایداری بیشتر >>>
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
            path: isFile
                ? normalizedPath
                : '', // فقط فایل‌ها مسیر کامل قابل انتخاب دارند
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

  Future<void> findFilesWithAi() async {
    if (focusController.text.trim().isEmpty) {
      Get.snackbar('خطا', 'لطفاً حوزه تمرکز خود را مشخص کنید.');
      return;
    }

    isAiFindingFiles.value = true;
    statusMessage.value = 'هوش مصنوعی در حال تحلیل پروژه شماست...';

    try {
      final relevantFiles = await _geminiService.findRelevantFiles(
        directoryTree: directoryTree,
        userFocus: focusController.text.trim(),
      );

      // <<< اصلاح کلیدی: نرمال‌سازی مسیرهای دریافتی از AI >>>
      final normalizedRelevantFiles =
          relevantFiles.map(_normalizePath).toList();

      aiSuggestedFiles.assignAll(normalizedRelevantFiles);
      userFinalSelection.assignAll(normalizedRelevantFiles);

      _expandToSelection(treeNodes, userFinalSelection);

      statusMessage.value =
          '${relevantFiles.length} فایل مرتبط توسط AI پیدا شد. لطفاً بازبینی کنید.';
      treeNodes.refresh();
    } catch (e) {
      statusMessage.value = 'خطا در تحلیل AI.';
      Get.snackbar('خطای تحلیل', e.toString());
    } finally {
      isAiFindingFiles.value = false;
    }
  }

  void _expandToSelection(List<TreeNode> nodes, List<String> selection) {
    for (var node in nodes) {
      bool hasSelectedChild = _nodeContainsSelection(node, selection);
      if (hasSelectedChild) {
        node.isExpanded = true;
        _expandToSelection(node.children, selection);
      }
    }
  }

  bool _nodeContainsSelection(TreeNode node, List<String> selection) {
    if (node.isFile && selection.contains(node.path)) {
      return true;
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
      node.isExpanded = !node.isExpanded;
    }
    treeNodes.refresh();
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
        aiSuggestedFiles: aiSuggestedFiles,
        finalSelectedFiles: userFinalSelection,
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
