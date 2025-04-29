/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:flutter/material.dart';

enum Sandbox { production, development }

class SandboxBanner extends StatelessWidget {
  final Widget child;

  const SandboxBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Banner(
      location: BannerLocation.topStart,
      message: "SANDBOX",
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10.0),
      textDirection: TextDirection.ltr,
      child: child,
    );
  }
}
