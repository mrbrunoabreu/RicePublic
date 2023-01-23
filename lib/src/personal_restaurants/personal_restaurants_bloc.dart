import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import 'dart:developer' as developer;

import 'personal_restaurants_event.dart';
import 'personal_restaurants_state.dart';
import '../repository/model/personal_list.dart';
import '../repository/model/restaurant.dart';
import '../repository/rice_repository.dart';

class PersonalRestaurantsBloc
    extends BaseBloc<PersonalRestaurantsEvent, PersonalRestaurantsState> {
  PersonalRestaurantsBloc({required RiceRepository riceRepository})
      : super(
            riceRepository: riceRepository,
            initialState: UnPersonalRestaurantsState(0));

  Future<bool> addRestaurant({
    required Restaurant restaurant,
    required String? listId,
  }) async {
    final result = await this.riceRepository.addRestaurantToMyLists(
          restaurant,
          listId,
          false,
        );

    print('Adding ${restaurant.id} to list $listId - Result: $result');

    return result;
  }

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<PersonalList> findPersonalList({required String? listId}) {
    return this.riceRepository.findPersonalList(listId: listId);
  }

  Future<Restaurant?> findRestaurant({required String restaurantId}) {
    return this.riceRepository.findRestaurant(restaurantId);
  }

  @override
  Future<void> mapEventToState(
    PersonalRestaurantsEvent event,
    Emitter<PersonalRestaurantsState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'ProfileBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}
