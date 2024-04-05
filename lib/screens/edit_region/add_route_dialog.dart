import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidemap/functions.dart';
import 'package:guidemap/screens/models/place_model.dart';
import 'package:guidemap/screens/models/region_model.dart';

class AddRouterDialog extends StatefulWidget {
  final RegionModel regionModel;
  final Function() close;
  const AddRouterDialog({
    super.key,
    required this.close,
    required this.regionModel,
  });

  @override
  State<AddRouterDialog> createState() => _AddRouterDialogState();
}

class _AddRouterDialogState extends State<AddRouterDialog> {
  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  Completer<GoogleMapController> controller = Completer();
  LatLng? currentPosition;
  bool isMapLoading = true;
  Set<Polygon> polygonSet = {};
  List<Map<String, Object>> routePoints = [];
  List<PlaceModel> placeList = [];
  List<LatLng> ptsList = [];
  LatLng? startPos;
  LatLng? endPos;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    fetchPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Route ${routePoints.length}'),
          leading: IconButton(
            onPressed: () {
              widget.close();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title is required!';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Route Name'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Set Route'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                    ),
                    height: 450,
                    child: isMapLoading
                        ? const Center(child: CircularProgressIndicator())
                        : GoogleMap(
                            zoomGesturesEnabled: true,
                            initialCameraPosition: CameraPosition(
                              target: currentPosition!,
                              zoom: 17,
                            ),
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                            markers: markers,
                            polygons: {
                              Polygon(
                                polygonId: const PolygonId('polygon_main'),
                                fillColor: Colors.green.withOpacity(0.3),
                                points: widget.regionModel.regionPoints,
                                strokeWidth: 3,
                              ),
                            },
                            polylines: {
                              Polyline(
                                polylineId: const PolylineId('route_main'),
                                width: 3,
                                startCap: Cap.roundCap,
                                endCap: Cap.roundCap,
                                points: ptsList,
                              ),
                            },
                          ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Place Name or Route Point Note'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  getActionBtns(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getActionBtns(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: ElevatedButton(
            onPressed: () async {
              addAsPlace(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text('Add as Place'),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: ElevatedButton(
            onPressed: () async {
              final currentPos = await getCurrentPosLatLng();
              addRoutePoint(currentPos);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text('Add Route Point'),
          ),
        ),
      ],
    );
  }

  List<LatLng> getLatLngList(List<Map<String, Object>> list) {
    return List.generate(list.length, (index) {
      LatLng pos = list[index]['position'] as LatLng;
      return LatLng(pos.latitude, pos.longitude);
    });
  }

  Future<LatLng> getCurrentPosLatLng() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
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

  void addRoutePoint(LatLng point) {
    if (startPos != null && endPos != null) {
      showSnackbar(
        context,
        'Route Selected, delete a point to continue another road!',
      );
      return;
    }
    if (startPos == null) {
      startPos = point;
      generateMarkers();
    }
    if (endPos == null) {
      endPos = point;
      generateMarkers();
    }
    routePoints.add({
      'note': noteCtrl.text,
      'position': point,
    });
    setState(() {
      ptsList = getLatLngList(routePoints);
    });
  }

  void addAsPlace(BuildContext context) async {
    if (noteCtrl.text.isNotEmpty) {
      final currentPos = await getCurrentPosLatLng();
      await FirebaseFirestore.instance
          .collection('regions')
          .doc(widget.regionModel.id)
          .collection('places')
          .add({
        'title': noteCtrl.text,
        'position': {
          'latitude': currentPos.latitude,
          'longitude': currentPos.longitude,
        }
      });
      fetchPlaces();
    } else {
      showSnackbar(context, 'Place Name is required!');
    }
  }

  void fetchPlaces() async {
    final docs = (await FirebaseFirestore.instance
            .collection('regions')
            .doc(widget.regionModel.id)
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

  void generateMarkers() async {
    var result = <Marker>{};
    for (int index = 0; index < placeList.length; index++) {
      result.add(
        Marker(
          markerId: MarkerId('marker_${index + 1}'),
          icon: BitmapDescriptor.defaultMarker,
          position: placeList[index].position,
          infoWindow: InfoWindow(
            title: placeList[index].title,
          ),
          onTap: () {
            if (startPos == null) {
              // startPos = placeList[index].position;
              addRoutePoint(placeList[index].position);
              return;
            }
            if (endPos == null) {
              endPos = placeList[index].position;
              addRoutePoint(placeList[index].position);
              return;
            }
          },
        ),
      );
    }
    if (startPos != null) {
      result.add(
        Marker(
          markerId: const MarkerId('start_point_marker'),
          icon: BitmapDescriptor.defaultMarker,
          position: startPos!,
        ),
      );
    }
    setState(() {
      markers = result;
    });
  }
}
