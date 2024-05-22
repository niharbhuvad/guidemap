import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidemap/utils/funs.dart';
import 'package:guidemap/utils/x_colors.dart';
import 'package:guidemap/utils/x_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Completer<GoogleMapController> mapCtrl = Completer();
  Set<Polygon> polygonSet = {};
  bool showAreas = true;

  @override
  void initState() {
    super.initState();
    getCurrentLocation().then((value) {
      setMapCamPos(mapCtrl: mapCtrl, pos: value).then((value) {
        getRegions();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          XWidgets.switchListTile(
            value: showAreas,
            text: 'Show Areas',
            onChanged: (value) => setState(() => showAreas = value),
          ),
          Expanded(
            child: Material(
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 3, color: XColors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.hardEdge,
              child: GoogleMap(
                onMapCreated: (controller) => mapCtrl.complete(controller),
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 12,
                ),
                myLocationEnabled: true,
                polygons: showAreas ? polygonSet : {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getRegions() async {
    Set<Polygon> result = <Polygon>{};
    final docs = (await FirebaseFirestore.instance
            .collection('regions')
            .where('owner_uid',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get())
        .docs;
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
            strokeWidth: 1,
            strokeColor: Colors.green.withOpacity(0.7),
            points: coordsList,
            consumeTapEvents: true,
            onTap: () {
              context.push('/view_region/${doc.id}');
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
