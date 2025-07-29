import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استخراج کننده هوشمند زمینه کد'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.code, size: 80, color: Colors.teal),
              const SizedBox(height: 24),
              const Text(
                'به ابزار هوشمند استخراج کد خوش آمدید!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'لطفاً فایل متنی کامل پروژه خود (front.txt) را برای شروع تحلیل انتخاب کنید.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // --- دکمه اصلی که حالا از پکیج جدید استفاده می‌کند ---
              ElevatedButton.icon(
                onPressed: controller.pickAndProcessProjectFile,
                icon: const Icon(Iconsax.document_upload),
                label: const Text('انتخاب فایل پروژه'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
