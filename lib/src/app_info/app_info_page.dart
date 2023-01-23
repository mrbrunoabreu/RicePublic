import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/rice_repository.dart';

class AppInfoPage extends StatelessWidget {
  static const String routeName = '/app';

  @override
  Widget build(BuildContext context) {
    var _bloc = AppInfoBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      body: AppInfoScreen(bloc: _bloc),
    );
  }
}
