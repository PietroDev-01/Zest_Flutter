import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/restaurant_controller.dart';
import '../../models/restaurant_model.dart';

class AddRestaurantPage extends StatefulWidget {
  final RestaurantModel? restaurantToEdit;
  
  const AddRestaurantPage({super.key, this.restaurantToEdit});

  @override
  State<AddRestaurantPage> createState() => _AddRestaurantPageState();
}

class _AddRestaurantPageState extends State<AddRestaurantPage> {
  // --- CONTROLADORES ---
  final RestaurantController controller = Get.find();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final whatsappCtrl = TextEditingController();
  final openTimeCtrl = TextEditingController();
  final closeTimeCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  
  // --- MÁSCARAS DE FORMATAÇÃO ---
  final maskTime = MaskTextInputFormatter(mask: '##:##', filter: { "#": RegExp(r'[0-9]') });
  final maskPhone = MaskTextInputFormatter(mask: '(##) 9 ####-####', filter: { "#": RegExp(r'[0-9]') });

  // --- VARIÁVEIS DE ESTADO ---
  File? _selectedImage;
  String _base64Image = "";
  final List<String> _selectedTags = [];
  bool _isLoadingLoc = false;
  double? _latitude;
  double? _longitude;

  // --- LISTA DE TAGS ---
  final List<String> allTags = [
    "Pizzaria", "Hamburgueria", "Massas", "Comida Brasileira", 
    "Sorveteria", "Açaí", "Salgado", "Churrasco", "Bebida", 
    "Comida Caseira", "Sushi", "Lanche",
  ];

  // --- CICLO DE VIDA (INIT) ---
  @override
  void initState() {
    super.initState();
    // Se for edição, preenche os campos com os dados existentes
    if (widget.restaurantToEdit != null) {
      final r = widget.restaurantToEdit!;
      nameCtrl.text = r.name;
      descCtrl.text = r.description;
      whatsappCtrl.text = r.whatsapp;
      openTimeCtrl.text = r.openTime;
      closeTimeCtrl.text = r.closeTime;
      _base64Image = r.logoUrl;
      _selectedTags.addAll(r.tags);
      _latitude = r.latitude;
      _longitude = r.longitude;
    }
  }

  // --- FUNÇÕES DE LÓGICA ---

  // 1. Selecionar Imagem
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery, 
      imageQuality: 25, 
      maxWidth: 600
    );
    
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _selectedImage = File(pickedFile.path);
        _base64Image = base64Encode(bytes);
      });
    }
  }

  // 2. Buscar Localização por GPS
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLoc = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Erro", "Ligue o GPS.");
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        addressCtrl.text = "Localização GPS Capturada";
      });
      Get.snackbar("Sucesso", "GPS Capturado!", backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar("Erro", "Falha no GPS: $e");
    } finally {
      setState(() => _isLoadingLoc = false);
    }
  }

  // 3. Buscar Localização por Endereço
  Future<void> _getManualLocation() async {
    if (addressCtrl.text.isEmpty) {
      Get.snackbar("Atenção", "Digite um endereço ou CEP para buscar.");
      return;
    }
    setState(() => _isLoadingLoc = true);
    try {
      List<Location> locations = await locationFromAddress(addressCtrl.text);
      
      if (locations.isNotEmpty) {
        setState(() {
          _latitude = locations.first.latitude;
          _longitude = locations.first.longitude;
        });
        Get.snackbar("Encontrado", "Endereço localizado no mapa!", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Erro", "Endereço não encontrado.");
      }
    } catch (e) {
      Get.snackbar("Erro", "Não foi possível achar esse endereço.");
    } finally {
      setState(() => _isLoadingLoc = false);
    }
  }

  // 4. Salvar ou Atualizar Restaurante
  void _saveRestaurant() {
    if (nameCtrl.text.isEmpty || _selectedTags.isEmpty || _latitude == null) {
      Get.snackbar("Atenção", "Preencha Nome, Tags e Localização", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    
    final restaurantData = RestaurantModel(
      id: widget.restaurantToEdit?.id ?? "",
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

    if (widget.restaurantToEdit != null) {
      controller.updateRestaurant(restaurantData); // ATUALIZA
    } else {
      controller.addRestaurant(restaurantData); // CRIA NOVO
    }
  }

  // --- INTERFACE (BUILD) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastre seu Restaurante")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dados Principais", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 1. NOME
            const Text("Nome do Estabelecimento *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: nameCtrl,
              maxLength: 50,
              decoration: const InputDecoration(labelText: "Inserir Nome", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // 2. LOGO
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 135,
                  height: 135,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange, width: 2),
                    image: _selectedImage != null
                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                        : (_base64Image.isNotEmpty 
                            ? DecorationImage(image: controller.getImageProvider(_base64Image), fit: BoxFit.cover)
                            : null),
                  ),
                  child: (_selectedImage == null && _base64Image.isEmpty)
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const Center(child: Text("Logo", style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 20),

            // 3. HORÁRIOS COM MÁSCARA
            const Text("Horário De Funcionamento", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(child: TextField(
                  controller: openTimeCtrl,
                  inputFormatters: [maskTime],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Abre (ex: 18:00)", border: OutlineInputBorder())
                )),
                const SizedBox(width: 10),
                Expanded(child: TextField(
                  controller: closeTimeCtrl,
                  inputFormatters: [maskTime],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Fecha (ex: 23:00)", border: OutlineInputBorder())
                )),
              ],
            ),
            const SizedBox(height: 15),

            // 4. WHATSAPP COM MÁSCARA
            const Text("Whatsapp de Atendimento", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: whatsappCtrl,
              inputFormatters: [maskPhone],
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Whatsapp", 
                hintText: "(86) 9 9999-9999",
                prefixIcon: Icon(Icons.phone, color: Colors.green),
                border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 15),

            // 5. TAGS
            const Text("Categorias *", style: TextStyle(fontWeight: FontWeight.bold)),
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

            // DESCRIÇÃO
            const Text("Descrição", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: descCtrl,
              maxLength: 255,
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Descreva Seu Restaurante", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // 6. LOCALIZAÇÃO HÍBRIDA
            const Text("Localização *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            
            // Campo de Texto para Endereço Manual
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: "Digite Endereço ou CEP",
                      hintText: "Ex: Av. Frei Serafim, Teresina",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Botão de Buscar Endereço Manual
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.blue),
                    tooltip: "Buscar no Mapa",
                    onPressed: _isLoadingLoc ? null : _getManualLocation,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            const Center(child: Text("- OU USE O GPS -", style: TextStyle(color: Colors.grey, fontSize: 12))),
            const SizedBox(height: 15),

            // Botão de Usar a Localização Atual
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoadingLoc ? null : _getCurrentLocation,
                icon: _isLoadingLoc 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Icon(Icons.my_location, color: Colors.white),
                label: Text(
                  _latitude == null ? "Usar Localização Atual" : "Localização Capturada!",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _latitude == null ? Colors.blue : Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            if (_latitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("✅ Coordenadas salvas: $_latitude, $_longitude", style: TextStyle(color: Colors.green[700], fontSize: 12)),
              ),
            
            const SizedBox(height: 30),

            // BOTÃO SALVAR
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveRestaurant,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  widget.restaurantToEdit != null ? "Atualizar Dados" : "Salvar Restaurante", 
                  style: const TextStyle(color: Colors.white, fontSize: 18)
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}