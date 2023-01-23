import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'find_restaurant_bloc.dart';
import 'find_restaurant_screen.dart';
import '../repository/rice_repository.dart';
import '../view/screen_bar.dart';

class FindRestaurantPage extends StatefulWidget {
  static final String routeName = '/findRestaurant';

  @override
  _FindRestaurantPageState createState() => _FindRestaurantPageState();
}

class _FindRestaurantPageState extends State<FindRestaurantPage> {
  @override
  Widget build(BuildContext context) {
    final bloc =
        FindRestaurantBloc(riceRepository: context.read<RiceRepository>());

    return Scaffold(
      appBar: ScreenBar(Text('Find a Restaurant'.toUpperCase(),
          style: Theme.of(context).textTheme.headline2)),
      body: FindRestaurantScreen(
        bloc: bloc,
      ),
    );
  }
}
