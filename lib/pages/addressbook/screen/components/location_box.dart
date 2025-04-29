/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/pages/addressbook/utils/contacts_utils.dart';
import 'package:flutter/material.dart';

class LocationBox extends StatelessWidget {
  final String locationcode;

  const LocationBox({super.key, required this.locationcode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(color: getLocationColor(locationcode), borderRadius: BorderRadius.circular(4.0)),
      child: Text(locationcode, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
