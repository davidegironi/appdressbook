/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/pages/addressbook/utils/contacts_utils.dart';
import 'package:appdressbook/api/entities/appdressbookcontacts.dart';
import 'package:flutter/material.dart';

class ContactCircle extends StatelessWidget {
  final AppDressBookContactsPersons contact;
  final double radius;

  const ContactCircle({super.key, required this.contact, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: getAvatarColor('${contact.firstname}${contact.lastname}'),
      child: Text(
        contact.initials,
        style: TextStyle(color: getAvatarTextColor(), fontWeight: FontWeight.bold, fontSize: radius * 0.75),
      ),
    );
  }
}
