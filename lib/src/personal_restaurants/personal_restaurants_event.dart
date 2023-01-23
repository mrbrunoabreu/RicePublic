import 'package:flutter/material.dart';
import '../base_bloc.dart';
import 'personal_restaurants_bloc.dart';
import 'personal_restaurants_state.dart';
import '../repository/model/personal_list.dart';
import '../repository/model/restaurant.dart';

@immutable
abstract class PersonalRestaurantsEvent {
  Future<PersonalRestaurantsState> applyAsync(
      {PersonalRestaurantsState currentState, PersonalRestaurantsBloc bloc});
}

class UnPersonalRestaurantEvent extends PersonalRestaurantsEvent {
  @override
  Future<PersonalRestaurantsState> applyAsync(
      {PersonalRestaurantsState? currentState,
      PersonalRestaurantsBloc? bloc}) async {
    return UnPersonalRestaurantsState(0);
  }
}

class LoadPersonalRestaurantsEvent extends PersonalRestaurantsEvent {
  final String? listId;
  final List<String>? restaurants;

  LoadPersonalRestaurantsEvent({this.listId, this.restaurants});

  @override
  Future<PersonalRestaurantsState> applyAsync({
    PersonalRestaurantsState? currentState,
    PersonalRestaurantsBloc? bloc,
  }) async {
    try {
      if (this.listId != null) {
        final PersonalList list = await bloc!.findPersonalList(
          listId: this.listId,
        );

        return InPersonalRestaurantsState(0, personalList: list);
      } else if (this.restaurants != null) {
        final List<Restaurant?> restaurants = [];

        if (this.restaurants!.isNotEmpty) {
          await Future.forEach(this.restaurants!, (String restaurantId) async {
            restaurants.add(
              await bloc!.findRestaurant(restaurantId: restaurantId),
            );
          });
        }

        return InPersonalRestaurantsState(
          0,
          personalList: PersonalList(name: '', restaurants: restaurants),
        );
      } else {
        return UnPersonalRestaurantsState(0);
      }
    } catch (_, stackTrace) {
      return ErrorPersonalRestaurantsState(0, '');
    }
  }
}

class AddRestaurantToList extends PersonalRestaurantsEvent with NeedShowLoader {
  final Restaurant restaurant;
  final String? listId;

  AddRestaurantToList({
    required this.restaurant,
    required this.listId,
  });

  @override
  Future<PersonalRestaurantsState> applyAsync({
    PersonalRestaurantsState? currentState,
    PersonalRestaurantsBloc? bloc,
  }) async {
    await bloc!.addRestaurant(
      restaurant: this.restaurant,
      listId: this.listId,
    );

    return currentState!;
  }
}
