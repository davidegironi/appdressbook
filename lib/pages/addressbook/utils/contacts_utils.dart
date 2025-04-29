/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:flutter/material.dart';

// randomized color for the avatar
Color getAvatarColor(String seed) {
  final colors = [
    Colors.purple[700]!,
    Colors.blue[400]!,
    Colors.orange[700]!,
    Colors.amber[700]!,
    Colors.green[600]!,
    Colors.teal[500]!,
    Colors.pink[300]!,
    Colors.deepPurple[500]!,
  ];

  // simple hash function
  int hash = 0;
  for (int i = 0; i < seed.length; i++) {
    hash = (hash + seed.codeUnitAt(i)) % colors.length;
  }

  return colors[hash];
}

// get the text color
Color getAvatarTextColor() {
  return Colors.white;
}

// get locatino color
Color getLocationColor(String seed) {
  final colors = [
    Colors.purple[700]!,
    Colors.blue[400]!,
    Colors.orange[700]!,
    Colors.amber[700]!,
    Colors.green[600]!,
    Colors.teal[500]!,
    Colors.pink[300]!,
    Colors.deepPurple[500]!,
  ];

  // simple hash function
  int hash = 0;
  for (int i = 0; i < seed.length; i++) {
    hash = (hash + seed.codeUnitAt(i)) % colors.length;
  }

  return colors[hash];
}
