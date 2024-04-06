import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidemap/router_config.dart';
import 'package:guidemap/screens/models/place_model.dart';
import 'package:guidemap/screens/models/position_point_model.dart';
import 'package:guidemap/screens/models/region_model.dart';
import 'package:guidemap/screens/models/route_model.dart';

class ViewRegionScreen extends StatefulWidget {
  final String regionId;
  const ViewRegionScreen(this.regionId, {super.key});

  @override
  State<ViewRegionScreen> createState() => _ViewRegionScreenState();
}

class _ViewRegionScreenState extends State<ViewRegionScreen> {
  // int selectedIndex = 0;
  Completer<GoogleMapController> controller = Completer();
  LatLng? currentPosition;
  bool isMapLoading = true;
  Set<Polygon> polygonSet = {};
  RegionModel? regionModel;
  List<PlaceModel> placeList = [];
  List<RouteModel> routeList = [];
  Set<Polyline> polylines = <Polyline>{};
  Set<Marker> markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getRegion().then((value) {
      fetchPlaces();
      fetchRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Region'),
        leading: IconButton(
          onPressed: () {
            beamerDel.beamBack();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              refreshMapItems();
            },
            icon: const Icon(Icons.refresh_sharp),
          ),
        ],
      ),
      body: Container(
        child: (isMapLoading)
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
                markers: markers,
                polylines: polylines,
              ),
      ),
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
      isMapLoading = false;
    });
    return;
  }

  Future<void> getRegion() async {
    Set<Polygon> result = <Polygon>{};

    final doc = await FirebaseFirestore.instance
        .collection('regions')
        .doc(widget.regionId)
        .get();
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
        ),
      );
      regionModel = RegionModel(
        id: doc.id,
        title: doc['title'],
        desc: doc['desc'],
        regionPoints: coordsList,
      );
      setState(() {
        polygonSet = result;
      });
    }
  }

  void fetchPlaces() async {
    final docs = (await FirebaseFirestore.instance
            .collection('regions')
            .doc(regionModel!.id)
            .collection('places')
            .get())
        .docs;

    List<PlaceModel> result = [];
    for (int i = 0; i < docs.length; i++) {
      var doc = docs[i];
      if (doc.exists) {
        LatLng pos = LatLng(
          doc['position']['latitude'],
          doc['position']['longitude'],
        );
        result.add(
          PlaceModel(
            id: doc.id,
            title: doc['title'],
            position: pos,
          ),
        );
      }
    }
    setState(() {
      placeList = result;
    });
    generateMarkers();
  }

  void generateMarkers() {
    var result = <Marker>{};
    for (int index = 0; index < placeList.length; index++) {
      result.add(
        Marker(
            markerId: MarkerId('marker_${index + 1}'),
            icon: BitmapDescriptor.defaultMarker,
            position: placeList[index].position,
            infoWindow: InfoWindow(title: placeList[index].title)),
      );
    }
    setState(() {
      markers = result;
    });
  }

  void generatePolylines() {
    var result = <Polyline>{};
    for (var i = 0; i < routeList.length; i++) {
      List<LatLng> list = List.generate(routeList[i].routesPoints.length,
          (index) => routeList[i].routesPoints[index].position);
      result.add(
        Polyline(
          polylineId: PolylineId('polyline_${i + 1}'),
          points: list,
          width: 3,
        ),
      );
    }
    setState(() {
      polylines = result;
    });
  }

  void fetchRoutes() async {
    final docs = (await FirebaseFirestore.instance
            .collection('regions')
            .doc(regionModel!.id)
            .collection('routes')
            .get())
        .docs;
    List<RouteModel> result = [];
    for (int i = 0; i < docs.length; i++) {
      var doc = docs[i];
      if (doc.exists) {
        List<PositionPointModel> list = [];
        List<dynamic> points = doc['routes_points'];
        for (var j = 0; j < points.length; j++) {
          var pos = points[j]['position'];
          list.add(
            PositionPointModel(
              note: points[j]['note'],
              position: LatLng(
                pos['latitude'],
                pos['longitude'],
              ),
            ),
          );
        }
        result.add(RouteModel(
          id: doc.id,
          title: doc['title'],
          routesPoints: list,
        ));
      }
    }
    setState(() {
      routeList = result;
    });
    generatePolylines();
  }

  void refreshMapItems() {
    fetchPlaces();
    fetchRoutes();
  }
}
