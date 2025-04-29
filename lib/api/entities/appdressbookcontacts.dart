/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/utils/color_converter.dart';
import 'package:flutter/material.dart';

class AppDressBookContacts {
  AppDressBookContacts({
    required this.persons,
    required this.contacttypes,
    required this.companytypes,
    required this.roletypes,
    required this.locationtypes,
    required this.hash,
  });

  List<AppDressBookContactsPersons> persons;
  List<AppDressBookContactsContactTypes> contacttypes;
  List<AppDressBookContactsCompanyTypes> companytypes;
  List<AppDressBookContactsRoleTypes> roletypes;
  List<AppDressBookContactsLocationTypes> locationtypes;
  String hash;

  factory AppDressBookContacts.fromMap(Map<String, dynamic> json) =>
      AppDressBookContacts(
        persons:
            json["persons"] == null
                ? []
                : List<AppDressBookContactsPersons>.from(
                  json["persons"].map(
                    (x) => AppDressBookContactsPersons.fromMap(x),
                  ),
                ),
        contacttypes:
            json["contacttypes"] == null
                ? []
                : List<AppDressBookContactsContactTypes>.from(
                  json["contacttypes"].map(
                    (x) => AppDressBookContactsContactTypes.fromMap(x),
                  ),
                ),
        companytypes:
            json["companytypes"] == null
                ? []
                : List<AppDressBookContactsCompanyTypes>.from(
                  json["companytypes"].map(
                    (x) => AppDressBookContactsCompanyTypes.fromMap(x),
                  ),
                ),
        roletypes:
            json["roletypes"] == null
                ? []
                : List<AppDressBookContactsRoleTypes>.from(
                  json["roletypes"].map(
                    (x) => AppDressBookContactsRoleTypes.fromMap(x),
                  ),
                ),
        locationtypes:
            json["locationtypes"] == null
                ? []
                : List<AppDressBookContactsLocationTypes>.from(
                  json["locationtypes"].map(
                    (x) => AppDressBookContactsLocationTypes.fromMap(x),
                  ),
                ),
        hash: json["hash"],
      );

  Map<String, dynamic> toMap() => {
    "persons": List<dynamic>.from(persons.map((x) => x.toMap())),
    "contacttypes": List<dynamic>.from(contacttypes.map((x) => x.toMap())),
    "companytypes": List<dynamic>.from(companytypes.map((x) => x.toMap())),
    "roletypes": List<dynamic>.from(roletypes.map((x) => x.toMap())),
    "locationtypes": List<dynamic>.from(locationtypes.map((x) => x.toMap())),
    "hash": hash,
  };
}

class AppDressBookContactsPersons {
  AppDressBookContactsPersons({
    required this.id,
    required this.code,
    required this.firstname,
    required this.lastname,
    this.locationcode,
    this.companycode,
    this.rolecode,
    required this.contacts,
  });

  int id;
  String code;
  String firstname;
  String lastname;
  String? locationcode;
  String? companycode;
  String? rolecode;
  List<AppDressBookContactsPersonsContacts> contacts;

  String get fullName => "$firstname $lastname";
  String get initials =>
      "${firstname.isNotEmpty ? firstname[0] : ''}${lastname.isNotEmpty ? lastname[0] : ''}";

  factory AppDressBookContactsPersons.fromMap(Map<String, dynamic> json) =>
      AppDressBookContactsPersons(
        id: json["id"],
        code: json["code"],
        firstname: json["firstname"],
        lastname: json["lastname"],
        locationcode: json["locationcode"],
        companycode: json["companycode"],
        rolecode: json["rolecode"],
        contacts:
            json["contacts"] == null
                ? []
                : List<AppDressBookContactsPersonsContacts>.from(
                  json["contacts"].map(
                    (x) => AppDressBookContactsPersonsContacts.fromMap(x),
                  ),
                ),
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "code": code,
    "firstname": firstname,
    "lastname": lastname,
    "locationcode": locationcode,
    "companycode": companycode,
    "rolecode": rolecode,
    "contacts": List<dynamic>.from(contacts.map((x) => x.toMap())),
  };
}

class AppDressBookContactsCompanyTypes {
  AppDressBookContactsCompanyTypes({
    required this.code,
    required this.name,
    this.color,
  });

  String code;
  String name;
  Color? color;

  factory AppDressBookContactsCompanyTypes.fromMap(Map<String, dynamic> json) =>
      AppDressBookContactsCompanyTypes(
        code: json["code"],
        name: json["name"],
        color:
            json.containsKey("color") && json["color"] != null
                ? hexOrRGBToColor(json["color"])
                : Colors.transparent,
      );

  Map<String, dynamic> toMap() => {
    "code": code,
    "name": name,
    "color": colorToHex(color!),
  };
}

class AppDressBookContactsContactTypes {
  AppDressBookContactsContactTypes({
    required this.code,
    required this.name,
    this.color,
    required this.type,
  });

  String code;
  String name;
  Color? color;
  String type;

  factory AppDressBookContactsContactTypes.fromMap(Map<String, dynamic> json) =>
      AppDressBookContactsContactTypes(
        code: json["code"],
        name: json["name"],
        color:
            json.containsKey("color") && json["color"] != null
                ? hexOrRGBToColor(json["color"])
                : Colors.transparent,
        type: json["type"],
      );

  Map<String, dynamic> toMap() => {
    "code": code,
    "name": name,
    "color": colorToHex(color!),
    "type": type,
  };
}

class AppDressBookContactsLocationTypes {
  AppDressBookContactsLocationTypes({
    required this.code,
    required this.name,
    this.color,
  });

  String code;
  String name;
  Color? color;

  factory AppDressBookContactsLocationTypes.fromMap(
    Map<String, dynamic> json,
  ) => AppDressBookContactsLocationTypes(
    code: json["code"],
    name: json["name"],
    color:
        json.containsKey("color") && json["color"] != null
            ? hexOrRGBToColor(json["color"])
            : Colors.transparent,
  );

  Map<String, dynamic> toMap() => {
    "code": code,
    "name": name,
    "color": colorToHex(color!),
  };
}

class AppDressBookContactsRoleTypes {
  AppDressBookContactsRoleTypes({
    required this.code,
    required this.name,
    this.color,
  });

  String code;
  String name;
  Color? color;

  factory AppDressBookContactsRoleTypes.fromMap(Map<String, dynamic> json) =>
      AppDressBookContactsRoleTypes(
        code: json["code"],
        name: json["name"],
        color: hexOrRGBToColor(json["color"]),
      );

  Map<String, dynamic> toMap() => {
    "code": code,
    "name": name,
    "color": colorToHex(color!),
  };
}

class AppDressBookContactsPersonsContacts {
  AppDressBookContactsPersonsContacts({
    required this.code,
    required this.value,
  });

  String code;
  String value;

  factory AppDressBookContactsPersonsContacts.fromMap(
    Map<String, dynamic> json,
  ) => AppDressBookContactsPersonsContacts(
    code: json["code"],
    value: json["value"],
  );

  Map<String, dynamic> toMap() => {"code": code, "value": value};
}
