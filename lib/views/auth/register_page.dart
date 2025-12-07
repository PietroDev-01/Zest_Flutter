import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  final AuthController controller = Get.find();

  final List<String> emojis = ["😊", "😎", "🥳", "😋", "👩‍💻", "👨‍💻", "🍔", "🍕"];

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Faça seu cadastro no Zest", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // Campo Nome
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: "Seu Nome",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),

            // Campo Email
            TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),

            // Campo Senha
            TextField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Senha",
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 25),

            // Seletor de Emoji
            const Text("Escolha seu Avatar:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: emojis.length,
                itemBuilder: (context, index) {
                  final emoji = emojis[index];
                  return Obx(() {
                    final isSelected = controller.selectedEmoji.value == emoji;
                    return GestureDetector(
                      onTap: () => controller.selectedEmoji.value = emoji,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange.withOpacity(0.3) : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.orange, width: 2) : null,
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 28)),
                      ),
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 30),

            // Botão Cadastrar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.register(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Cadastrar", style: TextStyle(fontSize: 18, color: Colors.white)),
              )),
            ),
          ],
        ),
      ),
    );
  }
}