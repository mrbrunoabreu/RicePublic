import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'src/app_bloc_observer.dart';
import 'src/repository/rice_repository.dart';
import 'src/app.dart';

void bootstrap() {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  final RiceRepository riceRepository = RiceRepositoryImpl();

  runZonedGuarded(
    () async {
      await BlocOverrides.runZoned(
        () async => runApp(
          RiceApp(riceRepository: riceRepository),
        ),
        blocObserver: AppBlocObserver(),
      );
    },
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  findSystemLocale().then((String locale) {
    initializeDateFormatting(locale);
    bootstrap();
  });
}
