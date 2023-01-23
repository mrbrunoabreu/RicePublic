import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import '../create_personal_list/create_personal_list.dart' as view;
import 'personal_lists_bloc.dart';
import 'personal_lists_state.dart';
import '../personal_restaurants/personal_restaurants_page.dart';
import '../repository/model/profile.dart';
import '../screen_arguments.dart';
import '../utils.dart';
import '../view/my_list_item.dart';
import 'personal_lists_event.dart';
import 'dart:developer' as developer;

class PersonalListsScreen extends StatefulWidget {
  final PersonalListsBloc bloc;
  final PersonalListsPageArguments? arguments;

  PersonalListsScreen({required this.bloc, required this.arguments});

  @override
  _PersonalListsScreenState createState() => _PersonalListsScreenState();
}

class _PersonalListsScreenState extends State<PersonalListsScreen> {
  @override
  void initState() {
    _load();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonalListsBloc, PersonalListsState>(
      bloc: this.widget.bloc,
      builder: (BuildContext context, PersonalListsState state) {
        return BaseBloc.widgetBlocBuilderDecorator(
          context,
          state,
          builder: (context, dynamic state) {
            if (state is ErrorPersonalListsState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ackAlert(context, state.errorMessage);
              });
            }

            if (state is AddedRestaurantToListState) {
              _load();

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await ackDialog(context, 'Success', 'Added restaurant to list');

                Navigator.of(context).pop();
              });
            }

            if (state is InPersonalListsState) {
              return ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  this.widget.arguments!.readonly == true
                      ? Container()
                      : Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF3345A9),
                                shape: StadiumBorder(),
                              ),
                              child: Text(
                                "Create New List",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: _openCreateListBottomSheet,
                            ),
                          ),
                        ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: state.personalLists
                        .map(
                          (item) => GestureDetector(
                            onTap: () => _onTapListItem(item),
                            child: MyListItem(
                              metadata: item,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            }

            return Container();
          },
        );
      },
    );
  }

  _onTapListItem(ListMetadata item) {
    if (this.widget.arguments!.restaurant == null) {
      Navigator.of(context).pushNamed(
        PersonalRestaurantsPage.routeName,
        arguments: PersonalRestaurantsPageArguments(
          listId: item.id,
          name: item.name,
        ),
      );
    } else {
      this.widget.bloc.add(
            AddRestaurantToListEvent(
              listId: item.id,
              restaurant: this.widget.arguments!.restaurant,
            ),
          );
    }
  }

  _openCreateListBottomSheet() async {
    final shouldRefresh = await showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: view.CreatePersonalList(
            onComplete: (shouldRefresh) {
              Navigator.of(context).pop(shouldRefresh);
            },
          ),
        );
      },
    );

    if (shouldRefresh == true) {
      _load();
    }
  }

  _load() {
    developer.log('Reloading personal lists...');
    if (this.widget.arguments!.userId != null) {
      this.widget.bloc.add(UnPersonalListsEvent());
      this.widget.bloc.add(
            LoadPersonalListsEvent(
              userId: this.widget.arguments!.userId,
            ),
          );
    } else {
      this.widget.bloc.add(UnPersonalListsEvent());
      this.widget.bloc.add(
            LoadPersonalListsEvent(),
          );
    }
  }
}
