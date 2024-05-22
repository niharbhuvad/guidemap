import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory PlaceModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final lat = data['position']['latitude'];
    final lng = data['position']['longitude'];
    return PlaceModel(
      id: snapshot.id,
      title: data['title'],
      position: LatLng(lat, lng),
    );
  }
}
