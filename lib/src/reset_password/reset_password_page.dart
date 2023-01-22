import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rice_repository.dart';
import '../reset_password/index.dart';
import '../screen_arguments.dart';

class ResetPasswordPage extends StatelessWidget {
  static const String routeName = '/reset';

  @override
  Widget build(BuildContext context) {
    final ResetPasswordPageArguments args = ModalRoute.of(context)!
        .settings
        .arguments as ResetPasswordPageArguments;
    var _bloc =
        ResetPasswordBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      body: ResetPasswordScreen(token: args.token, bloc: _bloc),
    );
  }
}
