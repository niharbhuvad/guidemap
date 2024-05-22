import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidemap/utils/funs.dart';

class ChooseRegionDialog extends StatefulWidget {
  final Function(List<LatLng>? pts) close;
  const ChooseRegionDialog(this.close, {super.key});

  @override
  State<ChooseRegionDialog> createState() => _ChooseRegionDialogState();
}

class _ChooseRegionDialogState extends State<ChooseRegionDialog> {
  Completer<GoogleMapController> controller = Completer();
  LatLng? currentPosition;
  bool isLoading = true;
  List<LatLng> ptsList = [];
  Set<Marker> markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    getCurrentLocation().then((value) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          currentPosition = value;
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose Area'),
          leading: IconButton(
            onPressed: () => widget.close(null),
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
              onPressed: () {
                onSubmit(context);
              },
              icon: const Icon(Icons.check),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
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
                onTap: (argument) {
                  if (ptsList.isNotEmpty) {
                    if (ptsList[0] == argument) {}
                  }
                  setState(() {
                    ptsList.add(argument);
                  });
                  generateMarkers();
                },
                markers: markers,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('polyline_main'),
                    color: Colors.black,
                    width: 3,
                    points: ptsList,
                  ),
                  Polyline(
                    polylineId: const PolylineId('polyline_end'),
                    color: Colors.grey.shade400,
                    width: 5,
                    points: (ptsList.length > 2)
                        ? [
                            ptsList[0],
                            ptsList[ptsList.length - 1],
                          ]
                        : [],
                  ),
                },
              ),
      ),
    );
  }

  void generateMarkers() async {
    var result = <Marker>{};
    for (int index = 0; index < ptsList.length; index++) {
      result.add(
        Marker(
          markerId: MarkerId('marker_${index + 1}'),
          icon: BitmapDescriptor.defaultMarker,
          position: ptsList[index],
          infoWindow: InfoWindow(
            title: 'Marker ${index + 1}',
          ),
        ),
      );
    }
    setState(() {
      markers = result;
    });
  }

  void onSubmit(BuildContext context) {
    if (ptsList.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose 3 or more points to create region!'),
        ),
      );
      return;
    }
    widget.close(ptsList);
  }
}
