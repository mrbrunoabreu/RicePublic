import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../environment_config.dart';
import '../base_bloc.dart';
import '../main/main_page.dart';
import '../onboarding/index.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../repository/firebase_dynamic_link_service.dart';
import '../signup/index.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../screen_arguments.dart';
import '../utils.dart';
import 'welcome_page_view.dart';
import 'dart:developer' as developer;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    Key? key,
    required OnboardingBloc onboardingBloc,
    bool isSignUp = false,
    String? signUpToken = null,
    String? userId = null,
  })  : _onboardingBloc = onboardingBloc,
        _isSignUp = isSignUp,
        _signUpToken = signUpToken,
        _userId = userId,
        super(key: key);

  final OnboardingBloc _onboardingBloc;
  final bool _isSignUp;
  final String? _signUpToken;
  final String? _userId;

  @override
  OnboardingScreenState createState() {
    return OnboardingScreenState(
        _onboardingBloc,
        (_isSignUp != null) ? _signUpToken : null,
        (_isSignUp != null) ? _userId : null);
  }
}

enum BottomSheetType { None, Register, Signup, Signin, RecoverPassword }

class OnboardingScreenState extends State<OnboardingScreen> {
  static final MIN_PW_LENGTH = 6;
  static final MAX_PW_LENGTH = 50;
  static final MAX_NAME_LENGTH = 20;

  String _message = 'Log in/out by pressing the buttons below.';
  PanelController _pc = new PanelController();
  BottomSheetType _bottomSheetType = BottomSheetType.None;

  final _emailTextController = TextEditingController(text: '');
  final _passwordTextController = TextEditingController(text: '');
  final _confirmPasswordTextController = TextEditingController(text: '');
  final _fullnameTextController = TextEditingController();
  bool _isObscure = true;
  bool _isConfirmObscure = true;

  final OnboardingBloc _onboardingBloc;
  String? _signUpToken;
  String? _userId;
  OnboardingScreenState(this._onboardingBloc, this._signUpToken, this._userId);

  @override
  void initState() {
    super.initState();
    this._load();
  }

  @override
  void dispose() {
    _emailTextController.clear();
    _passwordTextController.clear();
    _confirmPasswordTextController.clear();
    _fullnameTextController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      bloc: widget._onboardingBloc,
      builder: (
        BuildContext context,
        OnboardingState currentState,
      ) =>
          BaseBloc.widgetBlocBuilderDecorator(
        context,
        currentState,
        builder: (
          BuildContext context,
          OnboardingState currentState,
        ) {
          developer.log('Onboarding state $currentState');

          SlidingUpPanel slidingUpPanel =
              buildSlidingUpPanel(context, currentState);
          List<Widget> list = [slidingUpPanel];
          OnBoardingPageArguments? args = ModalRoute.of(context)!
              .settings
              .arguments as OnBoardingPageArguments?;

          if (currentState is UnOnboardingState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (currentState is SentPasswordRecoveryState) {
            _emailTextController.text = '';

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _pc.close();
              ackDialog(context, 'Check', 'Sent Password reset email',
                  onPressed: () {
                widget._onboardingBloc.add(LoadOnboardingEvent());
              });
            });
          }

          if (currentState is SentEnrollmentEmailOnboardingState) {
            _emailTextController.text = '';
            _fullnameTextController.text = '';

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _pc.close();
              ackDialog(context, 'Check', 'Sent Signup verification email',
                  onPressed: () {
                widget._onboardingBloc.add(LoadOnboardingEvent());
              });
            });
          }

          if (args == null || !args.isLoggedOut) {
            if (currentState is LoggedInOnboardingState) {
              navigateMain();
            }
          }

          if (currentState is SingingUpState) {
            navigateSignUp();
          }

