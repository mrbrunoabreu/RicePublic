import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../chat_list/index.dart';
import '../explore/index.dart';
import '../plan_list/index.dart';
import '../profile/index.dart';

import '../notification/index.dart';
import 'package:ionicons/ionicons.dart';
import '../repository/rice_repository.dart';

import '../screen_arguments.dart';
import 'dart:developer' as developer;

class MainPage extends StatefulWidget {
  static const String routeName = '/main';
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();

  static void navigateMain(BuildContext context, String tab) {
    Navigator.pushReplacementNamed(context, MainPage.routeName,
        arguments: MainPageArguments(tab));
  }
}

class _MainPageState extends State<MainPage> {
  static const double _iconSize = 24.0;
  late NotificationBloc _notificationBloc;

  int _selectedIndex = 0;
  var _controller = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    super.initState();
    _notificationBloc =
        NotificationBloc(riceRepository: context.read<RiceRepository>());

    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    _notificationBloc.add(SetupFirebaseMessaging());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _onItemTapped(int index) {
    _controller.jumpToPage(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onBackPress() {
    if (_selectedIndex != 0) {
      developer.log('Current selected index = $_selectedIndex',
          name: '_MainPageState::_onBackPress');
      _controller.jumpToPage(0);
      setState(() {
        _selectedIndex = 0;
      });
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPress,
        child: Scaffold(
          body: PageView(
            controller: _controller,
            children: <Widget>[
              ExplorePage(),
              PlanListPage(),
              ChatListPage(),
              ProfilePage()
            ],
            physics: NeverScrollableScrollPhysics(),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Ionicons.search_outline),
                label: 'explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Ionicons.calendar_outline),
                label: 'plan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Ionicons.chatbubble_outline),
                label: 'chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Ionicons.person_circle_outline),
                label: 'profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor:
                Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
            onTap: _onItemTapped,
          ),
        ));
  }
}
