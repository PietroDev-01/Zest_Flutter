import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/restaurant_controller.dart';
import '../../models/restaurant_model.dart';
import '../../controllers/auth_controller.dart';

class AddRestaurantPage extends StatefulWidget {
  AddRestaurantPage({super.key}); 

  @override
  State<AddRestaurantPage> createState() => _AddRestaurantPageState();
}

class _AddRestaurantPageState extends State<AddRestaurantPage> {
  final RestaurantController controller = Get.find();
  
  final AuthController authController = Get.isRegistered<AuthController>() 
      ? Get.find<AuthController>() 
      : Get.put(AuthController());

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final whatsappCtrl = TextEditingController();
  final openTimeCtrl = TextEditingController();
  final closeTimeCtrl = TextEditingController();
  
  File? _selectedImage;
  String _base64Image = "";
  final List<String> _selectedTags = [];
  bool _isLoadingLoc = false;
  double? _latitude;
  double? _longitude;

  final List<String> allTags = [
    "Pizzaria", "Hamburgueria", "Massas", "Comida Brasileira", 
    "Sorveteria", "Açaí", "Salgado", "Churrasco", "Bebida", 
    "Comida Caseira", "Sushi", "Lanche"
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _selectedImage = File(pickedFile.path);
        _base64Image = base64Encode(bytes);
      });
    }
  }

  // --- GPS: Pedir Permissão ---
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLoc = true);
    
    try {
      // Verifica se o serviço de GPS está ligado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Erro", "O GPS está desligado. Ligue-o para continuar.");
        return;
      }

      // Verifica a permissão
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Se não tem, pede a permissão
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Erro", "Você precisa autorizar o uso do GPS.");
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar("Erro", "Permissão negada permanentemente. Vá nas configurações.");
        return;
      }

      // 3. Pega a localização com precisão
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      
      Get.snackbar("Sucesso", "Localização encontrada!", backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar("Erro", "Falha no GPS: $e");
    } finally {
      setState(() => _isLoadingLoc = false);
    }
  }

  void _saveRestaurant() {
    if (nameCtrl.text.isEmpty || _selectedTags.isEmpty || _latitude == null) {
      Get.snackbar("Atenção", "Preencha Nome, Tags e Localização (Obrigatórios)", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final newRestaurant = RestaurantModel(
      id: "",
      ownerId: FirebaseAuth.instance.currentUser?.uid ?? "anonimo",
      name: nameCtrl.text,
      description: descCtrl.text,
      logoUrl: _base64Image,
      tags: _selectedTags,
      whatsapp: whatsappCtrl.text,
      latitude: _latitude!,
      longitude: _longitude!,
      openTime: openTimeCtrl.text,
      closeTime: closeTimeCtrl.text,
    );

    controller.addRestaurant(newRestaurant);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastre seu Restaurante")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dados Principais", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange, width: 2),
                    image: _selectedImage != null
                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _selectedImage == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Toque para adicionar a logo", style: TextStyle(fontSize: 12, color: Colors.grey)),
            )),

            const SizedBox(height: 15),
            TextField(
              controller: nameCtrl,
              maxLength: 50,
              decoration: const InputDecoration(labelText: "Nome do Estabelecimento *", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: TextField(
                  controller: openTimeCtrl, 
                  maxLength: 5,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(labelText: "Abre (18:00)", border: OutlineInputBorder())
                )),
                const SizedBox(width: 10),
                Expanded(child: TextField(
                  controller: closeTimeCtrl, 
                  maxLength: 5,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(labelText: "Fecha (23:00)", border: OutlineInputBorder())
                )),
              ],
            ),

            const SizedBox(height: 15),
            const Text("Com o que você trabalha? (Tags) *", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: allTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  selectedColor: Colors.orange[200],
                  onSelected: (bool selected) {
                    setState(() {
                      selected ? _selectedTags.add(tag) : _selectedTags.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: whatsappCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 15,
              decoration: const InputDecoration(labelText: "WhatsApp (XX) 9 XXXX-XXXX", border: OutlineInputBorder()),
            ),
            
            TextField(
              controller: descCtrl,
              maxLength: 255,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Descrição breve", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            const Text("Localização *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoadingLoc ? null : _getCurrentLocation,
                icon: _isLoadingLoc 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Icon(Icons.my_location),
                label: Text(_latitude == null ? "Usar Localização Atual" : "Localização Capturada!"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _latitude == null ? Colors.blue : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(), 
                    child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 15), side: const BorderSide(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 15),
                
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _saveRestaurant,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.green.withOpacity(0.6),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text("Salvar", style: TextStyle(color: Colors.white)),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}