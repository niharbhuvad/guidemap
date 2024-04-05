import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidemap/cubits/home_cubit.dart';
import 'package:guidemap/screens/home/regions_page.dart';
import 'package:guidemap/screens/home/comps/bottombar.dart';
import 'package:guidemap/screens/home/explore_page.dart';
import 'package:guidemap/screens/home/saved_page.dart';
import 'package:guidemap/screens/home/settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocBuilder<HomeCubit, int>(builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Guide Map'),
          ),
          body: BlocBuilder<HomeCubit, int>(
            builder: (context, state) {
              return IndexedStack(
                index: state,
                children: const [
                  ExplorePage(),
                  RegionsPage(),
                  SavedPage(),
                  SettingsPage(),
                ],
              );
            },
          ),
          bottomNavigationBar: const Bottombar(),
        );
      }),
    );
  }
}
