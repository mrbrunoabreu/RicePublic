import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

TValue? switchTo<TOptionType, TValue>(
    TOptionType selectedOption, Map<TOptionType, TValue> branches) {
  if (!branches.containsKey(selectedOption)) {
    return null;
  }

  return branches[selectedOption];
}

Iterable<E> mapIndexed<E, T>(
    Iterable<T> items, E Function(int index, T item) f) sync* {
  var index = 0;

  for (final item in items) {
    yield f(index, item);
    index = index + 1;
  }
}

Future<void> ackOkAndCancelDialog(BuildContext context, String message,
    {VoidCallback? onPressedOk, VoidCallback? onPressedCancel}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () {
              if (onPressedOk != null) {
                onPressedOk();
              }
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              if (onPressedCancel != null) {
                onPressedCancel();
              }
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

String breakLine(String text, [int size = 30]) {
  const kEmptyStr = '';
  String result = kEmptyStr;
  final List<String> origin = text.split(' ');
  if (origin
          .map<int>((el) => el.length)
          .reduce((value, element) => value + element) <=
      size) {
    return text;
  }

  final words = origin
      .map((el) {
        result += el;
        if (result.length < size) {
          return el;
        }
        return kEmptyStr;
      })
      .where((e) => e != kEmptyStr)
      .toList();

  final sb = StringBuffer()
    ..writeln(words.join(' '))
    ..writeln(origin.getRange(words.length, origin.length).join(' '));

  return sb.toString();
}

const VoidCallback? emptyVoidCallback = null;

Future<void> ackAlert(BuildContext context, String? message,
    {VoidCallback? onPressed = emptyVoidCallback}) {
  return ackDialog(
    context,
    'Error',
    message,
    onPressed: onPressed,
    barrierDismissible: false,
  );
}

Future<void> ackDialog(
  BuildContext context,
  String title,
  String? message, {
  VoidCallback? onPressed = emptyVoidCallback,
  bool barrierDismissible = true,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message!),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () {
              if (onPressed != null) {
                onPressed();
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showAlertDialog3(BuildContext context,
    {required String title,
    required String message,
    required String text1,
    required String text2,
    required String text3,
    void onPressed(String text)?}) {
  if (onPressed == null) {
    onPressed = (String text) {};
  }
  Widget lembrarButton = TextButton(
    child: Text(text1),
    onPressed: () => onPressed!(text1),
  );
  Widget cancelaButton = TextButton(
    child: Text(text2),
    onPressed: () => onPressed!(text2),
  );
  Widget dispararButton = TextButton(
    child: Text(text3),
    onPressed: () => onPressed!(text3),
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      lembrarButton,
      cancelaButton,
      dispararButton,
    ],
  );

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<LatLng> calculateCentral(List<LatLng> locations) async {
  assert(locations.isNotEmpty);

  if (locations.length == 1) {
    return locations[0];
  }

  double x = 0, y = 0, z = 0;
  locations.forEach((latLng) {
    var latitude = latLng.latitude * pi / 180;
    var longitude = latLng.longitude * pi / 180;
    x += (cos(latitude) * cos(longitude));
    y += (cos(latitude) * sin(longitude));
    z += sin(latitude);
  });

  x = x / locations.length;
  y = y / locations.length;
  z = z / locations.length;

  var lng = atan2(y, x);
  var s = sqrt(x * x + y * y);
  var lat = atan2(z, s);

  return LatLng(lat * 180 / pi, lng * 180 / pi);
}

void launchMapsByRouteUrl(
    String originPlaceId, String destinationPlaceId) async {
  String mapOptions = [
    'origin=$originPlaceId',
    'origin_place_id=$originPlaceId',
    'destination=$destinationPlaceId',
    'destination_place_id=$destinationPlaceId',
    'dir_action=navigate'
  ].join('&');

  final url = 'https://www.google.com/maps/dir/api=1&$mapOptions';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void launchMapsByLocationUrl(double lat, double lng) async {
  final String googleMapsUrl = "comgooglemaps://?center=$lat,$lng";
  final String appleMapsUrl = "https://maps.apple.com/?q=$lat,$lng";

  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  }
  if (await canLaunch(appleMapsUrl)) {
    await launch(appleMapsUrl, forceSafariVC: false);
  } else {
    throw "Couldn't launch URL";
  }
}

void launchTel(String? telephoneNumber) async {
  String telephoneUrl = "tel:$telephoneNumber";

  if (await canLaunch(telephoneUrl)) {
    await launch(telephoneUrl);
  } else {
    throw "Can't phone that number.";
  }
}

void launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class LatLngPosition extends Position {
  LatLngPosition(
      {required double longitude,
      required double latitude,
      DateTime? timestamp = null,
      double accuracy = 0,
      double altitude = 0,
      double heading = 0,
      double speed = 0,
      double speedAccuracy = 0})
      : super(
            longitude: longitude,
            latitude: latitude,
            timestamp: timestamp,
            accuracy: accuracy,
            altitude: altitude,
            heading: heading,
            speed: speed,
            speedAccuracy: speedAccuracy);
}

Future<Position> loadUserLastLocation() async {
  // Check if has permission of location
  LocationPermission permission = await Geolocator.checkPermission();
  Position position = await _fetchLocation(permission);
  if (position != null) {
    return Future.value(position);
  }
  // Try to get permission of location
  LocationPermission requestedPermission = await Geolocator.requestPermission();
  return _fetchLocation(requestedPermission,
      defaultLocation: LatLngPosition(longitude: 139.7668, latitude: 35.6752));
}

Future<Position> _fetchLocation(LocationPermission permission,
    {Position? defaultLocation = null}) async {
  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    return Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 3))
        .then((position) => position)
        .catchError((e) {
      return Geolocator.getLastKnownPosition();
    }, test: (e) => e is TimeoutException).then(
            (value) => value != null ? value : defaultLocation!);
  }
  return Future.value(defaultLocation);
}

dayOfWeekAndDayOfMonthSuffixed(DateTime date) {
  var suffix = "th";

  var digit = date.day % 10;

  if ((digit > 0 && digit < 4) && (date.day < 11 || date.day > 13)) {
    suffix = ["st", "nd", "rd"][digit - 1];
  }

  return DateFormat("EEE d'$suffix'").format(date);
}

typedef ValueCallback<T, R> = R Function(T value);

double toPrecision(double num, int fractionDigits) {
  double mod = pow(10, fractionDigits.toDouble()) as double;
  return ((num * mod).round().toDouble() / mod);
}
