import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../main/index.dart';
import '../screen_arguments.dart';
import '../signup/index.dart';
import '../base_bloc.dart';
import '../utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    Key? key,
    required String? userEmail,
    required String? token,
    required SignUpBloc bloc,
  })  : _bloc = bloc,
        _userEmail = userEmail,
        _token = token,
        super(key: key);

  final SignUpBloc _bloc;
  final String? _token;
  final String? _userEmail;

  @override
  SignUpScreenState createState() {
    return SignUpScreenState(_bloc, _userEmail, _token);
  }
}

class SignUpScreenState extends State<SignUpScreen> {
  final SignUpBloc _bloc;
  final String? _token;
  final String? _userEmail;
  final _confirmPasswordTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  bool _isObscure = true;
  bool _isConfirmObscure = true;

  SignUpScreenState(this._bloc, this._userEmail, this._token);

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
    return BlocBuilder<SignUpBloc, SignUpState>(
        bloc: widget._bloc,
        builder: (
          BuildContext context,
          SignUpState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              SignUpState currentState,
            ) {
              if (currentState is ErrorSignUpState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage, onPressed: () {
                    this._load();
                  });
                });
              }

              if (currentState is DoneSignUpState) {
                _navigateMain();
              }

              return Scaffold(
                  appBar: _appBar(context) as PreferredSizeWidget?,
                  body: _body(context));
            }));
  }

  _navigateMain() {
    widget._bloc.add(UnSignUpEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        MainPage.routeName,
        ModalRoute.withName('/'),
        arguments: MainPageArguments(
          MainPageArguments.tabExplore,
        ),
      );
    });
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
                'Setup Your Password to complete Sign up',
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
                    "Confirm and Login",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (_passwordTextController.text ==
                        _confirmPasswordTextController.text) {
                      this._bloc.add(
                            DoSignUpEvent(
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
    widget._bloc.add(LoadSignUpEvent(
        isError: isError, token: _token, errMsg: msg, userEmail: _userEmail));
  }
}
