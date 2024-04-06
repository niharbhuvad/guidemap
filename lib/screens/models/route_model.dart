import 'package:guidemap/screens/models/position_point_model.dart';

class RouteModel {
  final String id;
  final String title;
  final List<PositionPointModel> routesPoints;
  RouteModel({
    required this.id,
    required this.title,
    required this.routesPoints,
  });
}
