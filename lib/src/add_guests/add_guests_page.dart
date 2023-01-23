import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/rice_repository.dart';
import '../screen_arguments.dart';
import '../view/screen_bar.dart';
import 'dart:developer' as developer;

class AddGuestsPage extends StatelessWidget {
  static const String routeName = '/addGuests';
  @override
  Widget build(BuildContext context) {
    var _addGuestsBloc =
        AddGuestsBloc(riceRepository: context.read<RiceRepository>());

    final arguments =
        ModalRoute.of(context)!.settings.arguments as AddGuestsPageArguments;

    developer.log('Preselected ${arguments.users!.length}');

    return Scaffold(
      appBar: ScreenBar(
        Text('Add guests', style: Theme.of(context).textTheme.headline2),
        isBackIcon: true,
        rightIcon: Icon(Icons.person_add),
      ),
      body: AddGuestsScreen(
        addGuestsBloc: _addGuestsBloc,
        selectedUsers: arguments.users,
      ),
    );
  }
}
