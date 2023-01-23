import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rice_repository.dart';
import 'index.dart';
import '../view/screen_bar.dart';

import '../notification/notification_bloc.dart';

class SettingsPage extends StatelessWidget {
  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    var _settingsBloc =
        SettingsBloc(riceRepository: context.read<RiceRepository>());
    var _notificationBloc =
        NotificationBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      appBar: ScreenBar(
        Text('SETTINGS', style: Theme.of(context).textTheme.headline2),
        rightIcon: null,
      ),
      body: SafeArea(
          child: SettingsScreen(
        settingsBloc: _settingsBloc,
        notificationBloc: _notificationBloc,
      )),
    );
  }
}
