import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidemap/models/area_model.dart';
import 'package:guidemap/models/place_model.dart';
import 'package:guidemap/utils/funs.dart';
import 'package:guidemap/utils/x_colors.dart';

class AddRouteDialog extends StatefulWidget {
  final Function() close;
  final AreaModel areaModel;
  const AddRouteDialog({
    super.key,
    required this.close,
    required this.areaModel,
  });

  @override
  State<AddRouteDialog> createState() => _AddRouteDialogState();
}

class _AddRouteDialogState extends State<AddRouteDialog> {
  final titleCtrl = TextEditingController();

  Completer<GoogleMapController> mapCtrl = Completer();
  LatLng? middlePos;
  // bool isLoading = true;
  List<LatLng> ptsList = [];
  List<PlaceModel> placeList = [];
  Set<Marker> markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    fetchPlaces(widget.areaModel.id).then((value) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          placeList = value;
        });
        generateMarkers();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('New Route ${placeList.length}'),
          leading: IconButton(
            onPressed: () => widget.close(),
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  ptsList.removeLast();
                });
                generateMarkers();
              },
              icon: const Icon(Icons.undo),
            ),
            const SizedBox(width: 5),
            IconButton(
              icon: const Icon(Icons.location_searching),
              onPressed: () async {
                fitPolygonToMap((await mapCtrl.future), widget.areaModel);
              },
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () {
                onSubmit(context);
              },
              icon: const Icon(Icons.check),
            ),
            SizedBox(width: MediaQuery.of(context).size.width / 70),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Route Name',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Material(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 3, color: XColors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      mapCtrl.complete(controller);
                      fitPolygonToMap(controller, widget.areaModel);
                    },
                    initialCameraPosition: CameraPosition(
                      target: getPolygonCenter(widget.areaModel.regionPoints),
                      zoom: 17,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onTap: (arg) {
                      setState(() {
                        ptsList.add(arg);
                      });
                      generateMarkers();
                    },
                    markers: markers,
                    polygons: {
                      Polygon(
                        polygonId: const PolygonId('polygon_main'),
                        points: widget.areaModel.regionPoints,
                        fillColor: Colors.green.withOpacity(0.3),
                        strokeColor: Colors.green.withOpacity(0.7),
                        strokeWidth: 1,
                      ),
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('polyline_main'),
                        color: Colors.black,
                        width: 3,
                        points: ptsList,
                      ),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          onTap: () {
            setState(() {
              ptsList.add(place.position);
            });
            generateMarkers();
          },
        ),
      );
    }
    if (ptsList.isNotEmpty) {
      result.add(
        Marker(
          markerId: const MarkerId('marker_route_start'),
          icon: BitmapDescriptor.defaultMarker,
          position: ptsList[0],
          infoWindow: const InfoWindow(
            title: 'Route Start',
          ),
        ),
      );

      if (ptsList.length > 1) {
        result.add(
          Marker(
            markerId: const MarkerId('marker_route_end'),
            icon: BitmapDescriptor.defaultMarker,
            position: ptsList.last,
            infoWindow: const InfoWindow(
              title: 'Route End',
            ),
          ),
        );
      }
    }
    setState(() {
      markers = result;
    });
  }

  Future<void> onSubmit(BuildContext context) async {
    if (ptsList.length < 2) {
      showSnackbar(context, 'Choose 2 or more points to create route!');
      return;
    }
    if (titleCtrl.text.isEmpty) {
      showSnackbar(context, 'Route Name is required!');
      return;
    }
    final List<dynamic> list = List.generate(
        ptsList.length,
        (index) => {
              'latitude': ptsList[index].latitude,
              'longitude': ptsList[index].longitude,
            });
    await FirebaseFirestore.instance
        .collection('regions')
        .doc(widget.areaModel.id)
        .collection('routes')
        .add({
      'title': titleCtrl.text,
      'routes_points': list,
    });
    // ignore: use_build_context_synchronously
    showSnackbar(context, 'Route Added Successfully!');

    widget.close();
  }
}
