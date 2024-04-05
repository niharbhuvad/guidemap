import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guidemap/router_config.dart';
import 'package:guidemap/screens/add_region/choose_region_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddRegionScreen extends StatefulWidget {
  const AddRegionScreen({super.key});

  @override
  State<AddRegionScreen> createState() => _AddRegionScreenState();
}

class _AddRegionScreenState extends State<AddRegionScreen> {
  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  List<LatLng> ptsList = [];
  Set<Marker> markers = <Marker>{};
  bool submitLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Region'),
        leading: IconButton(
          onPressed: () {
            beamerDel.beamBack();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          bottom: 10,
          left: 20,
          right: 20,
        ),
        child: ElevatedButton(
          onPressed: () {
            createRegion(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: submitLoading
              ? const CircularProgressIndicator()
              : const Text('Create Region'),
        ),
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          physics: const NeverScrollableScrollPhysics(),
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
                label: Text('Region Name'),
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
                label: Text('Region Description'),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Choose Region'),
            const SizedBox(height: 15),
            (ptsList.isEmpty)
                ? chooseRegionBtn()
                : Container(
                    height: 200,
                    clipBehavior: Clip.hardEdge,
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: ptsList[0],
                        zoom: 17,
                      ),
                      polygons: {
                        Polygon(
                          polygonId: const PolygonId('polygon_main'),
                          fillColor: Colors.green.withOpacity(0.3),
                          // visible: true,
                          strokeWidth: 3,
                          points: ptsList,
                        ),
                      },
                    ),
                  ),
          ],
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
  }

  ElevatedButton chooseRegionBtn() {
    return ElevatedButton.icon(
      onPressed: () {
        chooseRegion();
      },
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
            content: Text('Please choose the region first!'),
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
            'region_points': regionPoints,
          });
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Region Added Successfully!'),
            ),
          );
          beamerDel.beamBack();
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
