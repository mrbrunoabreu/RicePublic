import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'restaurant.g.dart';

@JsonSerializable()
class Restaurant {
  @JsonKey(ignore: true, name: '_id')
  String? id;
  String? googlePlaceId;
  String? name;
  @JsonKey(includeIfNull: false)
  String? address;
  @JsonKey(includeIfNull: false)
  String? photo;
  @JsonKey(includeIfNull: false, name: 'overallRating')
  num? rating;
  Location? location;
  OpeningHoursDetail? openingHoursDetail;

  @JsonKey(ignore: true, includeIfNull: false)
  String? phone;

  @JsonKey(ignore: true, includeIfNull: false)
  AwardDetail? awardDetail;

  Restaurant(
      {this.id,
      this.googlePlaceId,
      this.name,
      this.address,
      this.photo,
      this.location,
      this.rating,
      this.phone,
      this.openingHoursDetail});
  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _restaurantFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantToJson(this);

  @override
  String toString() {
    return _$RestaurantToString(this);
  }
}

class RestaurantMetadata {
  final String name;
  final String photo;
  final String description;

  RestaurantMetadata({
    required this.name,
    required this.photo,
    required this.description,
  });
}

Restaurant _restaurantFromJson(Map<String, dynamic> json) {
  var locationJson = json['location'];
  Location? location =
      locationJson != null ? new Location.fromJson(locationJson) : null;

  final List<String?> photos = [];

  if (json['photo'] != null) {
    photos.add(json['photo']);
  }

  return Restaurant(
    id: json['_id'] as String?,
    googlePlaceId: json['googlePlaceId'] as String?,
    name: json['name'] as String?,
    address: json['address'] as String?,
    rating: json['overallRating'] as num?,
    photo: json['photo'] as String?,
    openingHoursDetail: OpeningHoursDetail.fromJson(json['opening_hours']),
    location: location,
  );
}

@JsonSerializable()
class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});
  factory Location.fromJson(Map<String, dynamic> json) =>
      _locationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

Location _locationFromJson(Map<String, dynamic> json) {
  var coordinatesJson = json['coordinates'];
  List<double>? coordinates =
      coordinatesJson != null ? new List.from(coordinatesJson) : null;
  return Location(
    type: json['type'] as String?,
    coordinates: coordinates,
  );
}

@JsonSerializable()
class OpeningHours {
  /// JSON open_now
  final bool? openNow;

  OpeningHours(this.openNow);

  factory OpeningHours.fromJson(Map json) =>
      OpeningHours(json['open_now']);
}

@JsonSerializable()
class OpeningHoursDetail extends OpeningHours {
  final List<OpeningHoursPeriod>? periods;
  final List<String>? weekdayText;

  OpeningHoursDetail(
    openNow,
    this.periods,
    this.weekdayText,
  ) : super(openNow);

  factory OpeningHoursDetail.fromJson(Map<String, dynamic> json) => OpeningHoursDetail(
          json['open_now'],
          json['periods']
              ?.map((p) => OpeningHoursPeriod.fromJson(p))
              ?.toList()
              ?.cast<OpeningHoursPeriod>(),
          json['weekday_text'] != null
              ? (json['weekday_text'] as List?)?.cast<String>()
              : []);

  Map<String, dynamic> toJson() {
    return {
      'periods': [],
    };
  }
}

@JsonSerializable()
class OpeningHoursPeriodDate {
  final int? day;
  final String? time;

  OpeningHoursPeriodDate(this.day, this.time);

  factory OpeningHoursPeriodDate.fromJson(Map json) =>
      OpeningHoursPeriodDate(json['day'], json['time']);
}

@JsonSerializable()
class OpeningHoursPeriod {
  final OpeningHoursPeriodDate? open;
  final OpeningHoursPeriodDate? close;

  OpeningHoursPeriod(this.open, this.close);

  factory OpeningHoursPeriod.fromJson(Map json) =>OpeningHoursPeriod(OpeningHoursPeriodDate.fromJson(json['open']),
          OpeningHoursPeriodDate.fromJson(json['close']));
}

@JsonSerializable()
class AwardDetail {
  final String? icon;
  final String? globalTitle;
  final String? regionTitle;

  AwardDetail(this.icon, this.globalTitle, this.regionTitle);

  factory AwardDetail.fromJson(Map json) => AwardDetail(json['icon'], json['global'], json['region']);
}