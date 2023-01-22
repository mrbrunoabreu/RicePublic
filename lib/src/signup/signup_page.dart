import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rice_repository.dart';
import '../signup/index.dart';
import '../screen_arguments.dart';

class SignUpPage extends StatelessWidget {
  static const String routeName = '/signup';

  @override
  Widget build(BuildContext context) {
    final SignUpPageArguments args =
        ModalRoute.of(context)!.settings.arguments as SignUpPageArguments;
    var _bloc = SignUpBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      body: SignUpScreen(
          userEmail: args.userEmail, token: args.signUpToken, bloc: _bloc),
    );
  }
}
