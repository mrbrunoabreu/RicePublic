import 'package:collection/collection.dart' show IterableNullableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../base_bloc.dart';
import '../create_plan/create_plan_page.dart';
import 'index.dart';
import '../repository/model/plan.dart';
import '../profile/profile_page.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/user.dart';
import '../screen_arguments.dart';
import '../utils.dart';
import '../view/restaurant.dart';

class PlanDetailScreen extends StatefulWidget {
  const PlanDetailScreen({
    Key? key,
    required PlanDetailBloc planDetailBloc,
    this.plan,
  })  : _planDetailBloc = planDetailBloc,
        super(key: key);
  final Plan? plan;
  final PlanDetailBloc _planDetailBloc;

  @override
  PlanDetailScreenState createState() {
    return PlanDetailScreenState(_planDetailBloc);
  }
}

class PlanDetailScreenState extends State<PlanDetailScreen> {
  final PlanDetailBloc _planDetailBloc;

  PlanDetailScreenState(this._planDetailBloc);

  @override
  void initState() {
    super.initState();
    this._load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onBackPress() {
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanDetailBloc, PlanDetailState>(
        bloc: widget._planDetailBloc,
        builder: (
          BuildContext context,
          PlanDetailState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              PlanDetailState currentState,
            ) {
              List<Widget> list = [
                _buildBody(
                    currentState is InPlanDetailState
                        ? currentState.plan!
                        : widget.plan!,
                    currentState is InPlanDetailState
                        ? currentState.currentUser
                        : null)
              ];
              if (currentState is ErrorPlanDetailState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage);
                });
              }

              if (currentState is PlanDeletedState) {
                this
                    .widget
                    ._planDetailBloc
                    .add(LoadPlanDetailEvent(false, plan: widget.plan));

                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await ackDialog(context, 'Success', 'Plan Deleted!');

                  Navigator.of(context).pop();
                });
              }
              return WillPopScope(
                  onWillPop: _onBackPress,
                  child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: list));
            }));
  }

  Widget _buildWhere(Plan plan) {
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
            ],
          ),
          plan.restaurant != null ? _buildLocation(plan.restaurant!) : null,
        ].whereNotNull().toList(),
      ),
    ));
  }

  _buildLocation(Restaurant restaurant) {
    return SizedBox(
      child: Container(
        margin: EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => launchMapsByLocationUrl(
              restaurant.location!.coordinates![1],
              restaurant.location!.coordinates![0]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(
                          5,
                        ),
                        child: buildImage(
                          width: 80,
                          height: 80,
                          url: restaurant.photo,
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                restaurant.name!,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.fromLTRB(12, 4, 56, 4),
                                child: Text(
                                  restaurant.address!,
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                  style: Theme.of(context).textTheme.headline4,
                                )),
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

  Widget _buildWhen(Plan plan) {
    String formattedDate = DateFormat.yMMMEd().format(plan.planDate!);
    String formattedTime = DateFormat.jm().format(plan.planDate!);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                    child: SizedBox(
                      width: 160,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(formattedDate,
                            style: Theme.of(context).textTheme.button),
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'at',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                  Expanded(
                    child: SizedBox(
                      width: 80,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(formattedTime,
                            style: Theme.of(context).textTheme.button),
                      ),
                      // Text(''))
                    ),
                    // Text(''))
                  ),
                ],
              ),
            )
          ]),
    );
  }

  Widget _buildAddWhoSection(Plan plan) {
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
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          ProfilePage.routeName,
                          arguments: ProfilePageArguments(
                            userId: plan.users![index].id,
                          ),
                        );
                      },
                      child: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            plan.users![index].profile!.picture == null
                                ? 'https://ui-avatars.com/api/?color=3345A9&name=${plan.users![index].profile!.name}'
                                : plan.users![index].profile!.picture!.url!,
                          )),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(plan.users![index].profile!.name!))
                ],
              ),
            ),
          );
        },
        childCount: plan.users!.length,
      ),
    );
    // ]);
  }

  Widget _buildCommentSection(Plan plan) {
    return SizedBox(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Text(
                'Note',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Text(
                  plan.additionalComments != null
                      ? plan.additionalComments!
                      : '',
                  style: Theme.of(context).textTheme.bodyText1),
            )
          ]),
    ));
  }

  Widget _buildBody(Plan plan, User? currentUser) {
    return CustomScrollView(slivers: <Widget>[
      SliverToBoxAdapter(
        child: _buildWhere(plan),
      ),
      SliverToBoxAdapter(
        child: _buildWhen(plan),
      ),
      // SliverToBoxAdapter(
      //   child: _buildPublicPlanSwitch(),
      // ),
      SliverToBoxAdapter(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Who',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                            plan.isJoinable == null || plan.isJoinable!
                                ? 'Anyone can join'
                                : 'Private',
                            style: Theme.of(context).textTheme.button),
                      ],
                    )),
              ],
            )),
        // child: _test(),
      ),
      _buildAddWhoSection(plan),
      SliverToBoxAdapter(
        child: _buildCommentSection(plan),
      ),
      SliverToBoxAdapter(
        child: plan.userId != currentUser?.id
            ? Container()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: ButtonTheme(
                      minWidth: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3345A9),
                          shape: StadiumBorder(),
                        ),
                        child: Text("Edit Plan",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          _navigateCreatePlanPage(plan);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: ButtonTheme(
                      minWidth: double.infinity,
                      height: 50,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: StadiumBorder(),
                        ),
                        child: Text(
                          "Delete Plan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _askDeleteConfirmation(plan),
                      ),
                    ),
                  ),
                ],
              ),
      )
    ]);
  }

  _askDeleteConfirmation(Plan plan) async {
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure you want to delete this plan?'),
            content: Text('This action cannot be undone'),
            actions: [
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });

    if (result == true) {
      widget._planDetailBloc.add(DeletePlanEvent(planId: plan.id));
    }
  }

  _navigateCreatePlanPage(Plan plan) async {
    final result = await Navigator.pushNamed(
      context,
      CreatePlanPage.routeName,
      arguments: CreatePlanPageArguments(
        plan.restaurant,
        users: plan.users,
        plan: plan,
      ),
    );
    if (result as bool? ?? false) {
      widget._planDetailBloc.add(LoadPlanDetailEvent(true, plan: widget.plan));
    }
  }

  void _load([bool isError = false]) {
    widget._planDetailBloc.add(UnPlanDetailEvent());
    widget._planDetailBloc.add(LoadPlanDetailEvent(true, plan: widget.plan));
  }
}
