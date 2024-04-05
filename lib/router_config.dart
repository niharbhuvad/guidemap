import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:guidemap/screens/add_region/add_region_screen.dart';
import 'package:guidemap/screens/edit_region/edit_region_screen.dart';
import 'package:guidemap/screens/home/home_screen.dart';

final beamerDel = BeamerDelegate(
  initialPath: '/home',
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/home': (context, state, data) {
        return const BeamPage(
          key: ValueKey('home_screen'),
          title: 'Home Screen',
          child: HomeScreen(),
        );
      },
      '/add_region': (context, state, data) {
        return const BeamPage(
          key: ValueKey('add_region_screen'),
          title: 'Add Region Screen',
          child: AddRegionScreen(),
        );
      },
      '/edit_region/:id': (context, state, data) {
        return BeamPage(
          key: const ValueKey('add_region_screen'),
          title: 'Add Region Screen',
          child: EditRegionScreen(state.pathParameters['id']!),
        );
      },
    },
  ).call,
);
