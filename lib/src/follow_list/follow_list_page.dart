import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'follow_list_bloc.dart';
import 'follow_list_screen.dart';
import '../repository/rice_repository.dart';
import '../screen_arguments.dart';
import '../view/screen_bar.dart';

class FollowListPage extends StatelessWidget {
  static const String routeName = "/followList";

  @override
  Widget build(BuildContext context) {
    final bloc = FollowListBloc(riceRepository: context.read<RiceRepository>());

    final FollowListPageArguments args =
        ModalRoute.of(context)!.settings.arguments as FollowListPageArguments;

    return Scaffold(
      appBar: ScreenBar(
        Text(args.getTypeName().toUpperCase(),
            style: Theme.of(context).textTheme.headline2,
            overflow: TextOverflow.ellipsis),
        isBackIcon: true,
      ),
      body: FollowListScreen(bloc: bloc, args: args),
    );
  }
}
