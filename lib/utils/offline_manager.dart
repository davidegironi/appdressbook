/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'dart:async';

import 'package:appdressbook/main/app_localization.dart';
import 'package:appdressbook/main/app_themedata.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class OfflineManager extends StatefulWidget {
  final Widget child;
  final bool hardmode;

  const OfflineManager({super.key, required this.child, required this.hardmode});

  @override
  State<OfflineManager> createState() => _OfflineManagerState();
}

class _OfflineManagerState extends State<OfflineManager> {
  late final StreamSubscription<InternetStatus> subscription;

  bool isOnline = true;

  @override
  void initState() {
    super.initState();

    // check internet connection
    _checkConnection();

    // subscrive to check for connection
    subscription = InternetConnection().onStatusChange.listen((status) {
      if (mounted) {
        setState(() {
          isOnline = status == InternetStatus.connected;
        });
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  // check connection
  Future<void> _checkConnection() async {
    isOnline = await InternetConnection().hasInternetAccess;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return isOnline
        ? widget.child
        : Scaffold(
          body: Center(
            child:
                widget.hardmode
                    ? Scaffold(
                      body: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppI18N.instance.translate("offlinemanager.hardmoodetext1")),
                              Text(AppI18N.instance.translate("offlinemanager.hardmoodetext2")),
                            ],
                          ),
                        ),
                      ),
                    )
                    : Stack(
                      fit: StackFit.expand,
                      children: [
                        widget.child,
                        Positioned(
                          height: 32.0,
                          left: 0.0,
                          right: 0.0,
                          bottom: 0.0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              child: Scaffold(
                                backgroundColor: AppThemeColor.offlineForeground,
                                body: Center(
                                  child: Text(
                                    AppI18N.instance.translate("offlinemanager.offline"),
                                    style: TextStyle(color: AppThemeColor.offlineText, fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        );
  }
}
