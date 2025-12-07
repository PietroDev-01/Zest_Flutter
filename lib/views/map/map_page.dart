import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../controllers/restaurant_controller.dart';
import '../../models/restaurant_model.dart';
import '../widgets/restaurant_details_sheet.dart';

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
    _goToUserLocation();
    ever(resController.restaurantToFocus, (RestaurantModel? restaurant) {
      if (restaurant != null && mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(restaurant.latitude, restaurant.longitude),
            18,
          ),
        );
        resController.restaurantToFocus.value = null;
      }
    });
  }

  Future<void> _goToUserLocation() async {
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
      RestaurantDetailsSheet(
        restaurant: restaurant,
        isFromHome: false
        ),
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final Set<Marker> markers = resController.restaurants.map((restaurant) {
          return Marker(
            markerId: MarkerId(restaurant.id),
            position: LatLng(restaurant.latitude, restaurant.longitude),
            infoWindow: InfoWindow(
              title: restaurant.name,
              snippet: "Toque para ver detalhes",
              onTap: () => _showRestaurantDetails(restaurant),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          );
        }).toSet();

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 12),
              onMapCreated: (controller) => mapController = controller,
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
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