import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'find_chat_partner_bloc.dart';
import 'find_chat_partner_screen.dart';
import '../repository/rice_repository.dart';
import '../screen_arguments.dart';
import '../view/screen_bar.dart';

class FindChatPartnerPage extends StatefulWidget {
  static final String routeName = '/findChatPartner';

  @override
  _FindChatPartnerPageState createState() => _FindChatPartnerPageState();
}

class _FindChatPartnerPageState extends State<FindChatPartnerPage> {
  @override
  Widget build(BuildContext context) {
    final bloc =
        FindChatPartnerBloc(riceRepository: context.read<RiceRepository>());
    final FindChatPartnerPageArguments? args = ModalRoute.of(context)!
        .settings
        .arguments as FindChatPartnerPageArguments?;

    String title;

    if (args?.restaurant != null) {
      title = 'Share a restaurant';
    } else {
      title = 'Talk to someone';
    }

    return Scaffold(
      appBar: ScreenBar(
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.headline2,
        ),
        isBackIcon: false,
      ),
      body: FindChatPartnerScreen(
        bloc: bloc,
        args: args,
      ),
    );
  }
}
