import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rice/src/find_restaurant/find_restaurant_bloc.dart';
import 'package:rice/src/find_restaurant/find_restaurant_event.dart';
import 'package:rice/src/find_restaurant/find_restaurant_state.dart';
import '../repository/model/restaurant.dart';
import '../repository/rice_meteor_service.dart';
import '../repository/rice_repository.dart';
import 'package:rice/src/view/restaurant.dart';

class FindRestaurantScreen extends StatefulWidget {
  final FindRestaurantBloc bloc;

  FindRestaurantScreen({
    required this.bloc,
  }) {}

  @override
  _FindRestaurantScreenState createState() => _FindRestaurantScreenState();
}

class _FindRestaurantScreenState extends State<FindRestaurantScreen> {
  final searchController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();

    searchController.addListener(_onChangeSearch);

    _load();
  }

  @override
  void dispose() {
    searchController.removeListener(_onChangeSearch);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FindRestaurantBloc, FindRestaurantState>(
      bloc: widget.bloc,
      builder: (context, currentState) {
        if (currentState is InFindRestaurantState) {
          return SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: <Widget>[
                      Material(
                        elevation: 3,
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15.0),
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Enter a restaurant name",
                            hintStyle: Theme.of(context).textTheme.bodyText1,
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: currentState is UnFindRestaurantState
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.separated(
                          itemCount: currentState.restaurants.length,
                          padding: EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            return _buildSearchResult(
                              restaurant: currentState.restaurants[index],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: 16,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }

        return Container();
      },
    );
  }

  _onChangeSearch() {
    if (searchController.text.isNotEmpty) {
      this.widget.bloc.add(SearchByNameEvent(name: searchController.text));
    }
  }

  _load() {
    this.widget.bloc.add(LoadFindRestaurantEvent());
  }

  _buildSearchResult({
    required Restaurant restaurant,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(
          restaurant,
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: buildImage(
              width: 56,
              height: 56,
              url: restaurant.photo,
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  restaurant.address!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFAAAAAA),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
