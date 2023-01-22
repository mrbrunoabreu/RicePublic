import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../main/index.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    Key? key,
    required MainBloc mainBloc,
  })  : _mainBloc = mainBloc,
        super(key: key);

  final MainBloc _mainBloc;

  @override
  MainScreenState createState() {
    return MainScreenState(_mainBloc);
  }
}

class MainScreenState extends State<MainScreen> {
  final MainBloc _mainBloc;
  MainScreenState(this._mainBloc);

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
    return BlocBuilder<MainBloc, MainState>(
        bloc: widget._mainBloc,
        builder: (
          BuildContext context,
          MainState currentState,
        ) {
          if (currentState is UnMainState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (currentState is ErrorMainState) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(currentState.errorMessage ?? 'Error'),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text('reload'),
                    onPressed: () => this._load(),
                  ),
                ),
              ],
            ));
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Flutter files: done'),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('throw error'),
                    onPressed: () => this._load(true),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _load([bool isError = false]) {
    widget._mainBloc.add(UnMainEvent());
    widget._mainBloc.add(LoadMainEvent(isError));
  }
}
