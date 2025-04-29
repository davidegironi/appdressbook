/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/main/app_localization.dart';
import 'package:appdressbook/main/body_scaffold.dart';
import 'package:appdressbook/main/main_widget.dart';
import 'package:flutter/material.dart';

class RouteErrorScreen extends StatelessWidget {
  final String? route;

  const RouteErrorScreen({super.key, this.route = ""});

  @override
  Widget build(BuildContext context) {
    return MainWidget(
      child: Scaffold(
        body: BodyScaffold(
          isPadded: true,
          child: Center(child: Text("${AppI18N.instance.translate("app.noroute")} $route")),
        ),
      ),
    );
  }
}
