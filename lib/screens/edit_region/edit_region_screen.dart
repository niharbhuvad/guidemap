import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guidemap/screens/edit_region/add_route_dialog.dart';
import 'package:guidemap/models/area_model.dart';
import 'package:guidemap/models/route_model.dart';
import 'package:guidemap/screens/error_page.dart';
import 'package:guidemap/utils/x_colors.dart';

class EditRegionScreen extends StatefulWidget {
  final String regionId;
  const EditRegionScreen(this.regionId, {super.key});

  @override
  State<EditRegionScreen> createState() => _EditRegionScreenState();
}

class _EditRegionScreenState extends State<EditRegionScreen> {
  AreaModel? areaModel;
  bool readMore = false;

  @override
  void initState() {
    super.initState();
    getRegion();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(areaModel?.title ?? ''),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Routes'),
              Tab(text: 'Places'),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              onPressed: () {},
              label: const Text('New Place'),
              icon: const Icon(Icons.add),
            ),
            const SizedBox(height: 10),
            FloatingActionButton.extended(
              onPressed: addRoute,
              label: const Text('New Route'),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: (areaModel == null)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : (areaModel!.ownerUid != FirebaseAuth.instance.currentUser!.uid)
                ? const ErrorPage()
                : TabBarView(
                    children: [
                      getRouteListview(),
                      getRouteListview(),
                    ],
                  ),
      ),
    );
  }

  Widget getRouteListview() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('regions')
            .doc(widget.regionId)
            .collection('routes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final List<RouteModel> list = [];
            for (var doc in snapshot.data!.docs) {
              list.add(RouteModel.fromSnapshot(doc));
            }
            return ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 5),
              itemBuilder: (context, index) => getRouteItem(list[index]),
            );
          }
          return const ErrorPage(errorMsg: 'Routes Not Found!');
        });
  }

  Widget getRouteItem(RouteModel routeModel) {
    return ListTile(
      tileColor: XColors.white,
      title: Text(routeModel.title),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 5, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      trailing: PopupMenuButton(
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              onTap: () {
                FirebaseFirestore.instance
                    .collection('regions')
                    .doc(widget.regionId)
                    .collection('routes')
                    .doc(routeModel.id)
                    .delete();
              },
              child: const Text('Delete'),
            )
          ];
        },
      ),
    );
  }

  Future<void> getRegion() async {
    final doc = await FirebaseFirestore.instance
        .collection('regions')
        .doc(widget.regionId)
        .get();
    if (doc.exists) {
      areaModel = AreaModel.fromSnapshot(doc);
      setState(() {});
    }
  }

  void addRoute() async {
    showDialog(
      context: context,
      builder: (context) {
        return AddRouteDialog(
          close: () => Navigator.pop(context),
          areaModel: areaModel!,
        );
      },
    );
  }
}
