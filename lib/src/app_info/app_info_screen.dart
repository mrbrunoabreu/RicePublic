import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../environment_config.dart';
import 'index.dart';
import '../view/about.dart';
import 'package:version/version.dart';
import '../base_bloc.dart';
import '../utils.dart';

class AppInfoScreen extends StatefulWidget {
  static final String TITLE = 'Info, Terms of service, Privacy';
  static final String OSS_TITLE = 'Open Sources Licenses';
  const AppInfoScreen({
    Key? key,
    required AppInfoBloc bloc,
  })  : _bloc = bloc,
        super(key: key);

  final AppInfoBloc _bloc;

  @override
  AppInfoScreenState createState() {
    return AppInfoScreenState(_bloc);
  }
}

class AppInfoScreenState extends State<AppInfoScreen> {
  final AppInfoBloc _bloc;
  AppInfoScreenState(this._bloc);

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
    return BlocBuilder<AppInfoBloc, AppInfoState>(
        bloc: widget._bloc,
        builder: (
          BuildContext context,
          AppInfoState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              AppInfoState currentState,
            ) {
              if (currentState is ErrorAppInfoState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage, onPressed: () {
                    this._load();
                  });
                });
              }

              if (currentState is! InAppInfoState) {
                return Container();
              }

              return Scaffold(
                  appBar: _appBar(context) as PreferredSizeWidget?,
                  body: _body(context, currentState.appVersion));
            }));
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      automaticallyImplyLeading: false,
      title: Text(
        AppInfoScreen.TITLE,
        style: Theme.of(context).appBarTheme.textTheme!.headline6,
      ),
      leading: IconButton(
          icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
    );
  }

  Widget _body(BuildContext context, Version version) {
    return CustomScrollView(
        // controller: _scrollController,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: EdgeInsets.all(16),
                child: Column(children: <Widget>[
                  _buildItem(_defaultApplicationName(context) +
                      ' Version: ' +
                      version.toString()),
                  _buildItem('Privacy Policy and User of Service',
                      onTap: () => _navigatePrivacyPolicy()),
                  _buildItem(AppInfoScreen.OSS_TITLE,
                      onTap: () => _navigateOpenSourceLicenses(
                          context, version.toString())),
                ]),
              ),
            ]),
          )
        ]);
  }

  static void defaultCallback() {}

  _buildItem(String text, {VoidCallback onTap = defaultCallback}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                text,
                softWrap: false,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.headline2,
              ),
            )
          ],
        ),
      ),
    );
  }

  String _defaultApplicationName(BuildContext context) {
    // This doesn't handle the case of the application's title dynamically
    // changing. In theory, we should make Title expose the current application
    // title using an InheritedWidget, and so forth. However, in practice, if
    // someone really wants their application title to change dynamically, they
    // can provide an explicit applicationName to the widgets defined in this
    // file, instead of relying on the default.
    final Title? ancestorTitle = context.findAncestorWidgetOfExactType<Title>();
    return ancestorTitle?.title ??
        Platform.resolvedExecutable.split(Platform.pathSeparator).last;
  }

  Future<Null> _navigatePrivacyPolicy() async {
    launchURL(EnvironmentConfig.RICE_PRIVACY_URL);
  }

  Future<Null> _navigateOpenSourceLicenses(
      BuildContext context, String version) async {
    showAppLicensePage(
        context: context,
        title: AppInfoScreen.OSS_TITLE,
        applicationVersion: version);
  }

  void _load([bool isError = false, String? msg]) {
    widget._bloc.add(LoadAppInfoEvent(isError: isError, errMsg: msg));
  }
}
