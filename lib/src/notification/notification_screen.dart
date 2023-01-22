import 'dart:async';
import 'package:flutter/material.dart';
import 'index.dart';
import '../utils.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    Key? key,
    required NotificationBloc notificationBloc,
  })  : _notificationBloc = notificationBloc,
        super(key: key);

  final NotificationBloc _notificationBloc;

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NOTIFICATIONS',
          style: Theme.of(context).textTheme.headline2,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 1,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: getNotificationsFromDatabase(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return shimmer;
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Divider(
                          height: 0,
                          thickness: 0.5,
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundImage: NetworkImage(
                                  snapshot.data[index]['data']['image_url']
                                          .toString() ??
                                      'http://',
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                        snapshot.data[index]['notification']
                                                ['title']
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                        breakLine(snapshot.data[index]
                                                ['notification']['body']
                                            .toString()),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 0,
                          thickness: 0.5,
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget get shimmer => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListView.builder(
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Container(
                                width: 75.0,
                                height: 75.0,
                                color: Colors.white)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                height: 8.0,
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Container(
                                width: double.infinity,
                                height: 8.0,
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Container(
                                width: 40.0,
                                height: 8.0,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  itemCount: 4,
                ),
              ),
            )
          ],
        ),
      );

  Future<List<Map<String, dynamic>>> getNotificationsFromDatabase() async {
    // final QuerySnapshot collectionSnapshot =
    //     await Firestore.instance.collection('Notifications').getDocuments();
    // return collectionSnapshot.documents.map((DocumentSnapshot docSnapshot) => docSnapshot.data).toList();
    return [];
  }
}
