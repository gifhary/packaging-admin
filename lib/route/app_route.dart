import 'package:admin/screen/auth_screen.dart';
import 'package:admin/screen/dashboard_screen.dart';
import 'package:admin/screen/order_detail_screen.dart';
import 'package:get/get.dart';
import 'route_constant.dart';

class AppRoute {
  static final all = [
    GetPage(name: RouteConstant.auth, page: () => AuthScreen()),
    GetPage(name: RouteConstant.orderDetail, page: () => OrderDetailScreen()),
    GetPage(name: RouteConstant.dashboard, page: () => DashboardScreen())
  ];
}
