import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'index.dart';
import '../repository/rice_repository.dart';

class ChatListPage extends StatelessWidget {
  static const String routeName = '/chatList';

  @override
  Widget build(BuildContext context) {
    var _chatListBloc =
        ChatListBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      body: ChatListScreen(chatListBloc: _chatListBloc),
    );
  }
}
