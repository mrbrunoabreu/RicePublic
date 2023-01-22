import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rice_repository.dart';
import 'package:rice/src/restaurant_detail/index.dart';

class RestaurantDetailPage extends StatelessWidget {
  static const String routeName = '/restaurantDetail';

  @override
  Widget build(BuildContext context) {
    var _restaurantDetailBloc =
        RestaurantDetailBloc(riceRepository: context.read<RiceRepository>());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RestaurantDetailScreen(
        restaurantDetailBloc: _restaurantDetailBloc,
      ),
    );
  }
}
