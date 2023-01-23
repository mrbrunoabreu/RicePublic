import 'dart:async';

import 'package:collection/collection.dart' show IterableNullableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../add_guests/add_guests_page.dart';
import '../base_bloc.dart';
import '../find_restaurant/find_restaurant_page.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/user.dart';
import '../screen_arguments.dart';
import '../utils.dart';
import '../view/restaurant.dart';
import 'dart:developer' as developer;

import 'index.dart';

class CreatePlanScreen extends StatefulWidget {
  final List<User> preSelectedUsers;

  const CreatePlanScreen({
    Key? key,
    required CreatePlanBloc createPlanBloc,
    this.preSelectedUsers = const [],
  })  : _createPlanBloc = createPlanBloc,
        super(key: key);

  final CreatePlanBloc _createPlanBloc;

  @override
  CreatePlanScreenState createState() {
    return CreatePlanScreenState();
  }
}

class CreatePlanScreenState extends State<CreatePlanScreen> {
  final formatter = DateFormat(DateFormat.HOUR24_MINUTE);

  final TextStyle titleTextStyle = TextStyle(
    color: Color(0xFFAAAAAA),
    fontSize: 20.0,
  );

  FocusNode? _focusNode;
  TextEditingController _noteTextController = TextEditingController();

  CreatePlanScreenState();

  @override
  void initState() {
    super.initState();
    this._load();

    _focusNode = FocusNode();
    _focusNode!.addListener(onFocusChange);
  }

  @override
  void dispose() {
    _focusNode!.dispose();
    super.dispose();
  }

  void onFocusChange() {
    if (_focusNode!.hasFocus) {
      // Hide sticker when keyboard appear
      // setState(() {
      //   isShowSticker = false;
      // });
    }
  }

