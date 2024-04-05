import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidemap/cubits/home_cubit.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, int>(
      builder: (context, state) {
        return NavigationBar(
          backgroundColor: Colors.white,
          selectedIndex: state,
          surfaceTintColor: Colors.white,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.location_on),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.line_style_rounded),
              label: 'Regions',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark),
              label: 'Saved',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          onDestinationSelected: (value) {
            context.read<HomeCubit>().changeIndex(value);
          },
        );
      },
    );
  }
}
