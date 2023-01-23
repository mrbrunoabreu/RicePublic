import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../chat_room/chat_room_page.dart';
import 'find_chat_partner_bloc.dart';
import 'find_chat_partner_event.dart';
import 'find_chat_partner_state.dart';
import '../repository/model/chat.dart';
import '../repository/model/user.dart';
import '../screen_arguments.dart';

import 'dart:developer' as developer;

import '../view/avatar_row.dart';
import '../view/profile_picture.dart';

class FindChatPartnerScreen extends StatefulWidget {
  final FindChatPartnerBloc bloc;
  final FindChatPartnerPageArguments? args;

  FindChatPartnerScreen({
    required this.bloc,
    required this.args,
  }) {}

  @override
  _FindChatPartnerScreenState createState() => _FindChatPartnerScreenState();
}

class _FindChatPartnerScreenState extends State<FindChatPartnerScreen> {
  List<User?> selectedUsers = [];
  bool multipleSelection = false;

  final searchController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();

    searchController.addListener(_onChangeSearch);

    this.selectedUsers = List.from(this.widget.args?.selectedUsers ?? []);

    if (this.selectedUsers.isNotEmpty) {
      this.multipleSelection = true;
    }

    _load();
  }

  @override
  void dispose() {
    searchController.removeListener(_onChangeSearch);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarWrapper = (int index, Widget child) => Positioned(
          left: index * 24.0,
          child: child,
        );

    return BlocBuilder<FindChatPartnerBloc, FindChatPartnerState>(
      bloc: widget.bloc,
      builder: (context, currentState) {
        if (currentState is InFindChatPartnerState) {
          return SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  color: Theme.of(context).backgroundColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: <Widget>[
                      Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(15.0),
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Enter a friend's name",
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      // TODO: For group chat
                      // SizedBox(
                      //   height: 24,
                      // ),
                      // Container(
                      //   height: 32,
                      //   child: Stack(
                      //     children: buildAvatarRow(
                      //       photos: this
                      //           .selectedUsers
                      //           .reversed
                      //           .take(8)
                      //           .map(
                      //             (e) => e.profile.picture?.url,
                      //           )
                      //           .toList(),
                      //       limit: 5,
                      //       buildWrapper: avatarWrapper,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    itemCount: currentState.partners.length,
                    padding: EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      return _buildSearchResult(
                        partner: currentState.partners[index],
                        currentUser: currentState.currentUser,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 16,
                      );
                    },
                  ),
                ),
                !this.multipleSelection
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: ButtonTheme(
                            minWidth: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF3345A9),
                                shape: StadiumBorder(),
                              ),
                              child: Text(
                                this.widget.args?.chatId == null
                                    ? "Create Group"
                                    : 'Add Users',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                if (this.widget.args?.chatId == null) {
                                  this.widget.bloc.add(
                                        CreateChatGroupEvent(
                                          users: this.selectedUsers,
                                        ),
                                      );
                                } else {
                                  this.widget.bloc.add(AddUsersToChatGroupEvent(
                                        group: this.widget.args!.chatId,
                                        users: this
                                            .selectedUsers
                                            .map((e) => e!.id)
                                            .toList(),
                                      ));
                                }
                              },
                            )),
                      ),
              ],
            ),
          );
        }

        if (currentState is CreatedChatGroupState) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Navigator.pushReplacementNamed(
              context,
              ChatRoomPage.routeName,
              arguments: ChatRoomPageArguments(
                0,
                metadata: currentState.chat,
              ),
            );
          });
        }

        if (currentState is AddedUsersToChatGroupState) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Navigator.of(context).popUntil(
              ModalRoute.withName(ChatRoomPage.routeName),
            );
          });
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
    this.widget.bloc.add(UnFindChatPartnerEvent());
    this.widget.bloc.add(LoadFindChatPartnerEvent());
  }

  _buildSearchResult({
    required ChatPartner partner,
    required User currentUser,
  }) {
    final userFromArgs =
        (this.widget.args?.selectedUsers ?? []).firstWhereOrNull(
      (element) => element.id == partner.user!.id,
    );

    final wasInitiallySelected = userFromArgs != null;

    Function? onTap;

    if (this.multipleSelection) {
      onTap = wasInitiallySelected
          ? null
          : () => _toggleUserSelection(partner.user);
    } else {
      onTap = () => _chatWith(partner: partner, currentUser: currentUser);
    }

    return InkWell(
      onLongPress: () {
        this.setState(() {
          this.multipleSelection = true;
        });

        _toggleUserSelection(partner.user);
      },
      onTap: onTap as void Function()?,
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 8),
            child: ProfilePicture(
              pictureUrl: partner.user!.profile!.picture?.url,
            ),
          ),
          Expanded(
            child: Text(
              partner.user!.profile!.name ?? '',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: wasInitiallySelected ? Colors.grey.shade600 : null,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          !this.multipleSelection
              ? Container()
              : _buildRadioButton(
                  partner.user,
                  wasInitiallySelected: wasInitiallySelected,
                ),
        ],
      ),
    );
  }

  Widget _buildRadioButton(
    User? user, {
    bool? wasInitiallySelected,
  }) {
    final selectedUser = this
        .selectedUsers
        .firstWhere((element) => element!.id == user!.id, orElse: () => null);

    if (selectedUser != null) {
      return Container(
        width: 22,
        height: 22,
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 14,
        ),
        decoration: BoxDecoration(
          color: !wasInitiallySelected!
              ? Color(0xFF3345A9)
              : Colors.indigo.shade300,
          shape: BoxShape.circle,
        ),
      );
    }

    return Icon(
      Icons.radio_button_unchecked,
      color: Theme.of(context).hintColor,
    );
  }

  void _toggleUserSelection(User? user) {
    final selectedUser = this
        .selectedUsers
        .firstWhere((element) => element!.id == user!.id, orElse: () => null);

    if (selectedUser != null) {
      this.setState(() {
        this.selectedUsers = this
            .selectedUsers
            .where((element) => element!.id != user!.id)
            .toList();
      });
    } else {
      this.setState(() {
        this.selectedUsers.add(user);
      });
    }

    if (this.selectedUsers.isEmpty) {
      this.setState(() {
        this.multipleSelection = false;
      });
    }
  }

  _chatWith({required ChatPartner partner, required User currentUser}) async {
    ChatMetadata? metadata = partner.chat;

    if (metadata == null) {
      metadata = await widget.bloc.startChat(user: partner.user);
    }

    final restaurant = this.widget.args?.restaurant;

    if (restaurant != null) {
      await widget.bloc.shareRestaurant(
        chat: metadata.id,
        restaurant: restaurant,
      );
    }

    Navigator.pushNamed(
      context,
      ChatRoomPage.routeName,
      arguments: ChatRoomPageArguments(
        -1,
        metadata: metadata,
      ),
    );
  }
}
