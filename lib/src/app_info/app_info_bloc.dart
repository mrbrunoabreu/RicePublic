import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'index.dart';
import '../base_bloc.dart';
import '../repository/rice_repository.dart';
import 'package:version/version.dart';

class AppInfoBloc extends BaseBloc<AppInfoEvent, AppInfoState> {
  AppInfoBloc({required RiceRepository riceRepository})
      : super(riceRepository: riceRepository, initialState: UnAppInfoState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<Version> appVersion() async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    Version currentVersion = Version.parse(info.version);

    return currentVersion;
  }

  @override
  Future<void> mapEventToState(
      AppInfoEvent event, Emitter<AppInfoState> emitter) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'AppInfoBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}
