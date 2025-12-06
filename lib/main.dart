import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/auth_controller.dart';
import 'views/auth/login_page.dart';
import 'views/home/home_page.dart';
import 'views/restaurant/add_restaurant_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicia o Firebase (Banco e Auth)
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Projeto Restaurante',
      debugShowCheckedModeBanner: false,

      // Tema do App
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      
      // Rotas de Navegação
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/add-restaurant', page: () => AddRestaurantPage()),
      ],
    );
  }
}