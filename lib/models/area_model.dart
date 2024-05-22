import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AreaModel {
  final String id;
  final String title;
  final String desc;
  final String ownerUid;
  final Timestamp timestamp;
  final List<LatLng> regionPoints;
  AreaModel({
    required this.id,
    required this.title,
    required this.desc,
    required this.ownerUid,
    required this.timestamp,
    required this.regionPoints,
  });

  factory AreaModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final List<LatLng> points = [];
    for (var pt in data['region_points']) {
      points.add(LatLng(pt['latitude'], pt['longitude']));
    }
    return AreaModel(
      id: snapshot.id,
      title: data['title'],
      desc: data['desc'],
      ownerUid: data['owner_uid'],
      timestamp: data['timestamp'],
      regionPoints: points,
    );
  }
}
