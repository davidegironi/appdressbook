/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/auth/repositories/auth_repository.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/main/body_scaffold.dart';
import 'package:appdressbook/main/main_widget.dart';
import 'package:appdressbook/pages/addressbook/utils/contacts_utils.dart';
import 'package:appdressbook/main/app_localization.dart';
import 'package:appdressbook/main/app_themedata.dart';
import 'package:appdressbook/api/entities/appdressbookcontacts.dart';
import 'package:appdressbook/utils/snackbar_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonScreenArguments {
  final AppDressBookContactsPersons person;
  final List<AppDressBookContactsCompanyTypes> companyTypes;
  final List<AppDressBookContactsContactTypes> contactTypes;
  final List<AppDressBookContactsLocationTypes> locationTypes;
  final List<AppDressBookContactsRoleTypes> roleTypes;

  PersonScreenArguments(this.person, this.companyTypes, this.contactTypes, this.locationTypes, this.roleTypes);
}

class PersonScreen extends StatefulWidget {
  static const String routeName = '/person';
  static const int maxNameLenght = 20;

  final PersonScreenArguments args;

  const PersonScreen({super.key, required this.args});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class ContactList {
  ContactList({required this.name, required this.value, required this.icon, this.onAction});

  String name;
  String value;
  IconData icon;
  final Function()? onAction;
}

class _PersonScreenState extends State<PersonScreen> {
  final AuthRepository authRepository = GetIt.instance.get<AuthRepository>();
  final ConfigRepository configRepository = GetIt.instance.get<ConfigRepository>();

  @override
  Widget build(BuildContext context) {
    AppDressBookContactsPersons person = widget.args.person;
    List<AppDressBookContactsCompanyTypes> companyTypes = widget.args.companyTypes;
    List<AppDressBookContactsContactTypes> contactTypes = widget.args.contactTypes;
    List<AppDressBookContactsLocationTypes> locationTypes = widget.args.locationTypes;
    List<AppDressBookContactsRoleTypes> roleTypes = widget.args.roleTypes;

    final personColor = getAvatarColor('${person.firstname}${person.lastname}');
    final personTextColor = getAvatarTextColor();
    final name = '${person.firstname} ${person.lastname}';
    final displayName =
        name.length > PersonScreen.maxNameLenght ? '${name.substring(0, PersonScreen.maxNameLenght)}...' : name;
    final companyName =
        companyTypes
            .firstWhere(
              (item) => item.code == person.companycode,
              orElse: () => AppDressBookContactsCompanyTypes(code: person.companycode ?? "", name: ""),
            )
            .name;
    final roleName =
        roleTypes
            .firstWhere(
              (item) => item.code == person.rolecode,
              orElse: () => AppDressBookContactsRoleTypes(code: person.rolecode ?? "", name: ""),
            )
            .name;
    final locationCode = person.locationcode;
    final locationName =
        locationTypes
            .firstWhere(
              (item) => item.code == person.locationcode,
              orElse: () => AppDressBookContactsLocationTypes(code: person.locationcode ?? "", name: ""),
            )
            .name;
    List<ContactList> contactList = [];
    for (var contact in person.contacts) {
      final contactType = contactTypes.firstWhere((ct) => ct.code == contact.code);

      // get contact url
      String urlmail = contactType.type == "email" ? "mailto:${contact.value}" : "";
      String urlmessage = contactType.type == "phone" ? "sms:${contact.value}" : "";
      String urlcall = contactType.type == "phone" ? "tel:${contact.value}" : "";

      // check if call is enabled
      Function()? cannotcall =
          (!(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)
              ? () {
                SnackBarUtils.errorSnackbar(context, AppI18N.instance.translate("person.callnotsupported"));
              }
              : null);

      // add to contact list
      if (urlmail.isNotEmpty) {
        contactList.add(
          ContactList(
            name: contactType.name,
            icon: Icons.email,
            value: contact.value,
            onAction:
                cannotcall ??
                () async {
                  if (await canLaunchUrl(Uri.parse(urlmail))) {
                    await launchUrl(Uri.parse(urlmail));
                  } else {
                    if (context.mounted) {
                      SnackBarUtils.errorSnackbar(context, AppI18N.instance.translate("person.errorlaunchaction"));
                    }
                  }
                },
          ),
        );
      }
      if (urlmessage.isNotEmpty) {
        contactList.add(
          ContactList(
            name: contactType.name,
            icon: Icons.message,
            value: contact.value,
            onAction:
                cannotcall ??
                () async {
                  if (await canLaunchUrl(Uri.parse(urlmessage))) {
                    await launchUrl(Uri.parse(urlmessage));
                  } else {
                    if (context.mounted) {
                      SnackBarUtils.errorSnackbar(context, AppI18N.instance.translate("person.errorlaunchaction"));
                    }
                  }
                },
          ),
        );
      }
      if (urlcall.isNotEmpty) {
        contactList.add(
          ContactList(
            name: contactType.name,
            icon: Icons.call,
            value: contact.value,
            onAction:
                cannotcall ??
                () async {
                  if (await canLaunchUrl(Uri.parse(urlcall))) {
                    await launchUrl(Uri.parse(urlcall));
                  } else {
                    if (context.mounted) {
                      SnackBarUtils.errorSnackbar(context, AppI18N.instance.translate("person.errorlaunchaction"));
                    }
                  }
                },
          ),
        );
      }
    }

    return MainWidget(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppThemeColor.primaryColor,
          title: Text(AppI18N.instance.translate("person.appbartitle")),
        ),
        body: BodyScaffold(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: personColor,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Text(
                  displayName,
                  style: TextStyle(color: personTextColor, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: double.infinity,
                color: personColor.withAlpha(30),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("$locationName ", style: const TextStyle(fontSize: 14)),
                        Text(locationCode ?? "", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(companyName, style: const TextStyle(fontSize: 12)),
                        Text(roleName.isNotEmpty ? " - " : "", style: const TextStyle(fontSize: 12)),
                        Text(roleName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...contactList.map((contact) {
                return ListTile(
                  leading: Icon(contact.icon),
                  title: Text(contact.name, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(contact.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  trailing:
                      contact.onAction != null
                          ? IconButton(onPressed: contact.onAction, icon: const Icon(Icons.launch))
                          : null,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
