import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidemap/router_config.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  Completer<GoogleMapController> controller = Completer();
  LatLng? currentPosition;
  bool isLoading = true;
  Set<Polygon> polygonSet = {};

  @override
  void initState() {
    super.initState();
    getCurrentLocation().then((value) {
      getRegions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? const Center(child: CircularProgressIndicator())
        : GoogleMap(
            onMapCreated: (controller) {
              this.controller.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: currentPosition!,
              zoom: 17,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            polygons: polygonSet,
          );
  }

  Future<void> getCurrentLocation() async {
    await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    setState(() {
      currentPosition = location;
      isLoading = false;
    });
    return;
  }

  Future<void> getRegions() async {
    Set<Polygon> result = <Polygon>{};
    final docs =
        (await FirebaseFirestore.instance.collection('regions').get()).docs;
    for (int i = 0; i < docs.length; i++) {
      var doc = docs[i];
      if (doc.exists) {
        List<LatLng> coordsList = [];
        List<dynamic> regionPoints = doc['region_points'];
        for (var j = 0; j < regionPoints.length; j++) {
          coordsList.add(LatLng(
            regionPoints[j]['latitude'],
            regionPoints[j]['longitude'],
          ));
        }
        result.add(
          Polygon(
            polygonId: PolygonId('polygon_${doc.id}'),
            fillColor: Colors.green.withOpacity(0.3),
            strokeWidth: 2,
            points: coordsList,
            consumeTapEvents: true,
            onTap: () {
              beamerDel.beamToNamed('/view_region/${doc.id}');
            },
          ),
        );
      }
    }
    setState(() {
      polygonSet = result;
    });
  }
}
