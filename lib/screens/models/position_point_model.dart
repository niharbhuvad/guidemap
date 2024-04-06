import 'package:google_maps_flutter/google_maps_flutter.dart';

class PositionPointModel {
  final String note;
  final LatLng position;
  PositionPointModel({
    required this.note,
    required this.position,
  });
}
