import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Função global para mostrar o Loading
void showLoadingDialog(String message) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

// Função para fechar o Loading
void hideLoadingDialog() {
  if (Get.isDialogOpen ?? false) {
    Get.back();
  }
}