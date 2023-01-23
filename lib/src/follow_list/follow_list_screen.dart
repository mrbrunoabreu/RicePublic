import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import '../find_restaurant/find_restaurant_page.dart';
import 'follow_list_bloc.dart';
import 'follow_list_event.dart';
import 'follow_list_state.dart';
import '../profile/index.dart';
import '../repository/model/profile.dart';
import '../screen_arguments.dart';
import 'package:ionicons/ionicons.dart';

class FollowListScreen extends StatefulWidget {
  final FollowListBloc bloc;
  final FollowListPageArguments args;

  FollowListScreen({required this.bloc, required this.args});

  @override
  _FollowListScreenState createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowListBloc, FollowListState>(
      bloc: widget.bloc,
      builder: (BuildContext context, FollowListState state) {
        return BaseBloc.widgetBlocBuilderDecorator(context, state, builder: (
          BuildContext context,
          FollowListState state,
        ) {
          if (state is InFollowListState) {
            return _buildLayout(state, context);
          }

          return Container();
        });
      },
    );
  }

  Widget _buildLayout(InFollowListState state, BuildContext context) {
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
    ]);

    children.addAll(
      state.userList!.map(
        (user) => _buildItem(user.item1, user.item2, context),
      ),
    );

    return Container(
      color: Theme.of(context).cardColor,
      child: ListView(
        children: children,
      ),
    );
  }

  Widget _buildHeader(InFollowListState state) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // Icon(Ionicons.people
              // ),
              SizedBox(
                width: 6,
              ),
              Text(
                  this.widget.args.type == FollowListPageArgumentType.Followers
                      ? "You are follwed by"
                      : "You are following",
                  style: Theme.of(context).textTheme.button)
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Icon(Ionicons.people),
              SizedBox(
                width: 6,
              ),
              Text(
                  "${state.userList?.isEmpty == true ? '' : state.userList!.length} People",
                  style: Theme.of(context).textTheme.subtitle2)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String userId, Profile profile, BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          _navigateToUserProfile(profile.userId);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildPhoto(profile.picture!.url!),
              SizedBox(
                width: 16,
              ),
              Column(children: [
                Text(
                  profile.name!,
                  style: Theme.of(context).textTheme.headline2,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto(String url) {
    return Container(
      height: 60,
      width: 60,
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
    widget.bloc.add(UnFollowListEvent());
    widget.bloc.add(
      LoadFollowListEvent(userIds: this.widget.args.userIds),
    );
  }

  _navigateToUserProfile(String? userId) {
    print('id do seguidor: $userId');
    Navigator.of(context).pushNamed(
      ProfilePage.routeName,
      arguments: ProfilePageArguments(
        userId: userId,
      ),
    );
  }
}
