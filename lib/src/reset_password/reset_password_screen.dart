import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../reset_password/index.dart';
import '../base_bloc.dart';
import '../utils.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    Key? key,
    required String? token,
    required ResetPasswordBloc bloc,
  })  : _bloc = bloc,
        _token = token,
        super(key: key);

  final ResetPasswordBloc _bloc;
  final String? _token;

  @override
  ResetPasswordScreenState createState() {
    return ResetPasswordScreenState(_bloc, _token);
  }
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ResetPasswordBloc _bloc;
  final String? _token;
  final _confirmPasswordTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  bool _isObscure = true;
  bool _isConfirmObscure = true;

  ResetPasswordScreenState(this._bloc, this._token);

  @override
  void initState() {
    super.initState();
    this._load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
        bloc: widget._bloc,
        builder: (
          BuildContext context,
          ResetPasswordState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              ResetPasswordState currentState,
            ) {
              if (currentState is ErrorResetPasswordState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage, onPressed: () {
                    this._load();
                  });
                });
              }

              if (currentState is DoneResetPasswordState) {
                Navigator.pop(context);
              }

              return Scaffold(
                  appBar: _appBar(context) as PreferredSizeWidget?,
                  body: _body(context));
            }));
  }

  //region Widget --------------------------------------------------------------
  Widget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _body(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Reset Your Password',
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Password',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  TextField(
                    obscureText: _isObscure,
                    controller: _passwordTextController,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                            icon: Icon(_isObscure
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            })),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Confirm Password',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  TextField(
                    obscureText: _isConfirmObscure,
                    controller: _confirmPasswordTextController,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                            icon: Icon(_isConfirmObscure
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isConfirmObscure = !_isConfirmObscure;
                              });
                            })),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ButtonTheme(
                minWidth: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3345A9),
                    shape: StadiumBorder(),
                  ),
                  child: Text(
                    "Change Password",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (_passwordTextController.text ==
                        _confirmPasswordTextController.text) {
                      this._bloc.add(
                            DoResetPasswordEvent(
                              _passwordTextController.text,
                            ),
                          );
                    } else {
                      _load(true, "Password is different");
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  //endregion

  //region Private -------------------------------------------------------------
  void _load([bool isError = false, String? msg]) {
    widget._bloc.add(
        LoadResetPasswordEvent(isError: isError, token: _token, errMsg: msg));
  }
}
