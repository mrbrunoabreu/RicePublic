import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rice/src/add_guests/index.dart';
import 'package:rice/src/base_bloc.dart';
import '../repository/model/user.dart';
import 'package:rice/src/utils.dart';
import 'package:rice/src/view/custom_checkbox.dart';

class AddGuestsScreen extends StatefulWidget {
  final List<User>? selectedUsers;

  const AddGuestsScreen({
    Key? key,
    required AddGuestsBloc addGuestsBloc,
    required this.selectedUsers,
  })  : _addGuestsBloc = addGuestsBloc,
        super(key: key);

  final AddGuestsBloc _addGuestsBloc;

  @override
  AddGuestsScreenState createState() {
    return AddGuestsScreenState(_addGuestsBloc, this.selectedUsers);
  }
}

class AddGuestsScreenState extends State<AddGuestsScreen> {
  final AddGuestsBloc addGuestsBloc;
  List<User>? selectedUsers = [];

  final searchController = TextEditingController(text: '');

  AddGuestsScreenState(this.addGuestsBloc, this.selectedUsers);

  @override
  void initState() {
    super.initState();
    this._load();
  }

  @override
  void dispose() {
    searchController.removeListener(_onChangeSearch);

    super.dispose();
  }

  _onChangeSearch() {
    if (searchController.text.isNotEmpty) {
      this.widget._addGuestsBloc.add(
            SearchFriendsEvent(name: searchController.text),
          );
    }
  }

  Future<bool> _onBackPress() {
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddGuestsBloc, AddGuestsState>(
      bloc: widget._addGuestsBloc,
      builder: (BuildContext context, AddGuestsState currentState) =>
          BaseBloc.widgetBlocBuilderDecorator(context, currentState,
              builder: (BuildContext context, AddGuestsState currentState) {
        List<Widget> list = [_buildBody(context, currentState)];
        if (currentState is ErrorAddGuestsState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ackAlert(context, currentState.errorMessage,
                onPressed: () =>
                    widget._addGuestsBloc.add(LoadAddGuestsEvent(false)));
          });
        }
        return WillPopScope(
            onWillPop: _onBackPress,
            child: Stack(
                alignment: AlignmentDirectional.topCenter, children: list));
      }),
    );
  }

  Widget _buildBody(BuildContext context, AddGuestsState currentState) {
    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          // These are the slivers that show up in the "outer" scroll view.
          return <Widget>[
            SliverOverlapAbsorber(
                // This widget takes the overlapping behavior of the SliverAppBar,
                // and redirects it to the SliverOverlapInjector below. If it is
                // missing, then it is possible for the nested "inner" scroll view
                // below to end up under the SliverAppBar even when the inner
                // scroll view thinks it has not been scrolled.
                // This is not necessary if the "headerSliverBuilder" only builds
                // widgets that do not overlap the next sliver.
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Material(
                      elevation: 3,
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15.0),
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Enter a friend\'s name",
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                  // child: _test(),
                )),
          ];
        },
        body: Column(
          children: <Widget>[
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _buildFriendsList((currentState is InAddGuestsState)
                  ? currentState.friends
                  : []),
            )),
            SafeArea(
              child: _buildSubmitButton(),
            )
          ],
        ));
  }

  _buildFriendsList(List<User> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final selectedUser = selectedUsers!.firstWhereOrNull(
          (element) => element.id == items[index].id,
        );

        return Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  // ProfilePicture(
                  //   pictureUrl: items[index].profile?.picture?.url ?? "",
                  // ),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Text(
                      items[index].profile?.name ?? "",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  )
                ],
              ),
              CustomCheckBox(
                value: selectedUser != null,
                onChanged: (value) {
                  if (value) {
                    setState(() {
                      selectedUsers!.add(items[index]);
                    });
                  } else {
                    setState(() {
                      selectedUsers!.removeWhere(
                        (e) => e.id == items[index].id,
                      );
                    });
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      child: ButtonTheme(
        minWidth: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3345A9),
          ),
          child: Text(
            "ADD GUESTS",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(selectedUsers);
          },
        ),
      ),
    );
  }

  void _load([bool isError = false]) {
    widget._addGuestsBloc.add(UnAddGuestsEvent());
    widget._addGuestsBloc.add(LoadAddGuestsEvent(isError));

    searchController.addListener(_onChangeSearch);
  }
}
