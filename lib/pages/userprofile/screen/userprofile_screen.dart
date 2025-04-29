/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/pages/about/screen/about_screen.dart';
import 'package:appdressbook/auth/bloc/auth_bloc.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/main/app_localization.dart';
import 'package:appdressbook/auth/repositories/auth_repository.dart';
import 'package:appdressbook/main/app_themedata.dart';
import 'package:appdressbook/utils/alertdialog_utils.dart';
import 'package:appdressbook/main/body_scaffold.dart';
import 'package:appdressbook/main/main_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UserprofileScreen extends StatefulWidget {
  static const String routeName = '/userprofile';

  const UserprofileScreen({super.key});

  @override
  State<UserprofileScreen> createState() => _UserprofileScreenState();
}

class _UserprofileScreenState extends State<UserprofileScreen> {
  final AuthRepository authRepository = GetIt.instance.get<AuthRepository>();
  final ConfigRepository configRepository = GetIt.instance.get<ConfigRepository>();

  // check if is login
  bool islogin = false;

  String apiUrl = "/";
  String companyName = "/";

  @override
  void initState() {
    super.initState();

    // check if is logged in
    setState(() => islogin = authRepository.isCurrentlogin());

    loadPreferences();
  }

  // load preferences
  Future<void> loadPreferences() async {
    setState(() {
      apiUrl = configRepository.config.apiUrl;
      companyName = configRepository.config.config?.companyname ?? "/";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainWidget(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppThemeColor.primaryColor,
          title: Text(AppI18N.instance.translate("userprofile.appbartitle")),
          actions: [
            IconButton(icon: Icon(Icons.info), onPressed: () => Navigator.of(context).pushNamed(AboutScreen.routeName)),
          ],
        ),
        body: BodyScaffold(
          isPadded: true,
          child: Column(
            children: [
              islogin == false
                  ? Text(AppI18N.instance.translate("userprofile.notloggedin"))
                  : Column(
                    children: [
                      TextFormField(
                        readOnly: true,
                        key: Key(companyName.toString()),
                        initialValue: companyName,
                        onChanged: (value) {
                          setState(() => companyName = value);
                        },
                        decoration: InputDecoration(labelText: AppI18N.instance.translate("userprofile.companyname")),
                      ),
                      TextFormField(
                        readOnly: true,
                        key: Key(apiUrl.toString()),
                        initialValue: apiUrl,
                        onChanged: (value) {
                          setState(() => apiUrl = value);
                        },
                        decoration: InputDecoration(labelText: AppI18N.instance.translate("userprofile.apiurl")),
                      ),
                      Padding(padding: const EdgeInsets.all(10.0)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: Text(AppI18N.instance.translate("userprofile.buttonlogout")),
                          onPressed:
                              () => AlertDialogUtils.showAlertDialog(
                                context,
                                title: AppI18N.instance.translate("userprofile.logoutrequesttitle"),
                                message: AppI18N.instance.translate("userprofile.logoutrequesttext"),
                                onPressCancel: () => null,
                                onPressContinue: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                              ),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
