import 'package:flutter/material.dart';
import 'package:watermeter_postgraduate/page/homepage/homepage.dart';
import 'package:watermeter_postgraduate/page/setting/setting.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final _page = [
    MainPage(),
    const SettingWindow(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,
      body: _page[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: _selectedIndex == 0
                ? const Icon(Icons.home)
                : const Icon(Icons.home_outlined),
            label: '主页',
          ),
          NavigationDestination(
            icon: _selectedIndex == 3
                ? const Icon(Icons.settings)
                : const Icon(Icons.settings_outlined),
            label: '设置',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
