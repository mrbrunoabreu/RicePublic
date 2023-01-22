import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rice_repository.dart';
import 'package:rice/src/search_result/index.dart';

import '../screen_arguments.dart';

class SearchResultPage extends StatelessWidget {
  static const String routeName = '/searchResult';

  SearchResultScreenState _getState(
      SearchResultPageArguments args, SearchResultBloc searchResultBloc) {
    if (args.arguments is KeywordSearchArguments) {
      return KeywordSearchResultScreenState(
          (args.arguments as KeywordSearchArguments).keyword,
          searchResultBloc,
          (args.arguments as KeywordSearchArguments).viewType);
    } else if (args.arguments is PlaceSearchArguments) {
      return PlaceSearchResultScreenState(
          searchResultBloc,
          (args.arguments as PlaceSearchArguments).viewType,
          args.arguments.lat,
          args.arguments.lng);
    } else if (args.arguments is PeopleSearchArguments) {
      return PeopleSearchResultScreenState(
        (args.arguments as PeopleSearchArguments).keyword,
        searchResultBloc,
        (args.arguments as PeopleSearchArguments).viewType,
      );
    } else {
      throw AssertionError("No such state for result screen");
    }
  }

  static toggleNavigate(BuildContext context, SearchResultPageArguments args) {
    SearchResultPageArguments toggledArgs;
    if (args.arguments is KeywordSearchArguments) {
      toggledArgs = SearchResultPageArguments(KeywordSearchArguments(
          (args.arguments as KeywordSearchArguments).keyword,
          args.arguments.lat,
          args.arguments.lng,
          viewType: ((args.arguments as KeywordSearchArguments).viewType ==
                  SearchResultViewType.Normal)
              ? SearchResultViewType.Map
              : SearchResultViewType.Normal));
    } else if (args.arguments is PlaceSearchArguments) {
      toggledArgs = SearchResultPageArguments(PlaceSearchArguments(
          (args.arguments as PlaceSearchArguments).name,
          args.arguments.lat,
          args.arguments.lng,
          viewType: ((args.arguments as PlaceSearchArguments).viewType ==
                  SearchResultViewType.Normal)
              ? SearchResultViewType.Map
              : SearchResultViewType.Normal));
    } else {
      throw AssertionError("No such state for result screen");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, SearchResultPage.routeName,
          arguments: toggledArgs);
    });
  }

  @override
  Widget build(BuildContext context) {
    var _searchResultBloc =
        SearchResultBloc(riceRepository: context.read<RiceRepository>());

    final SearchResultPageArguments args =
        ModalRoute.of(context)!.settings.arguments as SearchResultPageArguments;

    return Scaffold(
      body: SearchResultScreen(
        searchResultBloc: _searchResultBloc,
        state: _getState(args, _searchResultBloc),
        searchTerm: args.arguments.name,
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation(),
    );
  }
}
