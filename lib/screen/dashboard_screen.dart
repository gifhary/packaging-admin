import 'package:admin/screen/dashboard/insight_screen.dart';
import 'package:admin/screen/dashboard/order_screen.dart';
import 'package:admin/screen/dashboard/setting_screen.dart';
import 'package:admin/widget/colored_tabbar.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback logOut;

  const DashboardScreen({Key? key, required this.logOut}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: ColoredTabBar(
          Color.fromRGBO(46, 45, 42, 0.8),
          TabBar(
            labelColor: Colors.white,
            indicatorColor: const Color.fromRGBO(160, 152, 128, 1),
            indicatorWeight: 5,
            tabs: [
              Tab(child: Text('Order', style: TextStyle(fontSize: 20))),
              Tab(child: Text('Insight', style: TextStyle(fontSize: 20))),
              Tab(child: Text('Setting', style: TextStyle(fontSize: 20))),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            OrderScreen(),
            InsightScreen(logOut: logOut),
            SettingScreen(),
          ],
        ),
      ),
    );
  }
}
