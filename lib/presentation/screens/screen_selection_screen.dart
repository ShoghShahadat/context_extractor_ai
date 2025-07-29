import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/screen_selection_controller.dart';

class ScreenSelectionScreen extends GetView<ScreenSelectionController> {
  const ScreenSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('انتخاب صفحات مورد نظر'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'جستجوی صفحه...',
                prefixIcon: const Icon(Iconsax.search_normal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => controller.filterScreens(value),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.filteredScreens.isEmpty) {
                return const Center(
                    child: Text('صفحه‌ای با این نام یافت نشد.'));
              }
              return ListView.builder(
                itemCount: controller.filteredScreens.length,
                itemBuilder: (context, index) {
                  final screen = controller.filteredScreens[index];
                  return Obx(() => CheckboxListTile(
                        title: Text(screen.displayName),
                        subtitle: Text(
                          '${screen.relatedFiles.length + 1} فایل مرتبط',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        value: screen.isSelected.value,
                        onChanged: (bool? value) {
                          controller.toggleSelection(screen);
                        },
                        activeColor: Colors.teal,
                      ));
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: controller.isGenerating.value
                ? null
                : controller.generateFinalCode,
            label: controller.isGenerating.value
                ? const Text('در حال تولید...')
                : const Text('تولید کد زمینه'),
            icon: controller.isGenerating.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Iconsax.code_1),
          )),
    );
  }
}
