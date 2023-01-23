import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../app_info/index.dart';
import '../base_bloc.dart';
import '../edit_profile/index.dart';
import '../notification/index.dart';
import '../onboarding/index.dart';
import 'index.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../screen_arguments.dart';

import '../utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    Key? key,
    required SettingsBloc settingsBloc,
    required NotificationBloc notificationBloc,
  })  : _settingsBloc = settingsBloc,
        _notificationBloc = notificationBloc,
        super(key: key);

  final SettingsBloc _settingsBloc;
  final NotificationBloc _notificationBloc;

  @override
  SettingsScreenState createState() {
    return SettingsScreenState(_settingsBloc, _notificationBloc);
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  final SettingsBloc _settingsBloc;
  final NotificationBloc _notificationBloc;

  final _slidingPanelController = PanelController();
  final _currentPasswordTextController = TextEditingController();
  final _newPasswordTextController = TextEditingController();

  SettingsScreenState(this._settingsBloc, this._notificationBloc);

  @override
  void initState() {
    super.initState();
    this._load();
  }

  @override
  void dispose() {
    super.dispose();
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
    return BlocBuilder<SettingsBloc, SettingsState>(
        bloc: widget._settingsBloc,
        builder: (
          BuildContext context,
          SettingsState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              SettingsState currentState,
            ) {
              if (currentState is LoggedOutProfileState) {
                _notificationBloc.add(TearDownFirebaseMessaging());
                _navigateOnboarding();
              }

              if (currentState is PasswordChangedState) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  ackDialog(context, 'Success', 'Your password was changed!');
                });
              }

              List<Widget> list = [
                _buildChangePasswordPanel(currentState),
              ];
              if (currentState is ErrorSettingsState) {
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

  SlidingUpPanel _buildChangePasswordPanel(SettingsState currentState) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(16.0),
      topRight: Radius.circular(16.0),
    );

    return SlidingUpPanel(
      controller: _slidingPanelController,
      borderRadius: radius,
      minHeight: 0,
      maxHeight: 337,
      backdropEnabled: true,
      panel: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Change Your Password',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Current Password',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  TextField(
                    obscureText: true,
                    controller: _currentPasswordTextController,
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
                    'New Password',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  TextField(
                    obscureText: true,
                    controller: _newPasswordTextController,
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
                    // TODO add password confirmation

                    this._settingsBloc.add(
                          ChangePasswordEvent(
                            currentPassword:
                                _currentPasswordTextController.text,
                            newPassword: _newPasswordTextController.text,
                          ),
                        );

                    _slidingPanelController.close();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(context, currentState),
    );
  }

  _buildEditProfile() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 8), child: Icon(Icons.person)),
          Expanded(
            child: Text(
              'Edit profile',
              softWrap: false,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.subtitle2,
            ),
          )
        ],
      ),
    );
  }

  _buildAppInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => _navigateAppInfo(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.info),
            ),
            Expanded(
              child: Text(
                AppInfoScreen.TITLE,
                softWrap: false,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildLocationServiceSwitch(SettingsState currentState) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Padding(
            //     padding: EdgeInsets.only(right: 8),
            //     child: Icon(Icons.perm_identity, color: Color(0xFF3345A9))),
            Expanded(
                child: Text('Location service',
                    softWrap: false,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.subtitle1)),
            Switch(
              value: (currentState is InSettingsState)
                  ? currentState.isServiceEnabled
                  : false,
              onChanged: (value) {
                setState(() {
                  Geolocator.openLocationSettings();
                });
              },
              activeTrackColor: Color(0xFFF0F0F0),
              activeColor: Color(0xFF3345A9),
            )
          ],
        ));
  }

  _buildUpdatePassword() {
    return GestureDetector(
      onTap: () {
        _slidingPanelController.open();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 8), child: Icon(Icons.lock)),
            Expanded(
              child: Text(
                'Update password',
                softWrap: false,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildSignOut() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => _logout(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.exit_to_app),
            ),
            Expanded(
              child: Text(
                'Sign out',
                softWrap: false,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            )
          ],
        ),
      ),
    );
  }

  _builDeleteAccount() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.delete, color: Color(0xFFCE4444))),
            Expanded(
                child: Text('Delete account',
                    softWrap: false,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Color(0xFFCE4444))))
          ],
        ));
  }

  _buildBody(
    BuildContext context,
    SettingsState currentState,
  ) {
    return CustomScrollView(
        // controller: _scrollController,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: EdgeInsets.all(16),
                child: Column(children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        _navigateEditProfile();
                      },
                      child: _buildEditProfile()),
                  GestureDetector(onTap: () {}, child: _buildUpdatePassword()),
                  _buildAppInfo(),
                  GestureDetector(
                      onTap: () {},
                      child: _buildLocationServiceSwitch(currentState)),
                  GestureDetector(onTap: () {}, child: _buildSignOut()),
                ]),
              ),
            ]),
          )
        ]);
  }

  void _logout() {
    ackOkAndCancelDialog(context, 'Do you want to sign out?',
        onPressedOk: () => widget._settingsBloc.add(LogoutEvent()));
  }

  void _load([bool isError = false]) {
    widget._settingsBloc.add(UnSettingsEvent());
    widget._settingsBloc.add(LoadSettingsEvent(isError));
  }

  void _navigateAppInfo() {
    widget._settingsBloc.add(UnSettingsEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, AppInfoPage.routeName);
    });
  }

  void _navigateOnboarding() {
    widget._settingsBloc.add(UnSettingsEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamedAndRemoveUntil(
          context, OnboardingPage.routeName, ModalRoute.withName('/'),
          arguments: OnBoardingPageArguments(true));
    });
  }

  void _navigateEditProfile() {
    // widget._settingsBloc.add(LoadSettingsEvent(false));
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // });
    Navigator.pushNamed(context, EditProfilePage.routeName);
  }
}
