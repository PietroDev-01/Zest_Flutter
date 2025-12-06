class RestaurantModel {
  String id;
  String ownerId;
  String name;
  String description;
  String logoUrl;
  List<String> tags;
  String whatsapp;
  double latitude;
  double longitude;
  String openTime;
  String closeTime;

  RestaurantModel ({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.tags,
    required this.whatsapp,
    required this.latitude,
    required this.longitude,
    required this.openTime,
    required this.closeTime
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'tags': tags,
      'whatsapp': whatsapp,
      'latitude': latitude,
      'longitude': longitude,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  factory RestaurantModel.fromMap(Map<String, dynamic> map, String docId) {
    return RestaurantModel(
      id: docId, 
      ownerId: map['ownerId'] ?? '', 
      name: map['name'] ?? '', 
      description: map['description'] ?? '', 
      logoUrl: map['logoUrl'] ?? '', 
      tags: List<String>.from(map['tags'] ?? []), 
      whatsapp: map['whatsapp'] ?? '', 
      latitude: map['latitude']?.toDouble() ?? 0.0, 
      longitude: map['longitude']?.toDouble() ?? 0.0, 
      openTime: map['openTime'] ?? '', 
      closeTime: map['closeTime'] ?? '',
    );
  }
}