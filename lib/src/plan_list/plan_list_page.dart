import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/rice_repository.dart';

class PlanListPage extends StatelessWidget {
  static const String routeName = '/planList';

  @override
  Widget build(BuildContext context) {
    var _planListBloc =
        PlanListBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      body: PlanListScreen(planListBloc: _planListBloc),
    );
  }
}
