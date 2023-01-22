import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'repository/rice_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  final String SP_TOKEN = "loginToken";
  late RiceRepository riceRepository;
  BaseBloc(
      {required RiceRepository riceRepository, required State initialState})
      : super(initialState) {
    this.riceRepository = riceRepository;
    on<Event>(mapEventToState);
  }

  String? getCurrentUserId() => riceRepository.getCurrentUserId();

  Future<void> mapEventToState(Event event, Emitter<State> emitter);

  Future<bool> isLoggedIn() {
    return riceRepository.isLoggedIn().then((isLoggedIn) async {
      developer.log('Is logged in? ${isLoggedIn}');

      if (!isLoggedIn) {
        developer.log('Will attempt login');

        final logginAttempt = await attemptLogin();

        developer.log('Login attempt result ${logginAttempt}');
        return logginAttempt;
      }
      return isLoggedIn;
    }).catchError((error) {
      developer.log('Login error $error');
    });
  }

  Future<bool> attemptLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(SP_TOKEN)) {
      final token = prefs.getString(SP_TOKEN);

      // developer.log('Login token $token');

      final value = await riceRepository.loginWithToken(token);
      if (value != null) {
        prefs.setString(SP_TOKEN, value);
      }
      return value != null;
    }

    developer.log('No login token');

    return false;
  }

  Future<bool> storeLoginToken({required String loginToken}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (loginToken != null) {
      prefs.setString(SP_TOKEN, loginToken);
    }
    return prefs.containsKey(SP_TOKEN);
  }

  Future<bool> logout() async {
    var isLoggedOut = await riceRepository.logout();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(SP_TOKEN);
    return Future.value(isLoggedOut);
  }

  static Widget widgetBlocBuilderDecorator<S extends LoaderController>(
      BuildContext context, S currentState,
      {required BlocWidgetBuilder<S> builder}) {
    if (currentState is NeedShowLoader) {
      currentState.showLoading();
    } else {
      currentState?.dismissLoading();
    }
    return builder(context, currentState);
  }
}

abstract class LoaderController {
  // factory LoaderController._() => null;
  void showLoading() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EasyLoading.show();
    });
  }

  void dismissLoading() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EasyLoading.dismiss();
    });
  }
}

abstract class NeedShowLoader {
  // factory NeedShowLoader._() => null;
}
