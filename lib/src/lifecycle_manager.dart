import 'dart:async';

import 'package:flutter/material.dart';
import './repository/firebase_dynamic_link_service.dart';
import './repository/rice_meteor_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:developer' as developer;

/// Stop and start long running services
class LifeCycleManager extends StatefulWidget {
  final Widget? child;
  LifeCycleManager({Key? key, this.child}) : super(key: key);
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  RiceMeteorService service = RiceMeteorService();
  Timer? _timerLink;
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attemptResume();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    service.disconnect();
    if (_timerLink != null) {
      _timerLink!.cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    developer.log('App state changed: $state', name: 'LifeCycleManager');
    if (state == AppLifecycleState.resumed) {
      _attemptResume();
      // _timerLink = new Timer(
      //   const Duration(milliseconds: 1000),
      //   () {

      //   },
      // );
    }
    if (state == AppLifecycleState.paused) {
      service.pause();
    }
  }

  Future<bool> _attemptResume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('loginToken')) {
      final token = prefs.getString('loginToken');
      return await service.resume(token: token).then((value) {
        if (value != null) {
          prefs.setString('loginToken', value);
        }
        return value != null;
      });
    }

    Stream<ConnectionStatus>? status = await service.connect();
    return status != null;
  }
}
