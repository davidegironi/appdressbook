/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/main/app_localization.dart';
import 'package:flutter/material.dart';

class AlertDialogUtils {
  // show an alert dialog
  static void showAlertDialog(
    BuildContext context, {
    required String title,
    required String message,
    Widget? body,
    Function? onPressCancel,
    Function? onPressContinue,
  }) {
    // directly utilize the context provided to create and show the dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // return an alert dialog
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              // add body only if it's not null
              if (body != null) body,
            ],
          ),
          actions: [
            // show cancel button if onPressCancel is not null
            if (onPressCancel != null)
              ElevatedButton(
                child: Text(
                  AppI18N.instance.translate("alertdialog.buttoncancel"),
                ),
                onPressed: () {
                  onPressCancel();
                  // close dialog using dialog-specific context
                  Navigator.pop(dialogContext, false);
                },
              ),
            // show continue button if onPressContinue is not null
            if (onPressContinue != null)
              ElevatedButton(
                child: Text(
                  AppI18N.instance.translate("alertdialog.buttoncontinue"),
                ),
                onPressed: () async {
                  await onPressContinue();
                  // close dialog using dialog-specific context
                  if (context.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                },
              ),
          ],
        );
      },
    );
  }
}
