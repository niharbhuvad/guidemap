import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {
  final String id;
  final String title;
  final List<LatLng> routesPoints;
  RouteModel({
    required this.id,
    required this.title,
    required this.routesPoints,
  });

  factory RouteModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final List<LatLng> points = [];
    for (var pt in data['routes_points']) {
      final lat = pt['latitude'];
      final lng = pt['longitude'];
      points.add(LatLng(lat, lng));
    }
    return RouteModel(
      id: snapshot.id,
      title: data['title'],
      routesPoints: points,
    );
  }
}
