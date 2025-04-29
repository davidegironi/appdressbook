/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/api/entities/appdressbookconfig.dart';
import 'package:appdressbook/api/entities/appdressbookcontacts.dart';

class Config {
  late String authToken;
  late String apiUrl;
  AppDressBookContacts? contacts;
  AppDressBookConfig? config;
}