  Future<bool> _onBackPress() {
    // if (isShowSoftKeyboard) {
    //   setState(() {
    //     isShowSoftKeyboard = false;
    //   });
    // } else {
    //   Navigator.pop(context);
    // }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final CreatePlanPageArguments? args =
        ModalRoute.of(context)!.settings.arguments as CreatePlanPageArguments?;

    if (args != null) {
      widget._createPlanBloc.add(OnRestaurantSelectEvent(args.restaurant));
    }

    return BlocBuilder<CreatePlanBloc, CreatePlanState>(
      bloc: widget._createPlanBloc,
      builder: (
        BuildContext context,
        CreatePlanState currentState,
      ) =>
          BaseBloc.widgetBlocBuilderDecorator(
        context,
        currentState,
        builder: (
          BuildContext context,
          CreatePlanState currentState,
        ) {
          List<Widget> list;

          if (currentState is ErrorCreatePlanState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ackAlert(context, currentState.errorMessage);
            });
            this.widget._createPlanBloc.add(OnCreatePlanEvent());
          }

          if (currentState is CreatedPlanState) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await ackDialog(
                context,
                'Success',
                'Have fun with your friends!',
              );

              this.widget._createPlanBloc.add(OnCreatePlanEvent());

              Navigator.pop(context, true);
            });
          }

          if (currentState is InCreatePlanState) {
            list = [
              _buildBody(
                restaurant: currentState.restaurant,
                day: currentState.day,
                isPublic: currentState.isPublic,
                planType: currentState.planType,
                friends: currentState.friends,
                editMode: args?.plan != null,
              )
            ];
          } else {
            list = [_buildBody(editMode: false)];
          }

          return WillPopScope(
            onWillPop: _onBackPress,
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: list,
            ),
          );
        },
      ),
    );
  }

  Widget _buildWhere(Restaurant? restaurant, BuildContext context) {
    return SizedBox(
        // height: 80,
        child: Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget?>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child:
                    Text('Where', style: Theme.of(context).textTheme.subtitle1),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                        context, FindRestaurantPage.routeName);

                    if (result != null) {
                      widget._createPlanBloc.add(
                        OnRestaurantSelectEvent(
                          result as Restaurant,
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: <Widget>[
                      Text(restaurant != null ? 'Change' : 'Find a restaurant',
                          style: Theme.of(context).textTheme.button),
                      Icon(Icons.keyboard_arrow_right,
                          color: Theme.of(context).toggleableActiveColor)
                    ],
                  ),
                ),
              )
            ],
          ),
          restaurant != null ? _buildLocation(restaurant) : null,
        ].whereNotNull().toList(),
      ),
    ));
  }

  _buildLocation(Restaurant restaurant) {
    if (restaurant == null) {
      return Container();
    }

    return SizedBox(
      child: Container(
        margin: EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => launchMapsByLocationUrl(
            restaurant.location!.coordinates![1],
            restaurant.location!.coordinates![0],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(
                    children: <Widget>[
                      buildImage(
                        width: 84,
                        height: 84,
                        url: restaurant.photo,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              child: Text(
                                restaurant.name ?? "",
                                softWrap: true,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                style: TextStyle(
                                  color: Color(0xFF222222),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(6, 4, 56, 4),
                              child: Text(
                                restaurant.address ?? "",
                                softWrap: true,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  color: Color(0xFF222222),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
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

  Widget _buildWhen(DateTime? day) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
          Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'When',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      child: Text(
                          day != null ? DateFormat.yMMMEd().format(day) : "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF3345A9),
                              fontWeight: FontWeight.bold)),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 1825)),
                      ).then((value) {
                        if (value != null) {
                          widget._createPlanBloc.add(OnDateSelectEvent(value));
                        }
                      });
                    },
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'at',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    child: Container(
                      width: 88,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.black12))),
                      child: Text(
                        day != null ? formatter.format(day) : '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF3345A9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      ).then((value) {
                        if (value != null) {
                          widget._createPlanBloc.add(OnTimeSelectEvent(value));
                        }
                      });
                    },
                  ),
                  // Text(''))
                ),
              )
            ],
          ),
        )
      ]),
    );
  }

  _buildPublicPlanSwitch(bool? isPublic) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: Text('Public plan',
                    softWrap: false,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.subtitle1)),
            Switch(
              value: isPublic ?? false,
              onChanged: (bool value) =>
                  widget._createPlanBloc.add(OnIsPublicSelectEvent(value)),
              activeTrackColor: Color(0xFFF0F0F0),
              activeColor: Color(0xFF3345A9),
            )
          ],
        ));
  }

  Widget _buildWhoDropdown(String? planType) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        'Who',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    DropdownButton<String>(
                      items: [
                        DropdownMenuItem(
                          value: 'anyone',
                          child: Text(
                            'Anyone can join',
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'friend',
                          child: Text(
                            'Friend Only',
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'invite',
                          child: Text(
                            'Invite Only',
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                      ],
                      onChanged: (value) => widget._createPlanBloc
                          .add(OnPlanTypeSelectEvent(value)),
                      value: planType ?? 'anyone',
                    ),
                  ],
                )),
          ],
        ));
  }

  Widget _buildFriends(List<User> friends) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            friends[index].profile!.picture!.url!,
                          )),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(friends[index].profile!.name!) ??
                            "" as Widget?)
                  ],
                )));
      },
      childCount: friends.length,
    ));
    // ]);
  }

  Widget _buildAddFriendsButton(List<User> friends) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
            padding: EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () => _navigateAddGuests(friends),
              child: Row(children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(36.0),
                  child: Container(
                    color: Color(0xFFCCCCCC),
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            color: Color(0xFF3345A9),
                          ),
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Add guest',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                )
              ]),
            ))
      ]),
    );
  }

  Widget _buildNoteSection() {
    return SizedBox(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Add note',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                controller: _noteTextController,
                style: Theme.of(context).textTheme.bodyText1,
                // maxLines: 10,
                maxLength: 140,
                focusNode: _focusNode,
                decoration: InputDecoration(
                    hintText: '(e.g.: Have a reservation? Date is decided?)'),
              ),
            )
          ]),
    );
  }

  Widget _buildSubmitButton(bool editMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ButtonTheme(
        minWidth: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3345A9), shape: StadiumBorder()),
          child: Text(editMode ? 'Update Plan' : "Create Plan",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          onPressed: () => _onSubmit(),
        ),
      ),
    );
  }

  void _onSubmit() {
    developer.log('Submiting...');

    if (!(widget._createPlanBloc.state is InCreatePlanState)) {
      return;
    }

    final InCreatePlanState currentState =
        widget._createPlanBloc.state as InCreatePlanState;

    if (currentState.restaurant == null) {
      showSnackbarError('Please select a restaurant');

      return;
    }

    if (currentState.day == null) {
      showSnackbarError('Please select a date');

      return;
    } else if (currentState.day!
        .isBefore(DateTime.now().add(Duration(minutes: 30)))) {
      showSnackbarError('Please set a time at least 30 minutes from now');

      return;
    }

    // if (currentState.friends?.isEmpty ?? true) {
    //   showSnackbarError('Please select one or more friends');
    //   return;
    // }

    final CreatePlanPageArguments? args =
        ModalRoute.of(context)!.settings.arguments as CreatePlanPageArguments?;

    widget._createPlanBloc.add(
      UploadPlanEvent(
        note: _noteTextController.text,
        planId: args?.plan?.id,
      ),
    );
  }

  void showSnackbarError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildBody({
    Restaurant? restaurant,
    DateTime? day,
    bool? isPublic,
    String? planType,
    List<User>? friends,
    required bool editMode,
  }) {
    return CustomScrollView(slivers: <Widget>[
      SliverToBoxAdapter(
        child: _buildWhere(restaurant, context),
      ),
      SliverToBoxAdapter(
        child: _buildWhen(day),
      ),
      SliverToBoxAdapter(
        child: _buildPublicPlanSwitch(isPublic),
      ),
      SliverToBoxAdapter(
        child: _buildWhoDropdown(planType),
        // child: _test(),
      ),
      _buildFriends(friends ?? []),
      _buildAddFriendsButton(friends ?? []),
      SliverToBoxAdapter(
        child: _buildNoteSection(),
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SafeArea(
              child: _buildSubmitButton(editMode),
            ),
          ],
        ),
      )
    ]);
  }

  void _load([bool isError = false]) {
    widget._createPlanBloc.add(LoadCreatePlanEvent(isError));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final CreatePlanPageArguments args =
          ModalRoute.of(context)!.settings.arguments as CreatePlanPageArguments;

      if (args.plan != null) {
        widget._createPlanBloc.add(OnIsPublicSelectEvent(args.plan!.isPublic));
        widget._createPlanBloc.add(OnDateSelectEvent(args.plan!.planDate));

        String planType;

        if (args.plan!.isJoinable!) {
          planType = 'anyone';
        } else if (args.plan!.isFollowersOnly!) {
          planType = 'friends';
        } else {
          planType = 'invite';
        }

        widget._createPlanBloc.add(OnPlanTypeSelectEvent(planType));

        _noteTextController.text = args.plan!.additionalComments!;
      }

      if (this.widget.preSelectedUsers.isNotEmpty) {
        widget._createPlanBloc.add(
          OnFriendsSelectEvent(this.widget.preSelectedUsers.where((element) {
            if (args?.plan != null) {
              return element.id != args.plan!.userId;
            }

            return true;
          }).toList()),
        );
      }
    });
  }

  _navigateAddGuests(List<User> friends) async {
    dynamic selectedFriends = await Navigator.pushNamed(
      context,
      AddGuestsPage.routeName,
      arguments: AddGuestsPageArguments(users: friends),
    );

    developer.log('Got a response...');

    if (selectedFriends is List) {
      developer.log('Will select new users...');

      selectedFriends = selectedFriends.map<User>((e) => e as User).toList();

      widget._createPlanBloc
          .add(OnFriendsSelectEvent(selectedFriends as List<User>?));
    }
  }
}
