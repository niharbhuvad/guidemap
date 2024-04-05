import 'package:google_maps_flutter/google_maps_flutter.dart';

class RegionModel {
  String id;
  String title;
  String desc;
  List<LatLng> regionPoints;
  RegionModel({
    required this.id,
    required this.title,
    required this.desc,
    required this.regionPoints,
  });
}
