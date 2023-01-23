import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'personal_restaurants_bloc.dart';
import 'personal_restaurants_screen.dart';
import '../repository/rice_repository.dart';
import '../screen_arguments.dart';
import '../view/screen_bar.dart';

class PersonalRestaurantsPage extends StatelessWidget {
  static const String routeName = "/personalRestaurants";

  @override
  Widget build(BuildContext context) {
    final bloc =
        PersonalRestaurantsBloc(riceRepository: context.read<RiceRepository>());

    final PersonalRestaurantsPageArguments args = ModalRoute.of(context)!
        .settings
        .arguments as PersonalRestaurantsPageArguments;

    return Scaffold(
      appBar: ScreenBar(
        Text('${args.name}'.toUpperCase(),
            style: Theme.of(context).textTheme.headline2,
            overflow: TextOverflow.ellipsis),
        isBackIcon: true,
      ),
      body: PersonalRestaurantsScreen(bloc: bloc, args: args),
    );
  }
}
