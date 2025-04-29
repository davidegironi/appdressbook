/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/auth/repositories/auth_repository.dart';
import 'package:appdressbook/config/prefskeys.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/pages/addressbook/cubit/contacts_cubit.dart';
import 'package:appdressbook/pages/addressbook/cubit/contacts_state.dart';
import 'package:appdressbook/pages/addressbook/screen/person_screen.dart';
import 'package:appdressbook/api/appdressbook_repository.dart';
import 'package:appdressbook/api/entities/appdressbookcontacts.dart';
import 'package:appdressbook/pages/addressbook/screen/components/contact_circle.dart';
import 'package:appdressbook/pages/addressbook/screen/components/location_box.dart';
import 'package:appdressbook/main/app_localization.dart';
import 'package:appdressbook/main/app_themedata.dart';
import 'package:appdressbook/main/body_scaffold.dart';
import 'package:appdressbook/main/main_widget.dart';
import 'package:appdressbook/pages/settings/screen/settings_screen.dart';
import 'package:appdressbook/utils/loading_spinner.dart';
import 'package:appdressbook/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ContactsScreen extends StatefulWidget {
  static const String routeName = '/contacts';

  static const int maxNameLenght = 20;
  static const int maxNameLenghtLatest = 10;
  static const int maxLatestContacts = 5;

  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final AuthRepository authRepository = GetIt.instance.get<AuthRepository>();
  final ConfigRepository configRepository = GetIt.instance.get<ConfigRepository>();

  // main cubit
  late final AppDressBookContactsCubit _cubit;

  // loaded contact list
  AppDressBookContacts contacts = AppDressBookContacts(
    persons: [],
    contacttypes: [],
    companytypes: [],
    roletypes: [],
    locationtypes: [],
    hash: "",
  );

  // check is is login
  bool islogin = false;

  // search functionality
  final TextEditingController searchController = TextEditingController();
  String searchText = "";
  List<AppDressBookContactsPersons> searchedContacts = [];

  // contacts by letter
  Map<String, List<AppDressBookContactsPersons>> contactsByLetter = {};
  List<String> contactsLetters = [];
  Map<String, GlobalKey> contactsLettersKeys = {};

  // latest contacts
  bool showLatestContacts = false;
  List<String> latestContactCodes = [];
  List<AppDressBookContactsPersons> latestContacts = [];

  @override
  void initState() {
    super.initState();

    // initialize cubit
    _cubit = AppDressBookContactsCubit();

    // check if is logged in
    setState(() => islogin = authRepository.isCurrentlogin());

    // add listener to search controller
    searchController.addListener(onSearchChanged);

    // load data
    reloadContacts();
  }

  @override
  void dispose() {
    // remove listener from search controller and dispose it
    searchController.removeListener(onSearchChanged);
    searchController.dispose();

    super.dispose();
  }

  /// search bar listener
  void onSearchChanged() {
    setState(() {
      searchText = searchController.text;
      // update filtered contacts based on search text
      updateContactList();
    });
  }

  /// update grouped contacts based on filtered contacts
  void updateContactList() {
    contactsByLetter = {};
    contactsLetters = [];
    contactsLettersKeys = {};

    // aply search filter
    if (searchText.isEmpty) {
      searchedContacts = List.from(contacts.persons);
    } else {
      final searchLower = searchText.toLowerCase();
      searchedContacts =
          contacts.persons.where((contact) {
            return contact.firstname.toLowerCase().contains(searchLower) ||
                contact.lastname.toLowerCase().contains(searchLower);
          }).toList();
    }

    // sort filtered persons
    searchedContacts.sort((a, b) => a.lastname.compareTo(b.lastname));

    for (AppDressBookContactsPersons item in searchedContacts) {
      final firstLetter = item.lastname.isNotEmpty ? item.lastname[0].toUpperCase() : '#';
      // add to grouped contacts
      if (!contactsByLetter.containsKey(firstLetter)) {
        contactsByLetter[firstLetter] = [];
      }
      contactsByLetter[firstLetter]!.add(item);
      // add to section keys
      if (!contactsLettersKeys.containsKey(firstLetter)) {
        contactsLettersKeys[firstLetter] = GlobalKey();
      }
    }

    // sort keys alphabetically
    contactsLetters = contactsByLetter.keys.toList()..sort();
  }

  // request a reload for contacts contacts
  Future<void> reloadContacts() async {
    // reload contacts if needed
    if (configRepository.prefs.getBool(PrefsKeys.refreshContacts.toString()) == null) {
      configRepository.prefs.setBool(PrefsKeys.refreshContacts.toString(), true);
    }
    bool refreshContacts = configRepository.prefs.getBool(PrefsKeys.refreshContacts.toString()) ?? true;

    // also load preferences related to contacts
    showLatestContacts = configRepository.prefs.getBool(PrefsKeys.showLatestContacts.toString()) ?? false;

    if (refreshContacts) {
      _cubit.contactslist();
    }
  }

  // load latest contact codes
  void loadLatestContacts() {
    latestContactCodes = configRepository.prefs.getStringList(PrefsKeys.latestContacts.toString()) ?? [];

    // map codes to actual contact objects
    latestContacts =
        latestContactCodes
            .map((code) => contacts.persons.firstWhere((person) => person.code == code))
            .whereType<AppDressBookContactsPersons>()
            .toList();

    // limit to most recent
    if (latestContacts.length > ContactsScreen.maxLatestContacts) {
      latestContacts = latestContacts.sublist(0, ContactsScreen.maxLatestContacts);
    }
  }

  // ssave a contact to latest contacts
  void addToLatestContacts(String contactCode) {
    // remove code if it already exists
    latestContactCodes.remove(contactCode);

    // add code to the beginning of the list
    latestContactCodes.insert(0, contactCode);

    // limit to most recent
    if (latestContactCodes.length > ContactsScreen.maxLatestContacts) {
      latestContactCodes = latestContactCodes.sublist(0, ContactsScreen.maxLatestContacts);
    }

    // save to preferences
    configRepository.prefs.setStringList(PrefsKeys.latestContacts.toString(), latestContactCodes);

    // update latest contacts list
    loadLatestContacts();
  }

  /// cubit listener
  void _listener(context, state) {
    if (state is AppDressBookContactsSuccess) {
      setState(() {
        contacts = state.value;

        // initialize filtered contacts with all contacts
        searchedContacts = List.from(contacts.persons);

        // update grouped contacts
        updateContactList();

        // load latest contacts
        loadLatestContacts();
      });
    } else if (state is AppDressBookContactsFailure) {
      SnackBarUtils.errorSnackbar(context, state.error);
    }
  }

  // contact item widget
  Widget contactItem(AppDressBookContactsPersons contact, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: InkWell(
        onTap: onTap,
        hoverColor: AppThemeColor.transparentColor,
        child: Row(
          children: [
            // avatar
            ContactCircle(contact: contact),

            const SizedBox(width: 12),

            // contact info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.fullName.length > ContactsScreen.maxNameLenght
                        ? '${contact.fullName.substring(0, ContactsScreen.maxNameLenght)}...'
                        : contact.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (contact.locationcode != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [LocationBox(locationcode: contact.locationcode ?? ""), const SizedBox(width: 8)],
                        ),
                      if (contact.rolecode != null)
                        Text(
                          contacts.roletypes
                              .firstWhere(
                                (item) => item.code == contact.rolecode,
                                orElse: () => AppDressBookContactsRoleTypes(code: contact.rolecode ?? "", name: ""),
                              )
                              .name,
                          style: TextStyle(color: AppThemeColor.reducedText, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: AppDressBookRepository(),
      child:
          islogin == false
              ? Text(AppI18N.instance.translate("contacts.notloggedin"))
              : BlocProvider.value(
                value: _cubit,
                child: BlocConsumer<AppDressBookContactsCubit, AppDressBookContactsState>(
                  listener: _listener,
                  builder: (context, state) {
                    return MainWidget(
                      child: Scaffold(
                        appBar: AppBar(
                          backgroundColor: AppThemeColor.primaryColor,
                          title: Text(AppI18N.instance.translate("contacts.appbartitle")),
                          actions: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () {
                                Navigator.of(context).pushNamed(SettingsScreen.routeName).then((_) {
                                  reloadContacts();
                                });
                              },
                            ),
                          ],
                        ),
                        body: BodyScaffold(
                          isPadded: false,
                          hasScollBody: true,
                          child:
                              state is AppDressBookContactsLoading
                                  ? const Align(alignment: Alignment.center, child: LoadingSpinner())
                                  : contacts.persons.isEmpty
                                  ? Center(child: Text(AppI18N.instance.translate("contacts.nocontacts")))
                                  : Stack(
                                    children: [
                                      Column(
                                        children: [
                                          // search bar
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                            child: TextField(
                                              controller: searchController,
                                              decoration: InputDecoration(
                                                hintText: AppI18N.instance.translate("contacts.search"),
                                                prefixIcon: const Icon(Icons.search),
                                                suffixIcon:
                                                    searchText.isNotEmpty
                                                        ? IconButton(
                                                          icon: const Icon(Icons.clear),
                                                          onPressed: () {
                                                            searchController.clear();
                                                          },
                                                        )
                                                        : null,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  borderSide: BorderSide.none,
                                                ),
                                                filled: true,
                                                fillColor: AppThemeColor.reducedFill,
                                              ),
                                            ),
                                          ),

                                          // show latest
                                          if (searchText.isEmpty && latestContacts.isNotEmpty && showLatestContacts)
                                            SizedBox(
                                              height: 90,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.horizontal,
                                                itemCount: latestContacts.length,
                                                itemBuilder: (context, index) {
                                                  final contact = latestContacts[index];
                                                  return SizedBox(
                                                    width: 100,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          addToLatestContacts(contact.code);
                                                          Navigator.of(context).pushNamed(
                                                            PersonScreen.routeName,
                                                            arguments: PersonScreenArguments(
                                                              contact,
                                                              contacts.companytypes,
                                                              contacts.contacttypes,
                                                              contacts.locationtypes,
                                                              contacts.roletypes,
                                                            ),
                                                          );
                                                        },
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            ContactCircle(contact: contact, radius: 30),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              contact.fullName.length >
                                                                      ContactsScreen.maxNameLenghtLatest
                                                                  ? '${contact.fullName.substring(0, ContactsScreen.maxNameLenghtLatest)}...'
                                                                  : contact.fullName,
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),

                                          // Search results count when searching
                                          if (searchText.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                              child: Text(
                                                '${searchedContacts.length} ${AppI18N.instance.translate("contacts.searchresults")}',
                                                style: const TextStyle(fontStyle: FontStyle.italic),
                                              ),
                                            ),

                                          // Divider
                                          const Divider(height: 2),

                                          // List of contacts with section headers
                                          Expanded(
                                            child:
                                                searchedContacts.isEmpty && searchText.isNotEmpty
                                                    ? Center(
                                                      child: Text(AppI18N.instance.translate("contacts.noresults")),
                                                    )
                                                    : ListView.builder(
                                                      itemCount: contactsLetters.length,
                                                      itemBuilder: (context, sectionIndex) {
                                                        final letter = contactsLetters[sectionIndex];
                                                        final sectionContacts = contactsByLetter[letter]!;

                                                        return Column(
                                                          key: contactsLettersKeys[letter],
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            // section letter indicator (only once per section)
                                                            Align(
                                                              alignment: Alignment.centerRight,
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(right: 25.0),
                                                                child: Text(
                                                                  letter,
                                                                  style: TextStyle(
                                                                    color: AppThemeColor.reducedText,
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            // Contact items in this section
                                                            ...sectionContacts.map(
                                                              (contact) => Column(
                                                                children: [
                                                                  contactItem(contact, () {
                                                                    // add to latest contact
                                                                    addToLatestContacts(contact.code);

                                                                    // show the contact
                                                                    Navigator.of(context)
                                                                        .pushNamed(
                                                                          PersonScreen.routeName,
                                                                          arguments: PersonScreenArguments(
                                                                            contact,
                                                                            contacts.companytypes,
                                                                            contacts.contacttypes,
                                                                            contacts.locationtypes,
                                                                            contacts.roletypes,
                                                                          ),
                                                                        )
                                                                        .then((_) {
                                                                          setState(() {
                                                                            loadLatestContacts();
                                                                          });
                                                                        });
                                                                  }),
                                                                  const Divider(height: 1),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                          ),
                                        ],
                                      ),

                                      // alphabet navigation on the right (only show when not searching or search has results)
                                      if (contactsLetters.isNotEmpty)
                                        Positioned(
                                          right: 0,
                                          top: searchText.isEmpty ? 230 : 160, // Adjust position based on search state
                                          bottom: 20,
                                          width: 20,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0x80FFFFFF),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                return SingleChildScrollView(
                                                  physics: const ClampingScrollPhysics(),
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children:
                                                          contactsLetters
                                                              .map(
                                                                (letter) => GestureDetector(
                                                                  onTap: () {
                                                                    // Find the index of the section with this letter
                                                                    final index = contactsLetters.indexOf(letter);
                                                                    if (index != -1) {
                                                                      // Scroll to the corresponding section
                                                                      Scrollable.ensureVisible(
                                                                        contactsLettersKeys[letter]!.currentContext!,
                                                                        alignment: 0.0,
                                                                        duration: const Duration(milliseconds: 300),
                                                                        curve: Curves.easeInOut,
                                                                      );
                                                                    }
                                                                  },
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                                    child: Text(
                                                                      letter,
                                                                      style: TextStyle(
                                                                        fontSize: 10,
                                                                        fontWeight:
                                                                            contactsLetters.contains(letter)
                                                                                ? FontWeight.bold
                                                                                : FontWeight.normal,
                                                                        color:
                                                                            contactsLetters.contains(letter)
                                                                                ? AppThemeColor.mainText
                                                                                : AppThemeColor.reducedText,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                              .toList(),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
