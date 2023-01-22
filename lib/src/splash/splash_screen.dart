import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../environment_config.dart';
import '../utils.dart';
import 'package:version/version.dart';

import '../onboarding/index.dart';
import 'dart:developer' as developer;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _CONFIG_FORCED_UPDATE_VERSION = "force_update_current_version";
  static const _CONFIG_GOOGLE_PLAY_URL = "google_play_url";
  static const _CONFIG_APP_STORE_URL = "app_store_url";
  static const APP_STORE_URL = EnvironmentConfig.APP_STORE_URL;
  static const PLAY_STORE_URL = EnvironmentConfig.PLAY_STORE_URL;

  AnimationController? _controller;
  bool needUpdate = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigate();
      }
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  Future<bool> versionCheck(context) async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    Version currentVersion = Version.parse(info.version);

    //Get Latest version info from firebase config
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    try {
      final defaults = <String, dynamic>{
        _CONFIG_FORCED_UPDATE_VERSION: '0.1.7',
        _CONFIG_GOOGLE_PLAY_URL: PLAY_STORE_URL,
        _CONFIG_APP_STORE_URL: APP_STORE_URL
      };
      remoteConfig.setDefaults(defaults);

      await remoteConfig.fetchAndActivate();
      // Using default duration to force fetching from remote server.
      // await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      // await remoteConfig.activateFetched();
      Version newVersion =
          Version.parse(remoteConfig.getString(_CONFIG_FORCED_UPDATE_VERSION));
      if (newVersion >= currentVersion) {
        String playUrl = remoteConfig.getString(_CONFIG_GOOGLE_PLAY_URL);
        String appUrl = remoteConfig.getString(_CONFIG_APP_STORE_URL);
        _showVersionDialog(
            context: context, googlePlayUrl: playUrl, appStoreUrl: appUrl);
        return true;
      }
    } on PlatformException catch (exception, stacktrace) {
      developer.log("$exception",
          name: "SplashScreenState.versionCheck", stackTrace: stacktrace);
    } catch (exception, stacktrace) {
      developer.log(
          "Unable to fetch remote config. Cached or default values will be used",
          name: "SplashScreenState.versionCheck",
          stackTrace: stacktrace);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return Builder(
      builder: (context) {
        return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
                child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                            child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Lottie.asset(
                            isDarkMode
                                ? 'assets/splash/rice_logo_dark.json'
                                : 'assets/splash/rice_logo.json',
                            repeat: false,
                            controller: _controller,
                            onLoaded: (composition) {
                              // Configure the AnimationController with the duration of the
                              // Lottie file and start the animation.
                              _controller?.duration = Duration(seconds: 3);
                              _controller?.forward();
                            },
                          ),
                        ))
                      ],
                    ))));
      },
    );
  }

  _showVersionDialog(
      {required BuildContext context,
      String googlePlayUrl = PLAY_STORE_URL,
      String appStoreUrl = APP_STORE_URL}) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                    child: Text(btnLabel),
                    onPressed: () => launchURL(appStoreUrl),
                  ),
                  // TextButton(
                  //   child: Text(btnLabelCancel),
                  //   onPressed: () => Navigator.pop(context),
                  // ),
                ],
              )
            : new AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                    child: Text(btnLabel),
                    onPressed: () => launchURL(googlePlayUrl),
                  ),
                  // TextButton(
                  //   child: Text(btnLabelCancel),
                  //   onPressed: () => Navigator.pop(context),
                  // ),
                ],
              );
      },
    );
  }

  _navigate() async {
    try {
      needUpdate = await versionCheck(context);
    } catch (e, stacktrace) {
      developer.log("$e",
          name: "SplashScreenState._navigate", stackTrace: stacktrace);
    }
    if (!needUpdate) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return OnboardingPage();
        }),
      );
    }
  }
}
