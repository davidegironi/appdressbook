/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:flutter/material.dart';

class BodyScaffold extends StatelessWidget {
  final Widget child;
  final bool hasScollBody;
  final bool isPadded;

  const BodyScaffold({super.key, required this.child, this.hasScollBody = false, this.isPadded = false});

  @override
  Widget build(BuildContext context) {
    // main scaffold body, with scrollview
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: hasScollBody,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: isPadded ? Padding(padding: const EdgeInsets.all(12.0), child: child) : child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
