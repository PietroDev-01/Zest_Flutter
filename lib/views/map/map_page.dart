import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../controllers/restaurant_controller.dart';
import '../../models/restaurant_model.dart';
import '../widgets/restaurant_details_sheet.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/search_dialog.dart';

class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final RestaurantController resController = Get.find();
  GoogleMapController? mapController;
  final LatLng _initialPosition = const LatLng(-5.090333, -42.810688);

  @override
  void initState() {
    super.initState();

    ever(resController.restaurantToFocus, (RestaurantModel? restaurant) async {
      if (restaurant != null) {
        int tries = 0;
        while (mapController == null && tries < 20) {
          await Future.delayed(const Duration(milliseconds: 100));
          tries++;
        }

        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(restaurant.latitude, restaurant.longitude),
              18,
            ),
          );
        }
        resController.restaurantToFocus.value = null;
      }
    });
  }

  Future<void> _goToUserLocation() async {
    if (resController.restaurantToFocus.value != null) {
      print("Bloqueando ida ao usuário pois há foco pendente.");
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition();
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    } catch (e) {
      print("Erro ao pegar localização: $e");
    }
  }

  void _showRestaurantDetails(RestaurantModel restaurant) {
    Get.bottomSheet(
      RestaurantDetailsSheet(restaurant: restaurant, isFromHome: false),
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final Set<Marker> markers = resController.displayedRestaurants.map((
          restaurant,
        ) {
          return Marker(
            markerId: MarkerId(restaurant.id),
            position: LatLng(restaurant.latitude, restaurant.longitude),
            infoWindow: InfoWindow(
              title: restaurant.name,
              snippet: "Toque para ver Detalhes e Definir Rota!",
              onTap: () => _showRestaurantDetails(restaurant),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          );
        }).toSet();

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12,
              ),
              onMapCreated: (controller) {
                mapController = controller;
                if (resController.restaurantToFocus.value == null) {
                  _goToUserLocation();
                }
              },
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),

            Positioned(
              right: 16,
              bottom: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Botão Busca
                  Obx(() {
                    bool isActive =
                        resController.currentSearch.value.isNotEmpty;
                    return FloatingActionButton.small(
                      heroTag: "map_search",
                      backgroundColor: isActive ? Colors.blue : Colors.white,
                      child: Icon(
                        Icons.search,
                        color: isActive ? Colors.white : Colors.blue,
                      ),
                      onPressed: () => showCustomSearchDialog(),
                    );
                  }),
                  const SizedBox(height: 10),

                  // Botão Filtro
                  Obx(() {
                    bool isActive =
                        resController.activeTags.isNotEmpty ||
                        resController.filterOpenNow.value;
                    return FloatingActionButton.small(
                      heroTag: "map_filter",
                      backgroundColor: isActive ? Colors.orange : Colors.white,
                      child: Icon(
                        Icons.filter_list,
                        color: isActive ? Colors.white : Colors.purple,
                      ),
                      onPressed: () {
                        Get.bottomSheet(
                          FilterSheet(isMap: true),
                          isScrollControlled: true,
                          barrierColor: Colors.black.withOpacity(0.2),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),

            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                heroTag: "map_location",
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Colors.orange),
                onPressed: _goToUserLocation,
              ),
            ),
          ],
        );
      }),
    );
  }
}