import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rice_repository.dart';
import 'index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../base_bloc.dart';

class SettingsBloc extends BaseBloc<SettingsEvent, SettingsState> {
  SettingsBloc({required RiceRepository riceRepository})
      : super(riceRepository: riceRepository, initialState: UnSettingsState(0));

  @override
  Future<void> close() async {
    // dispose objects
    super.close();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return this.riceRepository.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
  }

  @override
  Future<void> mapEventToState(
    SettingsEvent event,
    Emitter<SettingsState> emitter,
  ) async {
    try {
      emitter(await event.applyAsync(currentState: state, bloc: this));
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'SettingsBloc', error: _, stackTrace: stackTrace);
      emitter(state);
    }
  }
}
