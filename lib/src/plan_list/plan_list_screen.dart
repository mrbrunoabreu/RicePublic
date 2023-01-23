import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import '../base_bloc.dart';
import '../create_plan/create_plan_page.dart';
import 'dart:ui' as ui;
import 'index.dart';
import '../view/home_bar.dart';
import '../view/plan.dart';
import 'package:table_calendar/table_calendar.dart';
import '../repository/model/plan.dart';
import '../utils.dart';

// The base class for the different types of items the list can contain.
abstract class ListItem {}

// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);
}

// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final Plan plan;

  MessageItem(this.plan);
}

class PlanListScreen extends StatefulWidget {
  const PlanListScreen({
    Key? key,
    required PlanListBloc planListBloc,
  })  : _planListBloc = planListBloc,
        super(key: key);

  final PlanListBloc _planListBloc;

  @override
  PlanListScreenState createState() {
    return PlanListScreenState(_planListBloc);
  }
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class PlanListScreenState extends State<PlanListScreen>
    with TickerProviderStateMixin {
  final PlanListBloc _planListBloc;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  TabController? _tabController;
  PlanListScreenState(this._planListBloc);
  LinkedHashMap<DateTime?, List<Event>> kEvents = LinkedHashMap.from({});

  final ValueNotifier _daySelect = ValueNotifier<DateTime?>(null);

  //region Super ---------------------------------------------------------------
  @override
  void initState() {
    _selectedDay = _focusedDay;
    _tabController = TabController(initialIndex: 1, length: 3, vsync: this);
    super.initState();
    this._load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanListBloc, PlanListState>(
        bloc: widget._planListBloc,
        builder: (
          BuildContext context,
          PlanListState currentState,
        ) =>
            BaseBloc.widgetBlocBuilderDecorator(context, currentState,
                builder: (
              BuildContext context,
              PlanListState currentState,
            ) {
              List<Widget> list = [
                Scaffold(
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(100),
                    child: PageBar(
                      title: 'Plan',
                      rightIcon: Icon(Ionicons.add_outline, size: 28),
                      rightIconTapCallback: () async {
                        await Navigator.pushNamed(
                          context,
                          CreatePlanPage.routeName,
                        );

                        _load();
                      },
                    ),
                  ),
                  body: _buildBody(context, currentState),
                ),
              ];
              if (currentState is ErrorPlanListState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ackAlert(context, currentState.errorMessage);
                });
              }
              return Stack(
                  alignment: AlignmentDirectional.topCenter, children: list);
            }));
  }
  //endregion

  //region Widget --------------------------------------------------------------
  Widget _buildBody(BuildContext context, PlanListState currentState) {
    if (currentState != null && currentState is InPlanListState) {
      kEvents = LinkedHashMap<DateTime?, List<Event>>.fromIterable(
          currentState.allPlans,
          key: (plan) => plan.planDate,
          value: (plan) => [Event("Event A0")]);
    }

    return DefaultTabController(
        length: 3, // This is the number of tabs.
        child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
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
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                    sliver: SliverToBoxAdapter(
                        child: Column(children: <Widget>[
                      _buildCalendar(kEvents),
                      _buildTabBar()
                    ]))),
              ];
            },
            body: ValueListenableBuilder(
              valueListenable: _daySelect,
              builder: (context, dynamic daySelect, child) {
                return TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    currentState != null && currentState is InPlanListState
                        ? _plansTimeline(currentState.allPlans, daySelect)
                        : _plansTimeline([], DateTime.now()),
                    currentState != null && currentState is InPlanListState
                        ? _plansTimeline(currentState.myPlans, daySelect)
                        : _plansTimeline([], DateTime.now()),
                    currentState != null && currentState is InPlanListState
                        ? _plansTimeline(currentState.friendsPlans, daySelect)
                        : _plansTimeline([], DateTime.now())
                  ],
                );
              },
            )));
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _daySelect.value = selectedDay;
  }

  Widget _buildCalendar(LinkedHashMap<DateTime?, List<Event>> events) {
    return Container(
        // elevation: 2.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: new BorderRadius.only(
              bottomLeft: const Radius.circular(14.0),
              bottomRight: const Radius.circular(14.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              blurRadius: 6.0, // has the effect of softening the shadow
              spreadRadius: 0, // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                4.0, // vertical, move down 10
              ),
            )
          ],
        ),
        child: SafeArea(
            child: Column(
          // height: 50,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(),
              child: Container(
                child: TableCalendar<Event>(
                  eventLoader: _getEventsForDay,
                  firstDay: kFirstDay,
                  lastDay: kLastDay,
                  focusedDay: _focusedDay,
                  onDaySelected: _onDaySelected,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                  ),
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const <CalendarFormat, String>{
                    CalendarFormat.month: ''
                  },
                  headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: Theme.of(context).textTheme.subtitle2!,
                      headerMargin: EdgeInsets.symmetric(
                          horizontal:
                              (MediaQuery.of(context).size.width - 216) / 2,
                          vertical: 16),
                      headerPadding: EdgeInsets.all(8),
                      leftChevronPadding: EdgeInsets.all(0),
                      rightChevronPadding: EdgeInsets.all(0),
                      leftChevronIcon: Icon(Icons.arrow_left, size: 24),
                      rightChevronIcon: Icon(
                        Icons.arrow_right,
                        size: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(80.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      )),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) =>
                        _dayBuilder(day.day.toString()),
                    todayBuilder: (context, date, events) =>
                        _todayDayBuilder(date.day.toString()),
                    selectedBuilder: (context, day, focusedDay) =>
                        _selectedDayBuilder(day),
                    markerBuilder: (context, date, events) {
                      return _eventsMarker(date, events);
                    },
                    holidayBuilder: (context, day, focusedDay) =>
                        _holidaysMarker(),
                    dowBuilder: (context, weekday) {
                      String weekdayStr = DateFormat.E().format(weekday);
                      return (weekday.weekday == DateTime.sunday ||
                              weekday.weekday == DateTime.saturday)
                          ? _dowWeekendBuilder(weekdayStr)
                          : _dowWeekdayBuilder(weekdayStr);
                    },
                  ),
                ),
              ),
            )
          ],
        )));
  }

  Widget _plansTimeline(List<Plan> plans, DateTime? selectDay) {
    List<ListItem> items = [];

    if (plans.isNotEmpty)
      items = _plansToItems(plans, selectDay ?? DateTime.now());

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is HeadingItem)
          return _headingItem(index, plans.length, item.heading);
        else if (item is MessageItem) return _messageItem(item.plan);
        return SizedBox();
      },
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      tabs: [
        Tab(
          text: 'ALL',
        ),
        Tab(
          text: 'MY PLANS',
        ),
        Tab(
          text: 'FRIENDS',
        ),
      ],
      unselectedLabelColor: Theme.of(context).disabledColor,
      labelColor: Theme.of(context).primaryColor,
      indicatorColor: Theme.of(context).primaryColor,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8),
      controller: this._tabController,
    );
  }

  Widget _dayBuilder(String day) {
    return Center(
        child: Text(day,
            style: TextStyle(
                fontSize: 14, color: Theme.of(context).disabledColor)));
  }

  Widget _todayDayBuilder(String day) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
          color: Color(0xFF3345A9),
        ),
        child: Center(
            child: Text(day,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _selectedDayBuilder(DateTime date) {
    return DateTime.now().day != date.day
        ? Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFd2e3fc).withOpacity(.5),
              ),
              child: Center(
                  child: Text(date.day.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: Color(0xFF185abc)))),
            ),
          )
        : _todayDayBuilder(date.day.toString());
  }

  Widget _eventsMarker(DateTime date, List events) {
    return Positioned(
      right: 12,
      top: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _daySelect.value == date && kToday != date
                ? Colors.white
                : kToday == date
                    ? Colors.white
                    : date.isBefore(DateTime.now())
                        ? Color(0xFFD8D8D8)
                        : Color(0xFF8DCA3E)),
        width: 6.0,
        height: 6.0,
      ),
    );
  }

  Widget _holidaysMarker() {
    return Positioned(
      right: -2,
      top: -2,
      child: Icon(
        Icons.add_box,
        size: 20.0,
        color: Colors.blueGrey[800],
      ),
    );
  }

  Widget _dowWeekdayBuilder(String weekday) {
    return Center(
        child: Text(weekday.toUpperCase(),
            style: Theme.of(context).textTheme.subtitle2));
  }

  Widget _dowWeekendBuilder(String weekend) {
    return Center(
        child: Text(weekend.toUpperCase(),
            style: Theme.of(context).textTheme.subtitle2));
  }

  Widget _messageItem(Plan plan) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            CustomPaint(
              size: Size(20, 148),
              painter: MonthConnectorPainter(1),
            ),
            buildPlan(
              context,
              plan,
              width: MediaQuery.of(context).size.width - 48,
              onTap: () {
                _load();
              },
            ),
          ],
        ));
  }

  Widget _headingItem(int index, int length, String text) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            CustomPaint(
              size: Size(20, 40),
              painter: MonthConnectorPainter(
                  index == 0 ? 0 : (index == (length - 1) ? 2 : 3)),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "${text.substring(0, 1).toUpperCase()}${text.substring(1).toLowerCase()}",
                  style: Theme.of(context).textTheme.subtitle2,
                ))
          ],
        ));
  }
  //endregion

  //region Private -------------------------------------------------------------
  void _load([bool isError = false]) {
    widget._planListBloc.add(UnPlanListEvent());
    widget._planListBloc.add(LoadPlanListEvent(isError));
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return "january";
        break;
      case 2:
        return "february";
        break;
      case 3:
        return "march";
        break;
      case 4:
        return "april";
        break;
      case 5:
        return "may";
        break;
      case 6:
        return "june";
        break;
      case 7:
        return "july";
        break;
      case 8:
        return "august";
        break;
      case 9:
        return "september";
        break;
      case 10:
        return "october";
        break;
      case 11:
        return "november";
        break;
      case 12:
        return "december";
        break;
      default:
        return "";
    }
  }

  List<ListItem> _plansToItems(List<Plan> plans, DateTime date) {
    List<ListItem> items = [];
    plans = plans
        .where(
            (plan) => plan.planDate!.isAfter(date) || kToday == plan.planDate)
        .toList();
    plans.sort((a, b) => a.planDate!.compareTo(b.planDate!));
    if (!plans.isEmpty) {
      String month = _getMonth(plans[0].planDate!.month);
      items.add(HeadingItem(month.toString()));
      plans.forEach((plan) {
        if (_getMonth(plan.planDate!.month) != month) {
          month = _getMonth(plan.planDate!.month);
          items.add(HeadingItem(month.toString()));
        }
        items.add(MessageItem(plan));
      });
    }
    return items;
  }

  //endregion
}

class MonthConnectorPainter extends CustomPainter {
  final int type; // 0: start, 1: middle, 2: end, 3: middle with point
  MonthConnectorPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final pointMode = ui.PointMode.points;
    final paint = Paint()..color = Color(0xFFAAAAAA);
    if (type == 1 || type == 2 || type == 3) {
      final p0 = Offset(size.width / 2, 0);
      final p1 = Offset(size.width / 2, size.height / 2);
      paint.strokeWidth = 1;
      canvas.drawLine(p0, p1, paint);
    }

    if (type != 1) {
      final points = [
        Offset(size.width / 2, size.height / 2),
      ];
      paint.strokeWidth = 8;
      paint.strokeCap = StrokeCap.round;
      canvas.drawPoints(pointMode, points, paint);
    }

    if (type == 0 || type == 1 || type == 3) {
      final p2 = Offset(size.width / 2, size.height / 2);
      final p3 = Offset(size.width / 2, size.height);
      paint.strokeWidth = 1;
      canvas.drawLine(p2, p3, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}
