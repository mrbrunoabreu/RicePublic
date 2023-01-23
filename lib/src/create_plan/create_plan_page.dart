import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/rice_repository.dart';
import '../screen_arguments.dart';
import '../view/screen_bar.dart';

class CreatePlanPage extends StatelessWidget {
  static const String routeName = '/createPlan';

  @override
  Widget build(BuildContext context) {
    final CreatePlanPageArguments? args =
        ModalRoute.of(context)!.settings.arguments as CreatePlanPageArguments?;
    var _createPlanBloc =
        CreatePlanBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      appBar: ScreenBar(
        Text(
            (args?.restaurant == null ? 'create a plan' : 'edit plan')
                .toUpperCase(),
            style: Theme.of(context).textTheme.headline2),
        isBackIcon: false,
      ),
      body: CreatePlanScreen(
        createPlanBloc: _createPlanBloc,
        preSelectedUsers: args?.users ?? [],
      ),
    );
  }
}
