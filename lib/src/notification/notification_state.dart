import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationReady extends NotificationState {
  const NotificationReady();
}

class NotificationReceived extends NotificationReady {
  final Map<String, dynamic> message;

  const NotificationReceived({
    required this.message,
  }) : super();

  @override
  List<Object> get props => super.props..addAll([message]);
}
