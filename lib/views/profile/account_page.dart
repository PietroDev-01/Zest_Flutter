import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'update_user_sheet.dart'; // Tela 7.1
import 'update_password_sheet.dart'; // Tela 7.2

class AccountPage extends StatelessWidget {
  final AuthController controller = Get.find();

  AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sua Conta")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Botão Amarelo: Limpar Histórico
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.snackbar("Info", "Histórico limpo! (Simulação)"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.all(15)),
                child: const Text("Limpar Histórico de Sugestão", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 15),

            // Botão Laranja: Alterar Usuário (Email)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.dialog(UpdateUserSheet(), barrierColor: Colors.black.withOpacity(0.3));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.all(15)),
                child: const Text("Alterar Usuário (Email)", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 15),

            // Botão Laranja: Alterar Senha
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.dialog(UpdatePasswordSheet(), barrierColor: Colors.black.withOpacity(0.3));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.all(15)),
                child: const Text("Alterar Senha", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 15),

            // Botão Laranja Escuro: Sair
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.logout(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.all(15)),
                child: const Text("Sair da Conta", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 15),

            // Botão Vermelho: Excluir Conta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: "Perigo!",
                    titleStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    middleText: "Isso apagará sua conta e todos os seus restaurantes permanentemente.",
                    
                    // --- BOTÕES ---
                    textCancel: "Cancelar", // Botão que faltava
                    textConfirm: "Sim, Excluir Tudo",
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    cancelTextColor: Colors.black,
                    
                    onConfirm: () {
                      Get.back(); // Fecha o diálogo
                      // Chama a função real de deletar (Vamos criar abaixo)
                      controller.deleteAccount(); 
                    }
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], padding: const EdgeInsets.all(15)),
                child: const Text("EXCLUIR CONTA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}