import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  final String id;
  final String title;
  final LatLng position;
  PlaceModel({
    required this.id,
    required this.title,
    required this.position,
  });
}
