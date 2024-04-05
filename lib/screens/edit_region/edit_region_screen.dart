import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidemap/router_config.dart';
import 'package:guidemap/screens/edit_region/add_route_dialog.dart';
import 'package:guidemap/screens/models/region_model.dart';

class EditRegionScreen extends StatefulWidget {
  final String regionId;
  const EditRegionScreen(this.regionId, {super.key});

  @override
  State<EditRegionScreen> createState() => _EditRegionScreenState();
}

class _EditRegionScreenState extends State<EditRegionScreen> {
  int selectedIndex = 0;
  Completer<GoogleMapController> controller = Completer();
  LatLng? currentPosition;
  bool isMapLoading = true;
  Set<Polygon> polygonSet = {};
  RegionModel? regionModel;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getRegion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Region'),
        leading: IconButton(
          onPressed: () {
            beamerDel.beamBack();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      bottomNavigationBar: getBottombar(),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          Container(
            child: (regionModel == null)
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : getOverviewList(),
          ),
          Container(
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
                  ),
          ),
        ],
      ),
    );
  }

  ListView getOverviewList() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          regionModel!.title,
          maxLines: 2,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          regionModel!.desc,
          maxLines: 7,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 16,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Routes',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                addRoute();
              },
              icon: const Icon(
                Icons.add_circle,
                size: 30,
              ),
            ),
          ],
        ),
      ],
    );
  }

  NavigationBar getBottombar() {
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard),
          label: 'Overview',
        ),
        NavigationDestination(
          icon: Icon(Icons.map),
          label: 'Region',
        ),
      ],
      onDestinationSelected: (value) {
        setState(() {
          selectedIndex = value;
        });
      },
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

  void addRoute() async {
    showDialog(
      context: context,
      builder: (context) {
        return AddRouterDialog(
          close: () => Navigator.pop(context),
          regionModel: regionModel!,
        );
      },
    );
  }
}
