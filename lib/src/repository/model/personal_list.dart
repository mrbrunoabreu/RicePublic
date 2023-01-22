import 'package:flutter/foundation.dart';
import '../model/restaurant.dart';
import '../model/user.dart';

class PersonalList {
  final String? name;
  final User? createdBy;
  final List<Restaurant?>? restaurants;

  PersonalList({required this.name, this.createdBy, this.restaurants});
}
