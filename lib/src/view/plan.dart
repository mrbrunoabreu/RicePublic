import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:rice/src/plan_detail/index.dart';
import 'package:rice/src/repository/model/plan.dart';
import 'package:rice/src/repository/model/user.dart';
import 'package:rice/src/view/restaurant.dart';

Widget buildPlan(
  BuildContext context,
  Plan plan, {
  double width: 336.0,
  double height: 200.0,
  double paddingLeft = 8,
  double paddingRight = 8,
  VoidCallback? onTap,
}) =>
    SizedBox(
        // height: height,
        width: width,
        child: Padding(
          padding: EdgeInsets.only(
              top: 8, left: paddingLeft, right: paddingRight, bottom: 8),
          child: GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  PlanDetailPage.routeName,
                  arguments: plan,
                );

                if (onTap != null) {
                  onTap();
                }
              },
              child: Card(
                elevation: 2.0,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 12, right: 14, bottom: 18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                    _planHeader(plan, context),
                    SizedBox(height: 10),
                    _planBody(plan, 72, context)
                  ]),
                ),
              )),
        ));

Widget _planHeader(Plan plan, context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Expanded(
        child: Text(
          '${plan.restaurant?.name ?? ""} ${plan.user?.profile?.name == null ? "" : "with ${plan.user?.profile?.name}"}',
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ),
      SizedBox(
        width: 16,
      ),
      Text(
        plan.planDate != null
            ? intl.DateFormat.yMMMEd().format(plan.planDate!)
            : "",
        softWrap: false,
        overflow: TextOverflow.fade,
        style: Theme.of(context).textTheme.headline4
      ),
    ],
  );
}

Widget _planBody(Plan plan, double height, BuildContext context) {
  Text address = Text(
    plan.restaurant?.address ?? "Address",
    softWrap: true,
    overflow: TextOverflow.clip,
    style: Theme.of(context).textTheme.headline4,
    maxLines: 1,
  );

  final host = plan.users!.firstWhereOrNull(
    (element) => element.id == plan.userId,
  );

  Text hostName = Text(
    'Hosted by: ${host?.profile?.name ?? "Unknown"}',
    softWrap: true,
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
    style: Theme.of(context).textTheme.headline4,
  );

  return Container(
    height: height,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _planPicture(plan?.restaurant?.photo, height),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 4),
              address,
              SizedBox(height: 2),
              hostName,
              Expanded(
                child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Stack(
                          textDirection: TextDirection.rtl,
                          alignment: AlignmentDirectional.centerEnd,
                          children: _guestsAvatar(plan.users?.length != null
                              ? plan.users!.length >= 4
                                  ? plan.users!.sublist(0, 4)
                                  : plan.users
                              : [], context)
                            ..add((plan.users?.length != null
                                ? plan.users!.length > 4
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4.0 * 20 + 16),
                                        child: Text(
                                          '+ ${plan.users!.length - 4}',
                                          softWrap: true,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            color: Color(0xFFAAAAAA),
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                    : SizedBox()
                                : SizedBox())))
                    ]),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _planPicture(String? imgUrl, double height) {
  return buildImage(width: height, height: height, url: imgUrl);
}

List<Widget> _guestsAvatar(List<User>? guests, BuildContext context) {
  int counter = -1;
  guests ??= [];
  return guests.map<Widget>((guest) {
    counter++;
    return Padding(
        padding: EdgeInsets.only(left: counter * 20.0),
        child: Container(
            width: 28,
            height: 28,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,// border color
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
                radius: 14,
                backgroundImage:
                    NetworkImage(guest.profile?.picture?.url ?? ""))));
  }).toList();
}
