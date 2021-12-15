import 'package:admin/screen/dashboard/insight_screen.dart';
import 'package:admin/screen/dashboard/order_screen.dart';
import 'package:admin/screen/dashboard/setting_screen.dart';
import 'package:admin/widget/colored_tabbar.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
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
            indicatorColor: Colors.white,
            tabs: [
              Tab(child: Text('Order')),
              Tab(child: Text('Insight')),
              Tab(child: Text('Setting')),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            OrderScreen(),
            InsightScreen(),
            SettingScreen(),
          ],
        ),
      ),
    );
  }
}
