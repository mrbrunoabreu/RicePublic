import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rice_repository.dart';
import 'package:rice/src/restaurant_list/index.dart';
import 'package:rice/src/screen_arguments.dart';
import 'package:rice/src/view/screen_bar.dart';

class RestaurantListPage extends StatelessWidget {
  static const String routeName = '/restaurantList';

  @override
  Widget build(BuildContext context) {
    final RestaurantListPageArguments args = ModalRoute.of(context)!
        .settings
        .arguments as RestaurantListPageArguments;
    var _restaurantListBloc =
        RestaurantListBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      appBar: ScreenBar(
          Text('RESTAURANTS', style: Theme.of(context).textTheme.headline2)),
      body: RestaurantListScreen(
          restaurantListBloc: _restaurantListBloc,
          restaurants: args.restaurants),
    );
  }
}
