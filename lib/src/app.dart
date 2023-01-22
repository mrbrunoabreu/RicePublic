import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../environment_config.dart';
import './lifecycle_manager.dart';
import './repository/rice_repository.dart';
import './routes.dart';
import './theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'splash/index.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class RiceApp extends StatelessWidget {
  const RiceApp({Key? key, required RiceRepository riceRepository})
      : _riceRepository = riceRepository,
        super(key: key);

  final RiceRepository _riceRepository;

  @override
  Widget build(BuildContext context) {
    _initLoader();
    _initPushNotificaiton();
    _initializeFlutterFire(context);

    return LifeCycleManager(
        child: RepositoryProvider.value(
      value: _riceRepository,
      child: MaterialApp(
        debugShowCheckedModeBanner: kDebugMode,
        title: 'Rice',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        builder: (context, child) {
          return FlutterEasyLoading(
            child: child,
          );
        },
        routes: routes,
        home: SplashScreen(),
      ),
    ));
  }

  Future<EasyLoading> _initLoader() async {
    return EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.doubleBounce
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 45.0
      ..indicatorColor = Colors.white
      ..backgroundColor = Colors.transparent
      ..progressColor = Colors.grey
      ..textColor = Colors.white
      ..maskColor = Colors.grey
      ..maskType = EasyLoadingMaskType.black
      ..userInteractions = false;
  }

  _initPushNotificaiton() async {
    //Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(
        kDebugMode ? OSLogLevel.verbose : OSLogLevel.error, OSLogLevel.none);

    OneSignal.shared.setAppId(
      EnvironmentConfig.one_signal_app_id,
    );

    // Implement in-app version of push authorization prompt: https://documentation.onesignal.com/docs/ios-push-opt-in-prompt
  }

  _initializeFlutterFire(BuildContext context) async {
    await Firebase.initializeApp();
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
  }
}
