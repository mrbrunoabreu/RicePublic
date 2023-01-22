import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/rice_repository.dart';

class NotificationPage extends StatelessWidget {
  static const String routeName = '/notification';

  @override
  Widget build(BuildContext context) {
    final _notificationBloc =
        NotificationBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      body: NotificationsScreen(notificationBloc: _notificationBloc),
    );
  }
}
