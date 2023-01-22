import 'package:flutter/material.dart';

class NavigationService{
  late GlobalKey<NavigatorState> navigationKey;

  static NavigationService _instance = NavigationService._internal();

  factory NavigationService() {
    _instance.navigationKey = GlobalKey<NavigatorState>();
    return _instance;
  }
  NavigationService._internal();

  Future<dynamic> navigateToReplacement(String _rn, arguments){
    return navigationKey.currentState!.pushReplacementNamed(_rn, arguments: arguments);
  }

  Future<dynamic> navigateTo(String _rn, arguments){
    return navigationKey.currentState!.pushNamed(_rn, arguments: arguments);
  }

  Future<dynamic> navigateToWithContext(BuildContext context, String _rn, arguments, {bool replace = false}){
    if (!replace) {
      return Navigator.of(context).pushNamed(_rn, arguments: arguments);
    }

    return Navigator.pushNamedAndRemoveUntil(
              context,
              _rn,
              ModalRoute.withName('/'),
              arguments: arguments,
            );
  }
  
  Future<dynamic> navigateToRoute(MaterialPageRoute _rn){
    return navigationKey.currentState!.push(_rn);
  }

  goback(){
    return navigationKey.currentState!.pop();
  }
}