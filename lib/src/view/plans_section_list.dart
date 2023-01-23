import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repository/model/plan.dart';
import "package:collection/collection.dart";
import 'plan.dart';

class PlansSectionList extends StatelessWidget {
  final List<Plan> plans;

  PlansSectionList({required this.plans});

  @override
  Widget build(BuildContext context) {
    final groups = _groupPlansByMonth();

    return ListView(
      children: groups.keys.map((month) {
        return _buildSection(
          context,
          title: month,
          plans: groups.entries
              .where((element) => element.key == month)
              .expand((element) => element.value)
              .toList(),
        );
      }).toList(),
    );
  }

  Map<String, List<Plan>> _groupPlansByMonth() {
    this.plans.sort((a, b) => a.planDate!.compareTo(b.planDate!));

    return groupBy(
      this.plans,
      (Plan plan) => DateFormat(DateFormat.YEAR_MONTH).format(plan.planDate!),
    );
  }

  Widget _buildSection(BuildContext context,
      {String? title, required List<Plan> plans}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFFAAAAAA),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 12),
                child: Text(
                  plans.isNotEmpty ? title! : '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 8),
            child: Container(
              margin: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: plans
                    .map(
                      (e) => buildPlan(context, e,
                          paddingLeft: 0, paddingRight: 0),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
