import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'explore_plans_bloc.dart';
import 'explore_plans_screen.dart';
import '../repository/rice_repository.dart';
import '../screen_arguments.dart';
import '../view/screen_bar.dart';

class ExplorePlansPage extends StatelessWidget {
  static const String routeName = '/explorePlans';

  @override
  Widget build(BuildContext context) {
    final bloc =
        ExplorePlansBloc(riceRepository: context.read<RiceRepository>());

    final ExplorePlansPageArguments arguments =
        ModalRoute.of(context)!.settings.arguments as ExplorePlansPageArguments;

    return Scaffold(
      appBar: ScreenBar(
        Text(
          arguments.title.toUpperCase(),
          style: Theme.of(context).textTheme.headline2,
        ),
        isBackIcon: false,
      ),
      body: ExplorePlansScreen(
        bloc: bloc,
        arguments: arguments,
      ),
    );
  }
}
