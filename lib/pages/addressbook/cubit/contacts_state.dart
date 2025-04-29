/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/api/entities/appdressbookcontacts.dart';
import 'package:equatable/equatable.dart';

abstract class AppDressBookContactsState extends Equatable {
  const AppDressBookContactsState();

  @override
  List<Object> get props => [];
}

class AppDressBookContactsInitial extends AppDressBookContactsState {}

class AppDressBookContactsLoading extends AppDressBookContactsState {}

class AppDressBookContactsSuccess extends AppDressBookContactsState {
  final AppDressBookContacts value;

  const AppDressBookContactsSuccess(this.value);
  @override
  bool operator ==(Object other) => other is AppDressBookContactsSuccess && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

class AppDressBookContactsFailure extends AppDressBookContactsState {
  final String error;

  const AppDressBookContactsFailure(this.error);

  @override
  bool operator ==(Object other) => other is AppDressBookContactsFailure && other.error == error;
  @override
  int get hashCode => error.hashCode;
}
