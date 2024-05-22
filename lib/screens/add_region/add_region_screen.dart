import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guidemap/screens/add_region/choose_region_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidemap/utils/funs.dart';
import 'package:guidemap/utils/x_colors.dart';
import 'package:guidemap/utils/x_widgets.dart';

class AddRegionScreen extends StatefulWidget {
  const AddRegionScreen({super.key});

  @override
  State<AddRegionScreen> createState() => _AddRegionScreenState();
}

class _AddRegionScreenState extends State<AddRegionScreen> {
  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  Completer<GoogleMapController> mapCtrl = Completer();

  List<LatLng> ptsList = [];
  Set<Marker> markers = <Marker>{};
  bool submitLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Area'),
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
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
                    label: Text('Area Name'),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: descCtrl,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required!';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('Area Description'),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Choose Area'),
                const SizedBox(height: 10),
                (ptsList.isEmpty)
                    ? chooseRegionBtn()
                    : SizedBox(
                        height: 200,
                        child: Material(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 3, color: XColors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          // height: 200,
                          clipBehavior: Clip.hardEdge,
                          child: GoogleMap(
                            onMapCreated: (controller) {
                              mapCtrl.complete(controller);
                            },
                            initialCameraPosition: CameraPosition(
                              target: ptsList[0],
                              zoom: 14,
                            ),
                            polygons: {
                              Polygon(
                                polygonId: const PolygonId('polygon_main'),
                                fillColor: Colors.green.withOpacity(0.3),
                                strokeWidth: 3,
                                points: ptsList,
                              ),
                            },
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                XWidgets.textBtn(
                  text: 'Create New Area',
                  loading: submitLoading,
                  onPressed: () => createRegion(context),
                )
              ],
            ),
          ),
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
        ),
      );
    }
    setState(() {
      markers = result;
    });
    (await mapCtrl.future).animateCamera(
      CameraUpdate.newLatLngBounds(getPolygonBounds(ptsList), 20),
    );
  }

  ElevatedButton chooseRegionBtn() {
    return ElevatedButton.icon(
      onPressed: () => chooseRegion(),
      icon: const Icon(Icons.add_location),
      label: const Text('Choose'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade500,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 50,
          horizontal: 20,
        ),
      ),
    );
  }

  void chooseRegion() async {
    List<LatLng>? result = await showDialog(
      context: context,
      builder: (context) {
        return ChooseRegionDialog((pts) => Navigator.pop(context, pts));
      },
    );
    if (result != null) {
      setState(() {
        ptsList = result;
        generateMarkers();
      });
    }
  }

  LatLng getCenter() {
    LatLng centroid = const LatLng(0, 0);

    for (int i = 0; i < ptsList.length; i++) {
      var newPt = LatLng(
        centroid.latitude + ptsList[i].latitude,
        centroid.longitude + ptsList[i].longitude,
      );
      centroid = newPt;
    }

    var newPt = LatLng(
      centroid.latitude / ptsList.length,
      centroid.longitude / ptsList.length,
    );
    centroid = newPt;

    return centroid;
  }

  void createRegion(BuildContext context) async {
    setState(() {
      submitLoading = true;
    });
    if (formKey.currentState!.validate()) {
      if (ptsList.isEmpty || ptsList.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please choose the area first!'),
          ),
        );
      } else {
        try {
          final regionPoints = List.generate(ptsList.length, (index) {
            return {
              'latitude': ptsList[index].latitude,
              'longitude': ptsList[index].longitude,
            };
          });
          await FirebaseFirestore.instance.collection('regions').add({
            'title': titleCtrl.text,
            'desc': descCtrl.text,
            'owner_uid': FirebaseAuth.instance.currentUser!.uid,
            'region_points': regionPoints,
            'timestamp': Timestamp.now(),
          });
          // ignore: use_build_context_synchronously
          showSnackbar(context, 'Area Added Successfully!');
          // ignore: use_build_context_synchronously
          context.pop();
          return;
        } catch (e) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
        }
      }
    }
    setState(() {
      submitLoading = false;
    });
  }
}
