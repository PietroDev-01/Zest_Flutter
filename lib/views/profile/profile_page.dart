import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  final AuthController authController = Get.find();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meu Perfil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              authController.nameController.text.isNotEmpty 
                  ? authController.nameController.text 
                  : "Usuário",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logout simples
                authController.emailController.clear();
                authController.passwordController.clear();
                Get.offAllNamed('/login');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Sair da Conta", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}