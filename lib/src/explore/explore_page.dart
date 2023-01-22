import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rice/src/explore/index.dart';
import 'package:rice/src/repository/rice_repository.dart';

class ExplorePage extends StatelessWidget {
  static const String routeName = '/explore';

  @override
  Widget build(BuildContext context) {
    var _exploreBloc = ExploreBloc(riceRepository: context.read<RiceRepository>());
    return Scaffold(
      body: ExploreScreen(exploreBloc: _exploreBloc),
    );
  }
}
