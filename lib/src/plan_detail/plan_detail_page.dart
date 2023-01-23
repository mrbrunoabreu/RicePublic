import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/model/plan.dart';
import '../repository/rice_repository.dart';
import '../view/screen_bar.dart';

class PlanDetailPage extends StatelessWidget {
  static const String routeName = '/planDetail';

  @override
  Widget build(BuildContext context) {
    final Plan? plan = ModalRoute.of(context)!.settings.arguments as Plan?;

    var _planDetailBloc =
        PlanDetailBloc(riceRepository: context.read<RiceRepository>());

    return Scaffold(
      appBar: ScreenBar(
        Text('PLAN DETAILS', style: Theme.of(context).textTheme.headline2),
        isBackIcon: true,
      ),
      body: PlanDetailScreen(planDetailBloc: _planDetailBloc, plan: plan),
    );
  }
}
