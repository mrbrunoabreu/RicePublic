import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rice/src/personal_lists/personal_lists_bloc.dart';
import 'package:rice/src/personal_lists/personal_lists_screen.dart';
import 'package:rice/src/repository/rice_repository.dart';
import 'package:rice/src/screen_arguments.dart';
import 'package:rice/src/view/screen_bar.dart';

class PersonalListsPage extends StatelessWidget {
  static const String routeName = '/personalLists';

  @override
  Widget build(BuildContext context) {
    final bloc = PersonalListsBloc(riceRepository: context.read<RiceRepository>());

    final PersonalListsPageArguments? arguments =
        ModalRoute.of(context)!.settings.arguments as PersonalListsPageArguments?;

    return Scaffold(
      appBar: ScreenBar(
        Text(
          (arguments?.name ?? 'My Lists').toUpperCase(), style: Theme.of(context).textTheme.headline2,
        ),
      ),
      body: PersonalListsScreen(bloc: bloc, arguments: arguments),
    );
  }
}
