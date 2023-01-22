import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rice/src/profile/index.dart';
import '../repository/rice_repository.dart';

class ProfilePage extends StatelessWidget {
  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    var _profileBloc =
        ProfileBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Profile'),
      // ),
      // backgroundColor: Colors.white,
      body: ProfileScreen(profileBloc: _profileBloc),
    );
  }
}
