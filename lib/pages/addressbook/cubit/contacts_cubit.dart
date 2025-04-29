/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'dart:convert';

import 'package:appdressbook/config/prefskeys.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/pages/addressbook/cubit/contacts_state.dart';
import 'package:appdressbook/api/appdressbook_repository.dart';
import 'package:appdressbook/api/entities/appdressbookcontacts.dart';
import 'package:appdressbook/main/app_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class AppDressBookContactsCubit extends Cubit<AppDressBookContactsState> {
  final AppDressBookRepository repository = AppDressBookRepository();
  final ConfigRepository configRepository = GetIt.instance.get<ConfigRepository>();

  static const bool alwaysRequestCompleteList = false;

  AppDressBookContactsCubit() : super(AppDressBookContactsInitial());

  // Emit a failure
  void failure(String error) async {
    emit(AppDressBookContactsFailure(error));
  }

  // Request the front list
  Future<void> contactslist() async {
    // emit loading
    emit(AppDressBookContactsLoading());
    String? prefsContacts = configRepository.prefs.getString(PrefsKeys.contacts.toString());
    if (prefsContacts != null) {
      // add a small delay to ensure widget tree is built
      Future.delayed(Duration(milliseconds: 100), () {
        try {
          AppDressBookContacts contacts = AppDressBookContacts.fromMap(jsonDecode(prefsContacts));
          emit(AppDressBookContactsSuccess(contacts));
        } catch (_) {}
      });
    }

    bool isUpdated =
        alwaysRequestCompleteList ||
        prefsContacts == null ||
        configRepository.config.contacts == null ||
        (configRepository.config.contacts != null &&
            await repository.isContactsListUpdated(configRepository.config.contacts!.hash));
    if (isUpdated) {
      // perform the request
      AppDressBookContacts? contacts = await repository.getContactsList();
      // check response
      if (contacts != null) {
        // save contacts to shared preferences
        configRepository.config.contacts = contacts;
        configRepository.prefs.setString(PrefsKeys.contacts.toString(), jsonEncode(contacts.toMap()));
        // emit success
        emit(AppDressBookContactsSuccess(contacts));
      } else {
        // emit error
        emit(AppDressBookContactsFailure(AppI18N.instance.translate("contacts.getlisterror")));
      }
    }
  }
}
