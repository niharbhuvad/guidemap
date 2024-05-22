import 'package:flutter/material.dart';
import 'package:guidemap/screens/home/pages/areas_page.dart';
import 'package:guidemap/screens/home/pages/dashboard_page.dart';
import 'package:guidemap/screens/home/pages/profile_page.dart';
import 'package:guidemap/utils/x_consts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(XConsts.appName.toUpperCase()),
      ),
      body: IndexedStack(
        index: selectedPage,
        alignment: Alignment.topCenter,
        children: const [
          DashboardPage(),
          AreasPage(),
          SizedBox(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedPage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_filled),
            label: 'Dashbaord',
          ),
          NavigationDestination(
            icon: Icon(Icons.amp_stories),
            label: 'Areas',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_rounded),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'You',
          ),
        ],
        onDestinationSelected: (value) {
          setState(() {
            selectedPage = value;
          });
        },
      ),
    );
  }
}
