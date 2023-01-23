import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import '../find_restaurant/find_restaurant_page.dart';
import 'personal_restaurants_bloc.dart';
import 'personal_restaurants_event.dart';
import 'personal_restaurants_state.dart';
import '../repository/model/restaurant.dart';
import '../restaurant_detail/restaurant_detail_page.dart';
import '../screen_arguments.dart';
import 'package:ionicons/ionicons.dart';

class PersonalRestaurantsScreen extends StatefulWidget {
  final PersonalRestaurantsBloc bloc;
  final PersonalRestaurantsPageArguments args;

  PersonalRestaurantsScreen({required this.bloc, required this.args});

  @override
  _PersonalRestaurantsScreenState createState() =>
      _PersonalRestaurantsScreenState();
}

class _PersonalRestaurantsScreenState extends State<PersonalRestaurantsScreen> {
  @override
  void initState() {
    _load();
    super.initState();
  }

  bool mutualSwitch = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonalRestaurantsBloc, PersonalRestaurantsState>(
      bloc: widget.bloc,
      builder: (BuildContext context, PersonalRestaurantsState state) {
        return BaseBloc.widgetBlocBuilderDecorator(context, state, builder: (
          BuildContext context,
          PersonalRestaurantsState state,
        ) {
          if (state is InPersonalRestaurantsState) {
            return _buildLayout(state, context);
          }
          return Container();
        });
      },
    );
  }

  Widget _buildLayout(InPersonalRestaurantsState state, BuildContext context) {
    final divider = Container(
      margin: EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Divider(),
    );

    final List<Widget> children = [];

    children.addAll([
      _buildHeader(state),
      divider,
      if (this.widget.args.sharedRestaurantsView! &&
          this.widget.args.mutualRestaurants != null)
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: mutualSwitch ? _loadMutual : _load,
              child: mutualSwitch
                  ? Text(
                      'See mutual (${this.widget.args.mutualRestaurants?.length})')
                  : Text('See all'),
            ),
          ),
        ),
      this.widget.args.readonly!
          ? Container()
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: ButtonTheme(
                minWidth: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3345A9),
                    shape: StadiumBorder(),
                  ),
                  child: Text(
                    "Add Restaurant",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _onAddRestaurant(),
                ),
              ),
            )
    ]);

    children.addAll(
      state.personalList!.restaurants!.map(
        (restaurant) => _buildItem(restaurant!, context),
      ),
    );

    return Container(
      color: Theme.of(context).cardColor,
      child: ListView(
        children: children,
      ),
    );
  }

  void _onAddRestaurant() async {
    final result = await Navigator.of(context).pushNamed(
      FindRestaurantPage.routeName,
    );

    if (result != null) {
      this.widget.bloc.add(
            AddRestaurantToList(
              restaurant: result as Restaurant,
              listId: this.widget.args.listId,
            ),
          );

      widget.bloc.add(
        LoadPersonalRestaurantsEvent(
          listId: this.widget.args.listId,
          restaurants: this.widget.args.restaurants,
        ),
      );
    }
  }

  Widget _buildHeader(InPersonalRestaurantsState state) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Icon(Ionicons.happy_outline),
              SizedBox(
                width: 6,
              ),
              Text(
                  'By ${state.personalList!.createdBy?.profile?.name ?? this.widget.args.by ?? ''}',
                  style: Theme.of(context).textTheme.button)
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Icon(Ionicons.restaurant_outline),
              SizedBox(
                width: 6,
              ),
              Text('${state.personalList!.restaurants!.length} Restaurants',
                  style: Theme.of(context).textTheme.subtitle2)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMutualFilter() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          child: Text('See mutual'),
          onPressed: null,
        ),
      ),
    );
  }

  Widget _buildItem(Restaurant restaurant, BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            RestaurantDetailPage.routeName,
            arguments: RestaursntDetailPageArguments(restaurant),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: restaurant.photo != null
                    ? [_buildPhoto(restaurant.photo!)]
                    : [],
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 16, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 4),
                        child: Text(
                          restaurant.name!,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                restaurant.address!,
                                style: Theme.of(context).textTheme.headline4,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),
                            restaurant.rating == null
                                ? Container()
                                : Row(
                                    children: <Widget>[
                                      Icon(
                                        Ionicons.star,
                                        size: 14,
                                        color: Color(
                                          0xfFFF7C669,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        '${restaurant.rating}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto(String url) {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          16,
        ),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            url,
          ),
        ),
      ),
    );
  }

  _load() {
    widget.bloc.add(UnPersonalRestaurantEvent());
    mutualSwitch = true;
    widget.bloc.add(
      LoadPersonalRestaurantsEvent(
        listId: this.widget.args.listId,
        restaurants: this.widget.args.restaurants,
      ),
    );
  }

  _loadMutual() {
    widget.bloc.add(UnPersonalRestaurantEvent());
    mutualSwitch = false;
    widget.bloc.add(
      LoadPersonalRestaurantsEvent(
        listId: this.widget.args.listId,
        restaurants: this.widget.args.mutualRestaurants,
      ),
    );
  }
}
