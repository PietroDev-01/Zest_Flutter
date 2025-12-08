import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  var selectedEmoji = "😊".obs;
  var currentUserName = "".obs; // Variável que a Home escuta

  // --- LIMPEZA DE MEMÓRIA (A CURA DO ZUMBI) ---
  void clearData() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    currentUserName.value = "";
    selectedEmoji.value = "😊";
  }

  // --- LOGIN ---
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Erro', 'Preencha todos os campos');
      return;
    }
    isLoading.value = true;

    try {
      UserCredential cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(), 
        password: passwordController.text.trim(),
      );
      
      // BUSCAR DADOS DO USUÁRIO NO BANCO PARA ATUALIZAR A UI
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        nameController.text = data['name'] ?? "";
        currentUserName.value = data['name'] ?? ""; // Atualiza a Home
        selectedEmoji.value = data['emoji'] ?? "😊";
      }

      Get.offAllNamed('/home'); 
      Get.snackbar('Sucesso', 'Bem-vindo de volta!', backgroundColor: Colors.green, colorText: Colors.white);

    } on FirebaseAuthException catch (e) {
      Get.snackbar('Erro no Login', e.message ?? 'Erro desconhecido');
    } finally {
      isLoading.value = false;
    }
  }

  // --- CADASTRO ---
  Future<void> register() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Erro', 'Preencha todos os campos');
      return;
    }

    isLoading.value = true;
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        emoji: selectedEmoji.value,
      );

      await FirebaseFirestore.instance.collection('users').doc(newUser.id).set(newUser.toMap());
      
      // Atualiza estado local
      currentUserName.value = newUser.name;

      Get.snackbar('Sucesso', 'Conta criada!', backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed('/home');

    } on FirebaseAuthException catch (e) {
      Get.snackbar('Erro', e.message ?? 'Falha ao cadastrar');
    } finally {
      isLoading.value = false;
    }
  }

  // --- ATUALIZAR PERFIL ---
  Future<void> updateProfile(String newName, String newEmoji) async {
    isLoading.value = true;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': newName,
          'emoji': newEmoji,
        });
        
        nameController.text = newName;
        currentUserName.value = newName;
        selectedEmoji.value = newEmoji;
        
        Get.back();
        Get.snackbar("Sucesso", "Perfil atualizado!", backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Erro", "Falha: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- ALTERAR EMAIL ---
  Future<void> changeEmail(String newEmail) async {
    if (newEmail.isEmpty || !newEmail.contains('@')) {
        Get.snackbar("Erro", "Email inválido", backgroundColor: Colors.red, colorText: Colors.white);
        return;
    }

    isLoading.value = true;
    try {
      await FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(newEmail);
      // Nota: O Firebase mudou. Agora ele envia um email de verificação antes de mudar de fato.
      // O email antigo continua valendo até o usuário clicar no link.
      
      Get.back();
      Get.snackbar("Verifique seu Email", "Um link de confirmação foi enviado para $newEmail.", 
          backgroundColor: Colors.blue, colorText: Colors.white, duration: const Duration(seconds: 5));
          
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Get.snackbar("Segurança", "Faça login novamente para mudar o email.", backgroundColor: Colors.red, colorText: Colors.white);
        logout();
      } else {
        Get.snackbar("Erro", e.message ?? "Erro desconhecido");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- EXCLUIR CONTA (CORRIGIDO: Deleta Restaurantes Primeiro) ---
  Future<void> deleteAccount() async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. Buscar e deletar todos os restaurantes desse usuário
        final query = await FirebaseFirestore.instance
            .collection('restaurants')
            .where('ownerId', isEqualTo: user.uid)
            .get();

        for (var doc in query.docs) {
          await doc.reference.delete(); // Deleta um por um
        }

        // 2. Deletar dados do usuário no Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

        // 3. Deletar autenticação
        await user.delete();
        
        clearData(); // Limpa memória local
        Get.offAllNamed('/login');
        Get.snackbar("Conta Deletada", "Seus dados foram removidos.", backgroundColor: Colors.grey, colorText: Colors.white);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Get.snackbar("Segurança", "Faça login novamente para excluir.", backgroundColor: Colors.red, colorText: Colors.white);
        logout();
      } else {
        Get.snackbar("Erro", e.message ?? "Erro ao excluir.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGOUT ---
  void logout() async {
    await FirebaseAuth.instance.signOut();
    clearData(); // Limpa memória para não mostrar dados antigos no próximo login
    Get.offAllNamed('/login');
  }
  
  // --- ALTERAR SENHA ---
  Future<void> changePassword(String newPassword) async {
    // ... (mesmo código anterior, sem mudanças necessárias)
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
      Get.back();
      Get.snackbar("Sucesso", "Senha alterada!", backgroundColor: Colors.green, colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
            Get.snackbar("Segurança", "Faça login novamente.", backgroundColor: Colors.red, colorText: Colors.white);
            logout();
        } else {
            Get.snackbar("Erro", e.message ?? "Erro desconhecido");
        }
    } finally {
        isLoading.value = false;
    }
  }
}