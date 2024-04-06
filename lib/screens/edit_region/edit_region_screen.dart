import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidemap/router_config.dart';
import 'package:guidemap/screens/edit_region/add_route_dialog.dart';
import 'package:guidemap/screens/models/place_model.dart';
import 'package:guidemap/screens/models/position_point_model.dart';
import 'package:guidemap/screens/models/region_model.dart';
import 'package:guidemap/screens/models/route_model.dart';

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
        title: const Text('Edit Region'),
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
                    markers: markers,
                    polylines: polylines,
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
        Column(
          children: List.generate(
            routeList.length,
            (index) {
              return getRoutesListItem(routeList[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget getRoutesListItem(RouteModel routeModel) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = 1;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        margin: const EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                routeModel.title,
                maxLines: 2,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 5),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
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
          strokeWidth: 1,
          strokeColor: Colors.green.withOpacity(0.7),
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
