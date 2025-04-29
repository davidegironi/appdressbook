/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/config/prefskeys.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/utils/sandbox_banner.dart';
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

  bool showSandbox = false;

  @override
  void initState() {
    super.initState();

    // load preferences
    _loadPreferences();
  }

  // load preerences
  Future<void> _loadPreferences() async {
    setState(() {
      final sandbox = configRepository.prefs.getString(PrefsKeys.sandBox.toString());
      if (sandbox == Sandbox.production.toString()) {
        showSandbox = false;
      } else if (sandbox == Sandbox.development.toString()) {
        showSandbox = true;
      } else {
        showSandbox = false;
      }
    });
  }

  // show the main widget
  Widget mainWidget() {
    // enable or disable the offline manager
    return MainWidget.offlineManagerEnabled
        ? OfflineManager(hardmode: MainWidget.offlineManagerHardmode, child: widget.child)
        : widget.child;
  }

  @override
  Widget build(BuildContext context) {
    return showSandbox
        // show the sandbox banner
        ? SandboxBanner(child: mainWidget())
        // show the child component
        : mainWidget();
  }
}
