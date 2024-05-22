import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidemap/models/place_model.dart';
import 'package:guidemap/models/area_model.dart';
import 'package:guidemap/models/route_model.dart';
import 'package:guidemap/utils/funs.dart';
import 'package:guidemap/utils/x_colors.dart';

class ViewRegionScreen extends StatefulWidget {
  final String regionId;
  const ViewRegionScreen(this.regionId, {super.key});

  @override
  State<ViewRegionScreen> createState() => _ViewRegionScreenState();
}

class _ViewRegionScreenState extends State<ViewRegionScreen> {
  Completer<GoogleMapController> mapCtrl = Completer();
  AreaModel? areaModel;
  bool isMapLoading = true;
  Set<Polygon> polygonSet = {};
  List<PlaceModel> placeList = [];
  List<RouteModel> routeList = [];
  Set<Polyline> polylines = <Polyline>{};
  Set<Marker> markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getRegion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(placeList.length.toString() + (areaModel?.title ?? '')),
        actions: [
          if (areaModel != null)
            IconButton(
              icon: const Icon(Icons.location_searching),
              onPressed: () async {
                fitPolygonToMap((await mapCtrl.future), areaModel!);
              },
            ),
          SizedBox(width: MediaQuery.of(context).size.width / 70),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Material(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 3, color: XColors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: (isMapLoading && areaModel == null)
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (controller) {
                    mapCtrl.complete(controller);
                  },
                  initialCameraPosition:
                      const CameraPosition(target: LatLng(0, 0), zoom: 10),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  polygons: polygonSet,
                  markers: markers,
                  polylines: polylines,
                ),
        ),
      ),
    );
  }

  Future<void> getRegion() async {
    Set<Polygon> result = <Polygon>{};
    final doc = await FirebaseFirestore.instance
        .collection('regions')
        .doc(widget.regionId)
        .get();
    if (doc.exists) {
      areaModel = AreaModel.fromSnapshot(doc);
      result.add(
        Polygon(
          polygonId: PolygonId('polygon_${doc.id}'),
          fillColor: Colors.green.withOpacity(0.3),
          strokeWidth: 1,
          strokeColor: Colors.green.withOpacity(0.7),
          points: areaModel!.regionPoints,
        ),
      );
      polygonSet = result;
      isMapLoading = false;
      setState(() {});
      fitPolygonToMap(await mapCtrl.future, areaModel!);
      placeList = await fetchPlaces(widget.regionId);
      routeList = await fetchRoutes(widget.regionId);
      generateMarkers();
      generatePolylines();
    }
  }

  void generateMarkers() async {
    var result = <Marker>{};
    for (var place in placeList) {
      result.add(
        Marker(
          markerId: MarkerId('marker_place_${place.id}'),
          icon: BitmapDescriptor.defaultMarker,
          position: place.position,
          infoWindow: InfoWindow(title: place.title),
        ),
      );
    }
    // for (var route in routeList) {
    //   result.addAll([
    //     Marker(
    //       markerId: MarkerId('marker_route_${route.id}_start'),
    //       icon: BitmapDescriptor.defaultMarker,
    //       position: route.routesPoints.first,
    //     ),
    //     Marker(
    //       markerId: MarkerId('marker_route_${route.id}_end'),
    //       icon: BitmapDescriptor.defaultMarker,
    //       position: route.routesPoints.last,
    //     ),
    //   ]);
    // }
    setState(() {
      markers = result;
    });
  }

  void generatePolylines() {
    var result = <Polyline>{};
    for (var route in routeList) {
      result.add(
        Polyline(
          polylineId: PolylineId('polyline_${route.id}'),
          points: route.routesPoints,
          width: 3,
          consumeTapEvents: true,
        ),
      );
    }
    setState(() {
      polylines = result;
    });
  }
}
