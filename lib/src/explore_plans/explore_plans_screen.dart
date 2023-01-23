import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../explore/explore_bloc.dart';
import 'explore_plans_bloc.dart';
import 'explore_plans_event.dart';
import 'explore_plans_state.dart';
import '../repository/model/plan.dart';
import '../screen_arguments.dart';
import '../view/plans_section_list.dart';

class ExplorePlansScreen extends StatefulWidget {
  final ExplorePlansPageArguments arguments;

  final ExplorePlansBloc bloc;

  ExplorePlansScreen({
    required this.bloc,
    required this.arguments,
  });

  @override
  _ExplorePlansScreenState createState() => _ExplorePlansScreenState();
}

class _ExplorePlansScreenState extends State<ExplorePlansScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    this.widget.bloc.add(UnExplorePlansEvent());
    this.widget.bloc.add(LoadExplorePlansEvent());

    searchController.addListener(_onChangeSearch);

    super.initState();
  }

  @override
  void dispose() {
    searchController.removeListener(_onChangeSearch);

    super.dispose();
  }

  _onChangeSearch() {
    this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExplorePlansBloc, ExplorePlansState>(
      bloc: widget.bloc,
      builder: (
        BuildContext context,
        ExplorePlansState currentState,
      ) {
        final List<Widget> widgets = [
          Container(
            color: Theme.of(context).backgroundColor,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: EdgeInsets.only(bottom: 24),
            child: Material(
              elevation: 3,
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8.0),
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search a Location",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ];

        if (currentState is InExplorePlansState) {
          widgets.add(
            Expanded(
              child: PlansSectionList(
                plans: currentState.plans!.where((plan) {
                  if (searchController.text.isEmpty) {
                    return true;
                  }

                  return plan.restaurant!.name!
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase());
                }).toList(),
              ),
            ),
          );
        }

        return Column(
          children: widgets,
        );
      },
    );
  }
}
