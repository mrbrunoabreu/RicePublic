import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import 'index.dart';
import '../chat_room/chat_room_page.dart';
import '../find_chat_partner/find_chat_partner_page.dart';
import '../repository/model/profile.dart';
import '../view/home_bar.dart';
import '../view/user_avatar.dart';
import 'package:ionicons/ionicons.dart';

import 'dart:async';

import '../screen_arguments.dart';
import '../utils.dart';

import '../repository/model/chat.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({
    Key? key,
    required ChatListBloc chatListBloc,
  })  : _chatListBloc = chatListBloc,
        super(key: key);

  final ChatListBloc _chatListBloc;

  @override
  ChatListScreenState createState() {
    return ChatListScreenState(_chatListBloc);
  }
}

class ChatListScreenState extends State<ChatListScreen>
    with WidgetsBindingObserver {
  final ChatListBloc _chatListBloc;
  final _kewordTextController = TextEditingController();

  ChatListScreenState(this._chatListBloc);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    this._load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatListBloc.add(UnChatListEvent());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Timer(
          Duration(milliseconds: 1500),
          () => _load(),
        );
      });
    }
    if (state == AppLifecycleState.paused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Timer(
          Duration(milliseconds: 500),
          () => widget._chatListBloc.add(UnChatListEvent()),
        );
      });
    }
  }

  Future<bool> _onWillPop() {
    // if (!_pc.isPanelClosed()) {
    //   _pc.close();
    //   return Future.value(false);
    // }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatListBloc, ChatListState>(
        bloc: widget._chatListBloc,
        builder: (
          BuildContext context,
          ChatListState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              ChatListState currentState,
            ) {
              List<Widget> list = [
                Column(
                  children: <Widget>[
                    PageBar(
                      title: 'Chat',
                      rightIcon: Icon(
                        Ionicons.person_add_outline,
                      ),
                      rightIconTapCallback: () async {
                        await Navigator.pushNamed(
                          context,
                          FindChatPartnerPage.routeName,
                        );
                        _load();
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Material(
                        elevation: 3,
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8.0),
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: _kewordTextController,
                          decoration: InputDecoration(
                              hintText: "Enter a friend name",
                              hintStyle: Theme.of(context).textTheme.bodyText1,
                              border: InputBorder.none,
                              prefixIcon: Icon(Ionicons.search_outline)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child: _buildBody(context, currentState),
                      ),
                    ),
                  ],
                ),
              ];

              if (currentState is ErrorChatListState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage);
                });
              }
              return WillPopScope(
                  onWillPop: _onWillPop,
                  child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: list));
            }));
  }

  Widget _buildChatItem(int index, ChatMetadata chat) {
    if (chat.users == null) return Container();

    List<Profile?> profiles =
        chat.members!.map((e) => chat.users![e]!.profile).toList();
    Widget avatar;
    if (chat.members!.length == 1) {
      avatar = UserAvatar(
          radius: 30, user: chat.members!.first, profile: profiles.first);
    } else {
      avatar = _buildChatGroupAvatars(chat.members!, profiles);
    }

    String? chatName = '';

    if (chat.members!.length == 1) {
      chatName = profiles[0]!.name;
    } else if (chat.name != null) {
      chatName = chat.name;
    } else {
      chatName = profiles.map((profile) => profile!.name).join(', ');
    }

    chat.name = chatName;
    return InkWell(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          ChatRoomPage.routeName,
          arguments:
              ChatRoomPageArguments(index, metadata: chat, profiles: profiles),
        );
        _load();
      },
      child: Container(
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: avatar,
            ),
            Expanded(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          chatName ?? '',
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 0),
                          child: (chat.lastMessage?.content?.isNotEmpty == true)
                              ? Text(
                                  chat.lastMessage!.type ==
                                          ChatMessage.TYPE_LOCATION
                                      ? 'Shared a restaurant'
                                      : chat.lastMessage!.content!,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.bodyText1,
                                )
                              : Container())
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  _buildChatGroupAvatars(List<String?> userIds, List<Profile?> profiles) {
    final length = userIds.length;

    final areMoreThan4 = length > 4;

    final indexes = List.generate(
        userIds.take(areMoreThan4 ? 3 : 4).length, (index) => index);

    final avatars = indexes.map<Widget>(
      (index) {
        return Positioned(
          left: index % 2 == 0 ? 0 : null,
          right: index % 2 == 1 ? 0 : null,
          top: index <= 1 ? 0 : null,
          bottom: index >= 2 ? 0 : null,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: UserAvatar(
              radius: 15,
              user: userIds[index],
              profile: profiles[index],
            ),
          ),
        );
      },
    ).toList();

    if (areMoreThan4) {
      avatars.add(
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 15,
              child: Text(
                '+${length - 3}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.grey.shade300,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 60,
      height: 60,
      child: Stack(
        children: avatars,
      ),
    );
  }

  _buildBody(BuildContext context, ChatListState currentState) {
    if (currentState is InChatListState) {
      return MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: StreamBuilder<List<ChatMetadata>>(
            stream: currentState.chats.chats(),
            builder: (BuildContext context,
                AsyncSnapshot<List<ChatMetadata>> snapshot) {
              if (!snapshot.hasData) return const Text('Connecting...');
              final int cardLength = snapshot.data!.length;
              return new ListView.builder(
                itemCount: cardLength,
                itemBuilder: (BuildContext context, int index) {
                  final ChatMetadata _card = snapshot.data![index];
                  if (notMatchingQuery(_card.name)) {
                    return Container();
                  }

                  return _buildChatItem(index, _card);
                },
              );
            },
          ));
    }
    return Container();
  }

  bool notMatchingQuery(String? name) {
    return _kewordTextController.text.isNotEmpty &&
        !name!.toLowerCase().contains(_kewordTextController.text.toLowerCase());
  }

  void _load([bool isError = false]) {
    widget._chatListBloc.add(UnChatListEvent());
    widget._chatListBloc.add(LoadChatListEvent(isError));

    // _kewordTextController.addListener(() {
    //   this.setState(() {});
    // });
  }
}
