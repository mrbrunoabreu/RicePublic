import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import '../repository/model/restaurant.dart';
import 'package:rice/src/restaurant_detail/index.dart';
import 'package:rice/src/restaurant_list/index.dart';
import 'package:rice/src/view/restaurant.dart';
import 'package:tuple/tuple.dart';

import '../screen_arguments.dart';
import '../utils.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({
    Key? key,
    required RestaurantListBloc restaurantListBloc,
    required this.restaurants,
  })  : _restaurantListBloc = restaurantListBloc,
        super(key: key);

  final RestaurantListBloc _restaurantListBloc;
  final List<Restaurant> restaurants;
  @override
  RestaurantListScreenState createState() {
    return RestaurantListScreenState(_restaurantListBloc);
  }
}

class RestaurantListScreenState extends State<RestaurantListScreen> {
  final RestaurantListBloc _restaurantListBloc;
  RestaurantListScreenState(this._restaurantListBloc);

  @override
  void initState() {
    super.initState();
    this._load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onWillPop() {
    // if (!_pc.isPanelClosed()) {
    //   _pc.close();
    //   return Future.value(false);
    // }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantListBloc, RestaurantListState>(
        bloc: widget._restaurantListBloc,
        builder: (
          BuildContext context,
          RestaurantListState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              RestaurantListState currentState,
            ) {
              List<Widget> list = [
                _buildBody(context, currentState),
                // SafeArea(child: _buildHeadBar(context, currentState)),
              ];
              if (currentState is ErrorRestaurantListState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage);
                });
              }
              return WillPopScope(
                  onWillPop: _onWillPop,
                  child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: list));
            }));
  }

  _buildRestaurants(
      Stream<List<Tuple2<Restaurant, List<String>>>>
          restaurantWithPhotosStream) {
    return StreamBuilder<List<Tuple2<Restaurant, List<String>>>>(
        stream: restaurantWithPhotosStream,
        builder: (ctx, snapshot) {
          if (snapshot.hasError || snapshot.data == null) {
            return Container();
          }
          return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) => SizedBox(),
              itemBuilder: (context, index) => RestaurantRow(
                      snapshot.data![index].item1,
                      photos: snapshot.data![index].item2, onTapCallback: () {
                    _navigateRestaurantDetail(snapshot.data![index].item1);
                  }));
        });
  }

  _buildAllRestaurantsListView(InRestaurantListState currentState) {
    return _buildRestaurants(
        Stream.fromFuture(currentState.restaurantWithPhotos));
  }

  _buildBody(BuildContext context, RestaurantListState currentState) {
    if (currentState is InRestaurantListState) {
      return SafeArea(
        child: _buildAllRestaurantsListView(currentState),
      );
    }

    return SafeArea(
      child: Container(),
    );
  }

  void _load([bool isError = false]) {
    widget._restaurantListBloc.add(UnRestaurantListEvent());
    widget._restaurantListBloc.add(LoadRestaurantListEvent(widget.restaurants));
  }

  _navigateRestaurantDetail(Restaurant restaurant) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushNamed(context, RestaurantDetailPage.routeName,
        arguments: RestaursntDetailPageArguments(restaurant));
    // });
  }
}