          if (currentState is ErrorOnboardingState && !currentState.consumed) {
            currentState.consumed = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              ackAlert(context, currentState.errorMessage, onPressed: () {
                widget._onboardingBloc.add(LoadOnboardingEvent());
              });
            });
          }

          return WillPopScope(
            onWillPop: _onWillPop,
            child: Stack(children: list),
          );
        },
      ),
    );
  }

  navigateSignUp() {
    widget._onboardingBloc.add(UnOnboardingEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(
        context,
        SignUpPage.routeName,
        arguments: SignUpPageArguments(
          signUpToken: this._signUpToken,
          userEmail: this._userId,
        ),
      );
    });
  }

  navigateMain() {
    widget._onboardingBloc.add(UnOnboardingEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(
        context,
        MainPage.routeName,
        arguments: MainPageArguments(
          MainPageArguments.tabExplore,
        ),
      );
    });
  }

  Center body(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          WelcomePageView(),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 5.0),
                  child: ButtonTheme(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3568B8),
                          shape: StadiumBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    4.0, 4.0, 8.0, 4.0),
                                child: Image(
                                    image: AssetImage(
                                        'assets/icon/ic_fb_clipart.png'),
                                    height: 24,
                                    width: 24)),
                            Text("Login with Facebook",
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                        onPressed: () => this._loginByFb(context),
                      ))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 8.0),
                  child: ButtonTheme(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3345A9),
                          shape: StadiumBorder(),
                        ),
                        child: Text("Register with email",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () => _tappedRegister(),
                      ))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 8.0),
                  child: Container(
                      alignment: AlignmentDirectional.center,
                      // color: Colors.black,
                      child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 32.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Already a member? ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                GestureDetector(
                                    onTap: () => _tappedLoginByEmail(),
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ))
                              ]))))
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() {
    if (!_pc.isPanelClosed) {
      _pc.close();
      return Future.value(false);
    }
    return Future.value(true);
  }

  _load([bool isError = false]) async {
    // widget._onboardingBloc.add(UnOnboardingEvent());
    widget._onboardingBloc.add(LoadOnboardingEvent());

    if (_signUpToken != null && _userId != null) {
      widget._onboardingBloc.add(SigningUpOnboardingEvent());
    }
    await DynamicLinkService().handleDynamicLinks(context);
  }

  void _tappedRegister() {
    setState(() {
      _bottomSheetType = BottomSheetType.Register;
    });
    _pc.open();
  }

  void _tappedLoginByEmail() {
    setState(() {
      _bottomSheetType = BottomSheetType.Signin;
    });
    _pc.open();
  }

  SlidingUpPanel buildSlidingUpPanel(
      BuildContext context, OnboardingState currentState) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(16.0),
      topRight: Radius.circular(16.0),
    );
    double panelHeight;

    if (currentState is SingingUpState) {
      _bottomSheetType = BottomSheetType.Signup;
    }

    if (_bottomSheetType == BottomSheetType.Register) {
      panelHeight = 400.0;
    } else if (_bottomSheetType == BottomSheetType.Signup) {
      panelHeight = 350.0;
    } else if (_bottomSheetType == BottomSheetType.RecoverPassword) {
      panelHeight = 350;
    } else {
      panelHeight = 450.0;
    }

    return SlidingUpPanel(
        color: Theme.of(context).backgroundColor,
        controller: _pc,
        minHeight: 0,
        maxHeight: panelHeight,
        backdropEnabled: true,
        panel: Column(children: <Widget>[
          Center(
            child: showBottomSheet(),
          ),
        ]),
        backdropColor: Colors.black,
        // collapsed: Container(
        //   decoration:
        //       BoxDecoration(color: Colors.blueGrey, borderRadius: radius),
        //   height: 10.0,
        //   child: Center(
        //     child: Text(
        //       "This is the collapsed Widget",
        //       style: TextStyle(color: Colors.white),
        //     ),
        //   ),
        // ),
        body: body(context),
        // defaultPanelState: (currentState is SingingUpState)? PanelState.OPEN : PanelState.CLOSED,
        defaultPanelState: PanelState.CLOSED,
        borderRadius: radius,
        onPanelOpened: () {},
        onPanelClosed: () {
          if (currentState is SingingUpState) {
            if (_signUpToken != null && _userId != null) {
              _signUpToken = null;
              _userId = null;
            }
            widget._onboardingBloc.add(LoadOnboardingEvent());
          }
        });
  }

  Widget? showBottomSheet() {
    if (_bottomSheetType == BottomSheetType.Register)
      return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Text('Create a new account',
                    style: Theme.of(context).textTheme.headline1),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Full name',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    TextField(
                      textCapitalization: TextCapitalization.words,
                      controller: _fullnameTextController,
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
                    Text('E-mail address',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailTextController,
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     crossAxisAlignment: CrossAxisAlignment.stretch,
              //     children: <Widget>[
              //       Text('Password',
              //           style: TextStyle(
              //               fontSize: 16.0,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.grey)),
              //       TextField(
              //         keyboardType: TextInputType.visiblePassword,
              //         controller: _passwordTextController,
              //         obscureText: true,
              //       ),
              //     ],
              //   ),
              // ),
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
                        child: Text("Register",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () => _registerByEmail(
                              context,
                              _fullnameTextController.text,
                              _emailTextController.text,
                            ))),
              ),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                      onTap: () => _navigatePrivacyPolicy(context),
                      child: Text(
                        'Read Privacy Policy & Terms',
                        style: TextStyle(color: Color(0xFF3345A9)),
                      ))),
            ],
          ));
    else if (_bottomSheetType == BottomSheetType.Signup)
      return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Text('Complete Sign up',
                    style: Theme.of(context).textTheme.headline1),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Password',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    TextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passwordTextController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
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
                    Text('Confirm Password',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    TextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _confirmPasswordTextController,
                      obscureText: _isConfirmObscure,
                      decoration: InputDecoration(
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
                      child: Text("Sign up",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () => _signUpByToken(
                          context,
                          this._userId,
                          this._signUpToken!,
                          _passwordTextController.text,
                          _confirmPasswordTextController.text),
                    )),
              ),
            ],
          ));
    else if (_bottomSheetType == BottomSheetType.Signin) {
      return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Login to Rice',
                    style: Theme.of(context).textTheme.headline1),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('E-mail address',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailTextController,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Password',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    TextField(
                      controller: _passwordTextController,
                      textInputAction: TextInputAction.send,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
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
                      child: Text("Login to Rice",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        _loginByEmail(
                          context,
                          _emailTextController.text,
                          _passwordTextController.text,
                        );
                      },
                    )),
              ),
              Padding(
                  padding: const EdgeInsets.all(4),
                  child: GestureDetector(
                      onTap: () => _forgotPassword(context),
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(color: Color(0xFF3345A9)),
                      ))),
            ],
          ));
    } else if (_bottomSheetType == BottomSheetType.RecoverPassword) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Recover Your Password',
                  style: Theme.of(context).textTheme.headline1),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'E-mail address',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  TextField(
                    controller: _emailTextController,
                  ),
                  Text(
                    'Don\'t worry! We\'ll send you an email with instructions',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
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
                    child: Text("Request Password Recovery",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      this.widget._onboardingBloc.add(
                            RequestPasswordRecoveryEvent(
                              email: _emailTextController.text,
                            ),
                          );
                    },
                  )),
            ),
            Padding(
                padding: const EdgeInsets.all(4),
                child: GestureDetector(
                    onTap: () => _tappedLoginByEmail(),
                    child: Text(
                      'All good? Sign In!',
                      style: TextStyle(color: Color(0xFF3345A9)),
                    ))),
          ],
        ),
      );
    }
  }

  Future<Null> _registerByEmail(
      BuildContext context, String name, String email) async {
    developer.log('${name.trim()}, ${email.trim()}', name: '_registerByEmail');
    _validateRegisterInfo(name, email).then((value) {
      if (value != null && value == true) {
        _onboardingBloc.add(RegisterByEmailOnboardingEvent(
            name: name.trim(), email: email.trim()));
      }
    });
  }

  Future<Null> _signUpByToken(BuildContext context, String? userId,
      String token, String password, String confirmedPassword) async {
    _validateSignUpInfo(token, password, confirmedPassword).then((value) {
      if (value != null && value == true) {
        _onboardingBloc.add(SignUpByTokenOnboardingEvent(
            userId: userId, token: token, password: password.trim()));
      }
    });
  }

  Future<bool> _validateRegisterInfo(String name, String email) async {
    if (name.isEmpty || email.isEmpty) {
      _onboardingBloc.add(MissingInfomationOnboardingEvent(
          message: "Must be not empty for required fields"));
      return false;
    }
    // if (password.length < MIN_PW_LENGTH && password.length > MAX_PW_LENGTH) {
    //   _onboardingBloc.add(MissingInfomationOnboardingEvent(message: "Password length should be between $MIN_PW_LENGTH and $MAX_PW_LENGTH"));
    //   return false;
    // }

    if (name.length > MAX_NAME_LENGTH) {
      _onboardingBloc.add(MissingInfomationOnboardingEvent(
          message:
              "Please make a name length less than ${MAX_NAME_LENGTH + 1}"));
      return false;
    }

    return true;
  }

  Future<bool> _validateSignUpInfo(
      String token, String password, String confirmedPassword) async {
    if (token.isEmpty || password.isEmpty || confirmedPassword.isEmpty) {
      _onboardingBloc.add(MissingInfomationOnboardingEvent(
          message: "Must be not empty for required fields"));
      return false;
    }
    if (confirmedPassword != password) {
      _onboardingBloc.add(MissingInfomationOnboardingEvent(
          message: "Please enter the same Password and Confirm Password"));
      return false;
    }

    if (password.length < MIN_PW_LENGTH && password.length > MAX_PW_LENGTH) {
      _onboardingBloc.add(MissingInfomationOnboardingEvent(
          message:
              "Password length should be between $MIN_PW_LENGTH and $MAX_PW_LENGTH"));
      return false;
    }

    return true;
  }

  Future<Null> _loginByEmail(
      BuildContext context, String email, String password) async {
    developer.log('${email.trim()}, ${password.trim()}', name: '_loginByEmail');
    _onboardingBloc.add(
      LoginByEmailOnboardingEvent(
        email: email.trim(),
        password: password.trim(),
      ),
    );
  }

  Future<Null> _forgotPassword(BuildContext context) async {
    setState(() {
      _bottomSheetType = BottomSheetType.RecoverPassword;
    });
  }

  Future<Null> _navigatePrivacyPolicy(BuildContext context) async {
    launchURL(EnvironmentConfig.RICE_PRIVACY_URL);
  }

  Future<Null> _loginByFb(BuildContext context) async {
    final LoginResult result = await FacebookAuth.instance
        .login(permissions: ['public_profile', 'email']);

    switch (result.status) {
      case LoginStatus.success:
        final AccessToken? accessToken = result.accessToken;
        widget._onboardingBloc
            .add(LoginByFacebookOnboardingEvent(token: accessToken));
        break;
      case LoginStatus.cancelled:
        var errorMsg = 'Login cancelled by the user.';
        _showMessage(errorMsg);
        break;
      case LoginStatus.failed:
        var errorMsg = 'Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.message}';
        _showMessage(errorMsg);
        ackAlert(context, errorMsg);
        break;
      case LoginStatus.operationInProgress:
        // TODO: Handle this case.
        break;
    }
  }

  void _showMessage(String message) {
    developer.log('$message', name: 'onboarding_screen');
    setState(() {
      _message = message;
    });
  }
}
