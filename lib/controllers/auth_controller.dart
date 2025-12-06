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

  // Guarda o emoji escolhido (Padrão é o sorriso)
  var selectedEmoji = "😊".obs;

  // --- LOGIN ---
  Future<void> login() async {
    // Validação simples
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Atenção', 'Preencha email e senha', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      // Conexão com o Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(), 
        password: passwordController.text.trim(),
      );
      
      // Se deu certo: Vai pra Home e apaga o histórico de voltar
      Get.offAllNamed('/home');
      Get.snackbar('Sucesso', 'Bem-vindo de volta!', backgroundColor: Colors.green, colorText: Colors.white);

    } on FirebaseAuthException catch (e) {
      // Tratamento de erros comuns (Senha errada, usuário não encontrado)
      Get.snackbar('Erro no Login', e.message ?? 'Verifique seus dados');
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
      // Usuário na Autenticação (Email/Senha)
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Dados para salvar no Banco
      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        emoji: selectedEmoji.value,
      );

      // Salva no Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.id)
          .set(newUser.toMap());

      Get.snackbar('Sucesso', 'Conta criada!', backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed('/home');

    } on FirebaseAuthException catch (e) {
      Get.snackbar('Erro ao Cadastrar', e.message ?? 'Tente novamente');
    } finally {
      isLoading.value = false;
    }
  }
}