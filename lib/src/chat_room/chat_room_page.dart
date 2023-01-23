import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'index.dart';
import '../create_plan/create_plan_page.dart';
import '../find_chat_partner/find_chat_partner_page.dart';
import '../repository/model/plan.dart';
import '../repository/model/profile.dart';
import '../repository/model/user.dart';
import '../repository/rice_repository.dart';
import '../screen_arguments.dart';
import '../view/screen_bar.dart';
import '../view/user_avatar.dart';

import '../utils.dart';

class MenuItem {
  final String title;
  final IconData iconData;
  final VoidCallback onPressed;
  final Color? color;

  MenuItem({
    required this.title,
    required this.iconData,
    required this.onPressed,
    this.color,
  });
}

class ChatRoomPage extends StatelessWidget {
  static const String routeName = '/chatRoom';

  final _textEditingController1 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ChatRoomPageArguments args =
        ModalRoute.of(context)!.settings.arguments as ChatRoomPageArguments;

    var chatRoomBloc =
        ChatRoomBloc(riceRepository: context.read<RiceRepository>());

    if (args.metadata!.planId != null) {
      return _buildPlanPage(context, bloc: chatRoomBloc, args: args);
    }

    return _buildP2PPage(
      context,
      bloc: chatRoomBloc,
      args: args,
    );
  }

  List<User> _toUserList(List<Profile?> profiles) => profiles.map(
        (e) {
          return User(
            profile: e,
            id: e!.userId,
            emails: [],
            username: '',
          );
        },
      ).toList();

  Widget _buildPlanPage(
    BuildContext context, {
    required ChatRoomBloc bloc,
    required ChatRoomPageArguments args,
  }) {
    final List<Widget> title = [
      Flexible(
        flex: 1,
        child: Container(
          margin: EdgeInsets.only(right: 8),
          child: Text('${args.metadata!.name}'),
        ),
      ),
    ];

    title.add(_buildAvatars(_toUserList(args.profiles!)));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(args.metadata!.planId != null ? 182 : 56),
        child: Container(
          child: Column(
            children: <Widget>[
              AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                backgroundColor: Theme.of(context).backgroundColor,
                elevation: 0,
                title: Row(
                  children: title,
                ),
                actions: <Widget>[
                  _buildPopUpAction(args),
                ],
              ),
              _buildRestaurantHeader(args.metadata!.planId),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 2.0,
                spreadRadius: 0.0,
                offset: Offset(2.0, 2.0), // shadow direction: bottom right
              ),
            ],
          ),
        ),
      ),
      body: ChatRoomScreen(chatRoomBloc: bloc, args: args),
    );
  }

  Widget _buildPopUpAction(ChatRoomPageArguments args) {
    return PopupMenuButton<MenuItem>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.black26,
      ),
      onSelected: (selected) {
        selected.onPressed();
      },
      itemBuilder: (context) => _buildMenuItems(
        context,
        args,
        _toUserList(args.profiles!),
      ),
    );
  }

  List<PopupMenuEntry<MenuItem>> _buildMenuItems(
    BuildContext context,
    ChatRoomPageArguments args,
    List<User> users,
  ) {
    final List<MenuItem?> items = [
      MenuItem(
        title: 'Add Users',
        iconData: Icons.group_add,
        onPressed: () {
          Navigator.of(context).pushNamed(
            FindChatPartnerPage.routeName,
            arguments: FindChatPartnerPageArguments(
              chatId: args.metadata!.id,
              selectedUsers: users,
            ),
          );
        },
      ),
    ];

    if (args.metadata!.planId == null) {
      items.add(
        MenuItem(
          title: 'Create Plan',
          iconData: MaterialCommunityIcons.silverware_fork_knife,
          onPressed: () {
            Navigator.of(context).pushNamed(
              CreatePlanPage.routeName,
              arguments: CreatePlanPageArguments(
                null,
                users: users,
              ),
            );
          },
        ),
      );
    }

    items.add(
      null,
    );

    items.addAll(List.of([
      MenuItem(
        title: 'Change Group Name',
        iconData: MaterialCommunityIcons.pencil,
        onPressed: () => _openBottomSheet(context),
      ),
      MenuItem(
        title: 'Leave Group',
        iconData: MaterialCommunityIcons.location_exit,
        onPressed: () => _openLeaveGroupDialog(context),
      ),
      null,
      MenuItem(
        title: 'Delete Group',
        iconData: MaterialCommunityIcons.trash_can,
        color: Colors.redAccent,
        onPressed: () => _openDeleteGroupDialog(context),
      ),
    ]));

    return items.map<PopupMenuEntry<MenuItem>>((MenuItem? item) {
      if (item == null) {
        return PopupMenuDivider();
      }

      return PopupMenuItem<MenuItem>(
        value: item,
        child: Row(
          children: <Widget>[
            Icon(
              item.iconData,
              color: item.color ?? Colors.grey.shade800,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              item.title,
              style: TextStyle(color: item.color ?? Colors.grey.shade800),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Color(0xFFD8D8D8),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Group Name',
                    style: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    maxLines: 1,
                    controller: _textEditingController1,
                    decoration: InputDecoration(
                      hintText: 'A cool name for this group',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter some text';
                      }
                      if (value.length <= 3) {
                        return 'Please enter more text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  ButtonTheme(
                    minWidth: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3345A9),
                          shape: StadiumBorder()),
                      child: Text(
                        "Rename Group",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _openLeaveGroupDialog(BuildContext context) async {
    final willLeave = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure you want to leave this group?'),
            content: Text('This action cannot be undone'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(color: Color(0xFF3345A9)),
                ),
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                    textStyle: TextStyle(color: Colors.black)),
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });

    if (willLeave == true) {
      Navigator.of(context).pop();

      // TODO actually leave group
    }
  }

  void _openDeleteGroupDialog(BuildContext context) async {
    final willLeave = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure you want to delete this group?'),
            content: Text('This action cannot be undone'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    textStyle: TextStyle(color: Color(0xFF3345A9))),
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                    textStyle: TextStyle(color: Colors.black)),
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });

    if (willLeave == true) {
      Navigator.of(context).pop();

      // TODO actually delete group
    }
  }

  Widget _buildRestaurantHeader(String? plan) {
    if (plan == null) {
      return Container();
    }

    // FIXME add stream
    return StreamBuilder(
      builder: (BuildContext context, AsyncSnapshot<Plan> snapshot) {
        return Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    margin: EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          snapshot.data!.restaurant!.photo!,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                snapshot.data!.restaurant!.name!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                dayOfWeekAndDayOfMonthSuffixed(
                                    snapshot.data!.planDate!),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              snapshot.data!.restaurant!.address!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Icon(
                              snapshot.data!.isPublic!
                                  ? Icons.lock_open
                                  : Icons.lock,
                              color: Colors.black26,
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Divider(),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'View Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.indigo.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildAvatars(List<User> users) {
    final indexes = List.generate(users.take(3).length, (index) => index);

    final List<Widget> children = indexes.map<Widget>(
      (index) {
        return Positioned(
          left: 24.0 * index,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: UserAvatar(
              radius: 16,
              user: users[index].id,
              profile: users[index].profile,
            ),
          ),
        );
      },
    ).toList();

    if (users.length > 3) {
      children.add(
        Positioned(
          left: 72,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 16,
              child: Text(
                '+${users.length - 3}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.grey.shade300,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 34,
      constraints: BoxConstraints(maxWidth: 106),
      child: Stack(
        children: children,
      ),
    );
  }

  Widget _buildP2PPage(
    BuildContext context, {
    required ChatRoomBloc bloc,
    required ChatRoomPageArguments args,
  }) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(96.0),
        child: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0,
          title: Text(args.metadata!.name ?? '',
              style: Theme.of(context).textTheme.headline2),
          actions: args.metadata!.members!.length <= 1
              ? []
              : <Widget>[
                  // _buildPopUpAction(bloc, args),
                ],
        ),
      ),
      floatingActionButtonLocation: centerTopFloatingActionButtonLocation,
      floatingActionButton: args.metadata!.planId != null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: Theme.of(context).cardColor,
              onPressed: () {
                _navigateCreatePlan(
                  context,
                  _toUserList(args.profiles!),
                );
              },
              label: Text('Create new plan',
                  style: Theme.of(context).textTheme.subtitle2)),
      body: ChatRoomScreen(
        chatRoomBloc: bloc,
        args: args,
      ),
    );
  }

  _navigateCreatePlan(BuildContext context, List<User> users) async {
    await Navigator.pushNamed(
      context,
      CreatePlanPage.routeName,
      arguments: CreatePlanPageArguments(
        null,
        users: users,
      ),
    );
  }
}
