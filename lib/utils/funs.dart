import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidemap/models/area_model.dart';
import 'package:guidemap/models/place_model.dart';
import 'package:guidemap/models/route_model.dart';

void showSnackbar(BuildContext context, String txt) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(txt),
    ),
  );
}

bool isAuthenticated(BuildContext context) {
  return (FirebaseAuth.instance.currentUser != null);
}

Future<LatLng> getCurrentLocation() async {
  await Geolocator.requestPermission();

  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  return LatLng(position.latitude, position.longitude);
}

Future<void> setMapCamPos({
  required Completer<GoogleMapController> mapCtrl,
  required LatLng pos,
  double zoom = 14,
}) async {
  final ctrl = await mapCtrl.future;
  ctrl.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: zoom)));
}

void fitPolygonToMap(GoogleMapController controller, AreaModel areaModel) {
  controller.animateCamera(CameraUpdate.newLatLngBounds(
      getPolygonBounds(areaModel.regionPoints),
      20)); // Adjust padding as needed
}

LatLngBounds getPolygonBounds(List<LatLng> points) {
  double minLat = points[0].latitude;
  double minLng = points[0].longitude;
  double maxLat = points[0].latitude;
  double maxLng = points[0].longitude;

  for (final point in points) {
    minLat = math.min(minLat, point.latitude);
    minLng = math.min(minLng, point.longitude);
    maxLat = math.max(maxLat, point.latitude);
    maxLng = math.max(maxLng, point.longitude);
  }

  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}

LatLng getPolygonCenter(List<LatLng> points) {
  double minLat = points[0].latitude;
  double minLng = points[0].longitude;
  double maxLat = points[0].latitude;
  double maxLng = points[0].longitude;

  for (final point in points) {
    minLat = math.min(minLat, point.latitude);
    minLng = math.min(minLng, point.longitude);
    maxLat = math.max(maxLat, point.latitude);
    maxLng = math.max(maxLng, point.longitude);
  }

  return LatLng((minLat + maxLat) / 2.0, (minLng + maxLng) / 2.0);
}

Future<List<RouteModel>> fetchRoutes(String areaId) async {
  List<RouteModel> result = [];
  final docs = (await FirebaseFirestore.instance
          .collection('regions')
          .doc(areaId)
          .collection('routes')
          .get())
      .docs;
  for (var doc in docs) {
    result.add(RouteModel.fromSnapshot(doc));
  }
  return result;
}

Future<List<PlaceModel>> fetchPlaces(String areaId) async {
  List<PlaceModel> result = [];
  final docs = (await FirebaseFirestore.instance
          .collection('regions')
          .doc(areaId)
          .collection('places')
          .get())
      .docs;

  for (var doc in docs) {
    result.add(PlaceModel.fromSnapshot(doc));
  }
  return result;
}
