import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rice/src/plan_detail/index.dart';
import 'package:rice/src/repository/model/plan.dart';
import 'package:rice/src/repository/rice_repository.dart';
import 'package:rice/src/view/screen_bar.dart';

class PlanDetailPage extends StatelessWidget {
  static const String routeName = '/planDetail';

  @override
  Widget build(BuildContext context) {
    final Plan? plan = ModalRoute.of(context)!.settings.arguments as Plan?;

    var _planDetailBloc = PlanDetailBloc(riceRepository: context.read<RiceRepository>());

    return Scaffold(
      appBar: ScreenBar(
        Text('PLAN DETAILS', style: Theme.of(context).textTheme.headline2),
        isBackIcon: true,
      ),
      body: PlanDetailScreen(planDetailBloc: _planDetailBloc, plan: plan),
    );
  }
}
