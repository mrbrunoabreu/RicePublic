import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rice_repository.dart';
import 'index.dart';
import '../screen_arguments.dart';
import '../view/screen_bar.dart';

class RestaurantReviewPage extends StatelessWidget {
  static const String routeName = '/restaurantReview';

  @override
  Widget build(BuildContext context) {
    final RestaurantReviewPageArguments args = ModalRoute.of(context)!
        .settings
        .arguments as RestaurantReviewPageArguments;
    var _restaurantReviewBloc =
        RestaurantReviewBloc(riceRepository: context.read<RiceRepository>());

    return Scaffold(
      appBar: ScreenBar(
        Text('write a review'.toUpperCase(),
            style: Theme.of(context).textTheme.headline2),
        isBackIcon: true,
      ),
      body: Container(
        child: RestaurantReviewScreen(
          restaurantReviewBloc: _restaurantReviewBloc,
          restaurant: args.restaurant,
        ),
      ),
    );
  }
}
