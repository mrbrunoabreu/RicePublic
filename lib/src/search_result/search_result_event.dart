import 'dart:async';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/user.dart';
import 'package:rice/src/search_result/index.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

import '../utils.dart';

@immutable
abstract class SearchResultEvent {
  Future<SearchResultState> applyAsync(
      {SearchResultState? currentState, SearchResultBloc? bloc});
  // final SearchResultRepository _searchResultRepository = SearchResultRepository();
}

class UnSearchResultEvent extends SearchResultEvent {
  @override
  Future<SearchResultState> applyAsync(
      {SearchResultState? currentState, SearchResultBloc? bloc}) async {
    return UnSearchResultState(0);
  }
}

// class LoadSearchResultEvent extends SearchResultEvent {
//   final bool isError;
//   @override
//   String toString() => 'LoadSearchResultEvent';

//   LoadSearchResultEvent(this.isError);

//   @override
//   Future<SearchResultState> applyAsync(
//       {SearchResultState currentState, SearchResultBloc bloc}) async {
//     try {
//       if (currentState is InSearchResultState) {
//         return currentState.getNewVersion();
//       }
//       await Future.delayed(Duration(seconds: 2));
//       bloc.findRestaurantsByKeyword("test");
//       // this._searchResultRepository.test(this.isError);
//       return InSearchResultState(0, "Hello world");
//     } catch (_, stackTrace) {
//       developer.log('$_',
//           name: 'LoadSearchResultEvent', error: _, stackTrace: stackTrace);
//       return ErrorSearchResultState(0, _?.toString());
//     }
//   }
// }

class LoadPeopleSearchResultEvent extends SearchResultEvent {
  final String keyword;
  @override
  String toString() => 'LoadPeopleSearchResultEvent';

  LoadPeopleSearchResultEvent(this.keyword) : assert(keyword != null);

  @override
  Future<SearchResultState> applyAsync(
      {SearchResultState? currentState, SearchResultBloc? bloc}) async {
    try {
      if (currentState is InSearchResultState) {
        return currentState.getNewVersion();
      }

      List<User> people = await bloc!.findUserByName(keyword);

      return InPeopleSearchResultState(0, people);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadPeopleSearchResultEvent',
          error: _,
          stackTrace: stackTrace);
      return ErrorSearchResultState(0, _.toString());
    }
  }
}

class LoadKeywordSearchResultEvent extends SearchResultEvent {
  final String keyword;
  @override
  String toString() => 'LoadKeywordSearchResultEvent';

  LoadKeywordSearchResultEvent(this.keyword) : assert(keyword != null);

  @override
  Future<SearchResultState> applyAsync(
      {SearchResultState? currentState, SearchResultBloc? bloc}) async {
    try {
      if (currentState is InSearchResultState) {
        return currentState.getNewVersion();
      }

      Position userLocation = await loadUserLastLocation();

      List<Tuple2<Restaurant, List<String>>> restaurants = await bloc!
          .findRestaurantsByKeyword(
        keyword,
        userLocation.latitude,
        userLocation.longitude,
      )
          .then(
        (restaurants) async {
          List<Tuple2<Restaurant, List<String>>> list = [];

          await Future.forEach(
            restaurants,
            (dynamic r) async {
              Tuple2<Restaurant, List<String>> item =
                  await bloc.findRestaurantPhotos(r);

              list.add(item);
            },
          );
          return list;
        },
      );

      return InSearchResultState(0, restaurants);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadKeywordSearchResultEvent',
          error: _,
          stackTrace: stackTrace);
      return ErrorSearchResultState(0, _.toString());
    }
  }
}
