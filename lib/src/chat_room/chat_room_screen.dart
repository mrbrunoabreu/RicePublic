import 'dart:async';

import 'package:animated_stream_list_nullsafety/animated_stream_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../base_bloc.dart';
import 'index.dart';
import '../create_plan/create_plan_page.dart';
import '../repository/model/chat.dart';
import '../repository/model/profile.dart';
import '../repository/model/restaurant.dart';
import '../repository/model/user.dart';
import '../screen_arguments.dart';
import '../utils.dart';
import '../view/restaurant.dart';
import '../view/user_avatar.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'dart:developer' as developer;

class ChatRoomScreen extends StatefulWidget {
  final ChatRoomPageArguments args;
  const ChatRoomScreen({
    Key? key,
    required ChatRoomBloc chatRoomBloc,
    required this.args,
  })  : _chatRoomBloc = chatRoomBloc,
        super(key: key);

  final ChatRoomBloc _chatRoomBloc;

  @override
  ChatRoomScreenState createState() {
    return ChatRoomScreenState();
  }
}

class ChatRoomScreenState extends State<ChatRoomScreen>
    with WidgetsBindingObserver {
  final FocusNode focusNode = new FocusNode();

  final ScrollController _scrollController = ScrollController();

  final TextEditingController textMessageController =
      new TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      this._load();
    });
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
          () => widget._chatRoomBloc
              .add(UnChatRoomEvent(this.widget.args.profiles)),
        );
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    this.widget._chatRoomBloc.add(UnChatRoomEvent(this.widget.args.profiles));
    super.dispose();
  }

  // Hide sticker or back
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

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    // setState(() {
    //   isShowSoftKeyboard = !isShowSoftKeyboard;
    // });
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      // setState(() {
      //   isShowSticker = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatRoomBloc, ChatRoomState>(
      bloc: widget._chatRoomBloc,
      builder: (
        BuildContext context,
        ChatRoomState currentState,
      ) {
        return BaseBloc.widgetBlocBuilderDecorator(
          context,
          currentState,
          builder: (
            BuildContext context,
            ChatRoomState currentState,
          ) {
            List<Widget> list = [];

            if (currentState is InChatRoomState) {
              if (currentState.text != null) {
                textMessageController.text = currentState.text!;
              }

              list.add(
                _buildMessagesAndInput(
                  state: currentState,
                ),
              );
            }

            if (currentState is ErrorChatRoomState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ackAlert(context, currentState.errorMessage);
              });
            }

            return WillPopScope(
              onWillPop: _onBackPress,
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: list,
              ),
            );
          },
        );
      },
    );
  }

  _buildMessagesAndInput({required InChatRoomState state}) {
    return Column(
      children: <Widget>[
        _buildListMessage(
          state.profiles,
          state.subscription.messages(),
          currentUser: state.currentUser,
        ),
        SafeArea(
          child: Column(
            children: <Widget>[
              // SendMessageRequest(
              //   message: state.messageRequest,
              //   isLoading: state.isChangingStatus,
              //   onChange: _onChangeSendMessageRequest,
              // ),
              _buildInput(state: state),
            ],
          ),
        ),
      ],
    );
  }

  // _onChangeSendMessageRequest({
  //   @required String status,
  //   @required SendMessageMetadata sendMessageRequest,
  // }) async {
  //   final ChatRoomPageArguments args =
  //       ModalRoute.of(context).settings.arguments;

  //   widget._chatRoomBloc.add(ChangingSendMessageRequestEvent());

  //   widget._chatRoomBloc.add(
  //     ChangeSendMessageRequestEvent(
  //       chat: args.metadata,
  //       status: status,
  //       request: sendMessageRequest,
  //     ),
  //   );
  // }

  Widget buildItem(
    int index,
    Profile? profile,
    User currentUser,
    ChatMessage message, {
    required bool flat,
    required TextDirection direction,
  }) {
    Widget messageWidget = Container();

    if (message.type == ChatMessage.TYPE_TEXT) {
      messageWidget = _buildTextMessage(message, direction);
    } else if (message.type == ChatMessage.TYPE_LOCATION) {
      messageWidget = _buildLocationMessage(message, direction);
    }

    return Row(
      textDirection: direction,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            right: 16,
            left: 16,
          ),
          child: flat
              ? SizedBox(
                  width: 48,
                )
              : UserAvatar(
                  radius: 24,
                  user: message.senderId,
                  profile: (profile != null) ? profile : null),
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: direction == TextDirection.rtl
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: <Widget>[
              flat
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Row(
                        textDirection: direction,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              right: direction == TextDirection.rtl ? 0 : 16,
                              left: direction == TextDirection.rtl ? 16 : 0,
                            ),
                            child: Text(
                              direction == TextDirection.rtl
                                  ? 'You'
                                  : profile?.name ?? 'You',
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              timeago.format(message.createdAt!),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 11.0,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              messageWidget,
            ],
          ),
        ),
      ],
    );
  }

  _buildTextMessage(ChatMessage message, TextDirection direction) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 96,
      ),
      child: Text(
        message.message!,
        style: TextStyle(
            fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal),
      ),
      decoration: _getMessageDecoration(direction),
    );
  }

  BoxDecoration _getMessageDecoration(TextDirection direction) {
    return BoxDecoration(
      color: direction == TextDirection.rtl
          ? Colors.indigo.shade50
          : Color(0xFFC4CDFF),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(direction == TextDirection.rtl ? 16 : 0),
        bottomLeft: Radius.circular(16),
        topRight: Radius.circular(direction == TextDirection.rtl ? 0 : 16),
        bottomRight: Radius.circular(16),
      ),
    );
  }

  _buildLocationMessage(ChatMessage message, TextDirection direction) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 96),
      child: FutureBuilder(
        future: this.widget._chatRoomBloc.findRestaurant(
              restaurantId: message.message,
            ),
        builder: (BuildContext context, AsyncSnapshot<Restaurant?> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return CircularProgressIndicator();
          }

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 8),
                    child: buildImage(
                      width: 48,
                      height: 48,
                      url: snapshot.data!.photo,
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.name!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          snapshot.data!.address!,
                          style: TextStyle(
                            color: direction == TextDirection.ltr
                                ? Color(0xFF616161)
                                : Color(0xFFAAAAAA),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  color: Theme.of(context).cardColor,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToCreatePlan(snapshot.data),
                child: Text('Create New Plan',
                    style: Theme.of(context).textTheme.subtitle2),
              ),
            ],
          );
        },
      ),
      decoration: _getMessageDecoration(direction),
    );
  }

  void _determineIfJumpToBottom() {
    // Scroll to bottom when user is not scrolling and the current offset is not at the bottom
    if (_scrollController.position.userScrollDirection ==
            ScrollDirection.idle &&
        _scrollController.offset.toStringAsFixed(1) ==
            _scrollController.position.maxScrollExtent?.toStringAsFixed(1)) {
      _scrollToBottom();
    }
  }

  void _navigateToCreatePlan(Restaurant? restaurant) async {
    final profiles = await this.widget.args.profiles!;
    await Navigator.of(context).pushNamed(
      CreatePlanPage.routeName,
      arguments: CreatePlanPageArguments(
        restaurant,
        users: profiles
            .map(
              (e) => User(
                id: e!.userId,
                username: '',
                emails: [],
                profile: e,
              ),
            )
            .toList(),
      ),
    );
    this._load();
  }

  Widget _buildListMessage(
    List<Profile?>? profiles,
    Stream<List<ChatMessage>> messages, {
    required User currentUser,
  }) {
    String? prevUser = '';
    String? prevMessage = '';
    return Expanded(
      child: AnimatedStreamList<ChatMessage>(
        scrollController: _scrollController,
        streamList: messages,
        padding: EdgeInsets.only(top: 32, bottom: 16),
        itemBuilder: (
          ChatMessage item,
          int index,
          BuildContext context,
          Animation<double> animation,
        ) {
          _determineIfJumpToBottom();
          bool isSameUser =
              prevUser == item.senderId && prevMessage != item.message;

          Profile? profile = (item.senderId == currentUser.id)
              ? currentUser.profile
              : profiles!.firstWhere(
                  (element) => element!.userId == item.senderId,
                  orElse: () => null,
                );

          final widget = buildItem(
            index,
            profile,
            currentUser,
            item,
            flat: isSameUser,
            direction: currentUser.id == item.senderId
                ? TextDirection.rtl
                : TextDirection.ltr,
          );
          prevUser = item.senderId;
          prevMessage = item.message;
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            child: widget,
          );
        },
        itemRemovedBuilder: (
          ChatMessage item,
          int index,
          BuildContext context,
          Animation<double> animation,
        ) =>
            SizeTransition(
          axis: Axis.vertical,
          sizeFactor: animation,
          child: Text(item.message!),
        ),
      ),
    );
  }

  _scrollToBottom({bool isAnimate = false}) {
    final threshold = .5;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_scrollController.hasClients == false) return;
      final offset = _scrollController.position.maxScrollExtent + threshold;
      if (isAnimate) {
        _scrollController.animateTo(
          offset,
          duration: Duration(seconds: 200),
          curve: Curves.fastOutSlowIn,
        );
      } else {
        _scrollController.jumpTo(offset);
      }
    });
  }

  Widget _buildInput({required InChatRoomState state}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              color: Theme.of(context).cardColor,
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                style: Theme.of(context).textTheme.bodyText1,
                controller: textMessageController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
                onTap: () {
                  // Timer(
                  //   Duration(milliseconds: 300),
                  //   () => _scrollToBottom(),
                  // );
                },
              ),
            ),
          ),
          Material(
              child: new Container(
                margin: new EdgeInsets.only(left: 8.0),
                child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => _sendMessage(state: state),
                ),
              ),
              color: Theme.of(context).cardColor),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(
            top: new BorderSide(color: Color(0xFF3345A9), width: 0.5),
          ),
          color: Theme.of(context).cardColor),
    );
  }

  _sendMessage({required InChatRoomState state}) {
    widget._chatRoomBloc.add(
      SendMessageEvent(
          chat: this.widget.args.metadata,
          text: this.textMessageController.text,
          profiles: state.profiles),
    );

    this.textMessageController.text = '';
  }

  void _load([bool isError = false]) {
    widget._chatRoomBloc.add(UnChatRoomEvent(this.widget.args.profiles));
    widget._chatRoomBloc.add(LoadChatRoomEvent(isError,
        chat: this.widget.args.metadata, profiles: this.widget.args.profiles));
  }
}

