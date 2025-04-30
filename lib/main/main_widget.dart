/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/utils/offline_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MainWidget extends StatefulWidget {
  final Widget child;
  // set the offline manager enabled
  static bool offlineManagerEnabled = true;
  // set the offline manager on hardmode
  static bool offlineManagerHardmode = false;

  const MainWidget({super.key, required this.child});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  final ConfigRepository configRepository = GetIt.instance.get<ConfigRepository>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainWidget.offlineManagerEnabled
        ? OfflineManager(hardmode: MainWidget.offlineManagerHardmode, child: widget.child)
        : widget.child;
  }
}
