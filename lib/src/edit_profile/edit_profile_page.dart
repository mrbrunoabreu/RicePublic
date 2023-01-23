import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/rice_repository.dart';
import '../view/screen_bar.dart';

class EditProfilePage extends StatelessWidget {
  static const String routeName = '/editProfile';

  @override
  Widget build(BuildContext context) {
    var _editProfileBloc =
        EditProfileBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      appBar: ScreenBar(
        Text('EDIT PROFILE', style: Theme.of(context).textTheme.headline2),
        rightIcon: null,
      ),
      body: SafeArea(
        child: EditProfileScreen(editProfileBloc: _editProfileBloc),
      ),
    );
  }
}
