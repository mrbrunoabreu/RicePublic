import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rice/src/create_plan/index.dart';
import 'package:rice/src/repository/rice_repository.dart';
import 'package:rice/src/screen_arguments.dart';
import 'package:rice/src/view/screen_bar.dart';

class CreatePlanPage extends StatelessWidget {
  static const String routeName = '/createPlan';

  @override
  Widget build(BuildContext context) {
    final CreatePlanPageArguments? args =
        ModalRoute.of(context)!.settings.arguments as CreatePlanPageArguments?;
    var _createPlanBloc = CreatePlanBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      appBar: ScreenBar(
        Text((args?.restaurant == null ? 'create a plan' : 'edit plan')
            .toUpperCase(), style: Theme.of(context).textTheme.headline2),
        isBackIcon: false,
      ),
      body: CreatePlanScreen(
        createPlanBloc: _createPlanBloc,
        preSelectedUsers: args?.users ?? [],
      ),
    );
  }
}
