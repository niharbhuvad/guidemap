import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guidemap/models/area_model.dart';
import 'package:guidemap/screens/error_page.dart';
import 'package:guidemap/utils/funs.dart';
import 'package:guidemap/utils/x_colors.dart';
import 'package:guidemap/utils/x_widgets.dart';

class AreasPage extends StatelessWidget {
  const AreasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add_region'),
        label: const Text('New Area'),
        icon: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('regions')
              .where('owner_uid',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            final List<AreaModel> areas = [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              for (var doc in snapshot.data!.docs) {
                areas.add(AreaModel.fromSnapshot(doc));
              }
            }
            areas.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            return (areas.isNotEmpty)
                ? ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: areas.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 5),
                    itemBuilder: (context, index) {
                      return getAreaItem(context, areas[index]);
                    },
                  )
                : const ErrorPage(errorMsg: 'Areas Not Found!');
          }),
    );
  }

  Widget getAreaItem(BuildContext context, AreaModel area) {
    return GestureDetector(
      onTap: () => context.push('/view_region/${area.id}'),
      child: ListTile(
        tileColor: XColors.white,
        contentPadding: const EdgeInsets.fromLTRB(12, 0, 5, 0),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: XColors.greyDark.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        title: Text(
          area.title,
          maxLines: 1,
          style: const TextStyle(
            color: XColors.greyDeep,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        horizontalTitleGap: 5,
        subtitle: Text(
          area.desc,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 13,
            overflow: TextOverflow.ellipsis,
            height: 1.3,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info),
          onPressed: () => showAreaDetails(context, area),
        ),
      ),
    );
  }

  void showAreaDetails(BuildContext context, AreaModel area) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          children: [
            Text(
              area.title,
              style: const TextStyle(
                color: XColors.greyDeep,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: XWidgets.iconTextBtn(
                    iconData: Icons.delete,
                    text: 'Delete Area',
                    onPressed: () async {
                      context.pop();
                      deleteArea(context, area);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: XWidgets.iconTextBtn(
                    iconData: Icons.map,
                    text: 'Edit Area',
                    onPressed: () {
                      context.push('/edit_region/${area.id}');
                      context.pop();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              area.desc,
              maxLines: null,
              style: const TextStyle(
                fontSize: 16,
                color: XColors.greyDeep,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteArea(BuildContext context, AreaModel area) async {
    await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Delete Area'),
            content: const Text('Are you really want to delete this area?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('regions')
                      .doc(area.id)
                      .delete();
                  showSnackbar(context, 'Area Deleted');
                },
                child: const Text('Yes'),
              ),
            ],
          );
        });
  }
}
