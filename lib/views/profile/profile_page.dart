import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/restaurant_controller.dart';
import '../widgets/restaurant_card.dart';
import 'management_sheet.dart';
import 'edit_profile_sheet.dart';
import 'account_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController authController = Get.find();
  final RestaurantController resController = Get.find();
  
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          isExpanded = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Meu Perfil", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabeçalho
            Center(
              child: Column(
                children: [
                  // EMOJI (Mantém Obx pois selectedEmoji é .obs)
                  Obx(() => Text(
                    authController.selectedEmoji.value, 
                    style: const TextStyle(fontSize: 60)
                  )),
                  
                  const SizedBox(height: 10),
                  
                  // --- CORREÇÃO AQUI: Removemos o Obx do Nome ---
                  // Usamos GetBuilder ou apenas Text simples para evitar o erro vermelho
                  GetBuilder<AuthController>(
                    builder: (controller) {
                      return Text(
                        controller.nameController.text.isNotEmpty 
                            ? controller.nameController.text 
                            : "Usuário",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      );
                    }
                  ),
                  // ----------------------------------------------

                  const Text("Últimas Sugestões", style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Botões de Ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.bottomSheet(
                        EditProfileSheet(),
                        isScrollControlled: true,
                        barrierColor: Colors.black.withOpacity(0.2),
                      ).then((_) {
                        // Força atualizar a tela quando fechar o modal para mostrar nome novo
                        setState(() {}); 
                      });
                    },
                    child: const Text("Editar Perfil"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.to(() => AccountPage());
                    },
                    child: const Text("Conta"),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            const Divider(),
            const Text("Gerenciar Seus Estabelecimentos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 15),

            // 3. Lista de Meus Restaurantes (Mantém Obx pois a lista é .obs)
            Obx(() {
              final myRestaurants = resController.myRestaurants;
              
              if (myRestaurants.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Você ainda não cadastrou nenhum restaurante."),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = myRestaurants[index];
                  return GestureDetector(
                    onTap: () {
                      Get.bottomSheet(
                        ManagementSheet(restaurant: restaurant),
                        isScrollControlled: true,
                        barrierColor: Colors.black.withOpacity(0.2),
                      );
                    },
                    child: AbsorbPointer(
                      child: RestaurantCard(restaurant: restaurant),
                    ),
                  );
                },
              );
            }),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      
      // 4. Botão Flutuante
      floatingActionButton: GestureDetector(
        onTap: () => Get.toNamed('/add-restaurant'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isExpanded) ...[
                const Text("Add Rest.", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.add_business, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}