typedef void OnChangeSendMessageRequest({
  required String status,
  required SendMessageMetadata sendMessageRequest,
});

class SendMessageRequest extends StatefulWidget {
  final SendMessageMetadata message;
  final bool isLoading;
  final OnChangeSendMessageRequest onChange;

  SendMessageRequest({
    required this.message,
    required this.isLoading,
    required this.onChange,
  }) {}

  @override
  _SendMessageRequestState createState() => _SendMessageRequestState();
}

class _SendMessageRequestState extends State<SendMessageRequest>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message == null) {
      return Container();
    }

    return SizeTransition(
      sizeFactor: _controller,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 16),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            this
                                .widget
                                .message
                                .createdBy!
                                .profile!
                                .picture!
                                .url!,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    this
                                        .widget
                                        .message
                                        .createdBy!
                                        .profile!
                                        .name!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    timeago
                                        .format(this.widget.message.createdAt!),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              this.widget.message.description!,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 40),
                    child: Row(
                      children: <Widget>[
                        TextButton(
                          child: Text(
                            'Accept',
                            style: TextStyle(
                              color: Color(0xff8DCA3E),
                              fontSize: 14,
                            ),
                          ),
                          onPressed: this.widget.isLoading
                              ? null
                              : () => widget.onChange(
                                    status: ChatMetadata.STATUS_ACCEPTED,
                                    sendMessageRequest: this.widget.message,
                                  ),
                        ),
                        TextButton(
                          child: Text(
                            'Ignore',
                            style: TextStyle(
                              color: Color(0xffAAAAAA),
                              fontSize: 14,
                            ),
                          ),
                          onPressed: this.widget.isLoading
                              ? null
                              : () => widget.onChange(
                                    status: ChatMetadata.STATUS_IGNORED,
                                    sendMessageRequest: this.widget.message,
                                  ),
                        ),
                        TextButton(
                          child: Text(
                            'Decline',
                            style: TextStyle(
                              color: Color(0xffCE4444),
                              fontSize: 14,
                            ),
                          ),
                          onPressed: this.widget.isLoading
                              ? null
                              : () => widget.onChange(
                                    status: ChatMetadata.STATUS_DECLINED,
                                    sendMessageRequest: this.widget.message,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            this.widget.isLoading
                ? LinearProgressIndicator(
                    backgroundColor: Colors.black,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
