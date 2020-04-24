// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import React, {
  useState, useEffect, useRef, useContext, useMemo
} from 'react';
import {
  StyleSheet,
  ScrollView,
  View,
  Text,
  ActivityIndicator,
  TouchableHighlight,
  TouchableOpacity,
  SectionList,
  TextInput,
  Image,
  KeyboardAvoidingView,
  Platform,
  useWindowDimensions
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import NetInfo from '@react-native-community/netinfo';

// load contexts
import MainContext from '../../../contexts/MainContext';

// load settings
import theme from '../../../themes/themes.default';
import I18n from '../../../locales/locales';
import Config from '../../../config/config';

// load pages
import navpages from '../../AppMain/components/AppNavigator.pages';

// load helpers
import ToastHelper from '../../AppMain/helpers/Toast.helpers';

// load helpers
import AddressBookHelper from '../helpers/AddressBook.helpers';

// load images
const imageSearch = require('../../../images/search.png');
const imageClear = require('../../../images/clear.png');

// set timeout for the first load
const upsertContactsFetchtimeoutonload = 30000;
// set timeout for timed upserts
const upsertContactsFetchtimeout = 120000;

// set contact styles
const contactHeight = 50;
const latestcontactsWidth = 100;
const latestcontactsHeight = 80;

/**
 * AddressBookList memoized component
 */
const AddressBookList = React.memo((props) => {
  const { contactsData, searchtext, contactslistRef } = props;

  // letters
  const letters = [...new Set(contactsData.map((r) => r.title))].sort();
  const letterview = letters.map((letter, index) => (
    <TouchableHighlight
      key={letter}
      underlayColor={theme.COLOR_ADDRESSBOOKLETTERPRESS}
      onPress={() => {
        contactslistRef.current.scrollToLocation({
          animated: true,
          sectionIndex: index,
          itemIndex: 0,
          viewPosition: 0
        });
      }}
    >
      <Text style={styles.addressbooklistletterstext}>
        {letter}
      </Text>
    </TouchableHighlight>
  ));

  /**
   * return an highlighted text
   * @param {string} text
   * @param {string} highlight
   */
  const getHighlightedText = useMemo(() => (text, highlight) => {
    const parts = text.split(new RegExp(`(${highlight})`, 'gi'));
    const ret = parts.map((part, i) => (
      // eslint-disable-next-line react/no-array-index-key
      <Text key={i}>
        <Text style={highlight != null && part.toLowerCase() === highlight.toLowerCase() ? { fontWeight: 'bold', color: theme.COLOR_ADDRESSBOOKHIGHLIGHTNAME } : {}}>
          { part }
        </Text>
      </Text>
    ));
    return ret;
  }, []);

  return (
    <View style={styles.addressbooklistview}>
      <View style={styles.addressbooklistviewlist}>
        <SectionList
          sections={contactsData}
          keyExtractor={(item) => item.id}
          ref={contactslistRef}
          stickySectionHeadersEnabled
          renderSectionHeader={({ section: { title } }) => (
            <View style={styles.addressbooklistsectionview}>
              <Text style={styles.addressbooklistsectiontext}>
                {title}
              </Text>
            </View>
          )}
          renderItem={({ item }) => {
            const {
              id,
              name,
              color,
              locationcode,
              locationcolor,
              locationcolorinvert,
              roleinfo
            } = item.contact;
            const { onPress } = item;

            const nameview = getHighlightedText(name, searchtext);

            return (
              <TouchableHighlight
                underlayColor={theme.COLOR_ADDRESSBOOKCONTACTPRESS}
                onPress={onPress}
              >
                <View
                  key={id}
                  style={styles.addressbooklistcontact}
                >
                  <View style={styles.addressbooklistcontactshortname}>
                    <View
                      style={StyleSheet.flatten([styles.addressbooklistcontactshortnamecircle,
                        { backgroundColor: color }])}
                    />
                  </View>
                  <View style={styles.addressbooklistcontactview}>
                    <View style={styles.addressbooklistcontactview}>
                      <Text numberOfLines={1} style={styles.addressbooklistcontacttextname}>
                        {nameview}
                      </Text>
                    </View>
                    {locationcode != null || roleinfo != null
                      ? (
                        <View style={styles.addressbooklistcontactviewinfo}>
                          {locationcode != null
                            ? (
                              <View
                                style={StyleSheet.flatten(
                                  [styles.addressbooklistcontactviewlocationcode,
                                    {
                                      backgroundColor: locationcolor
                                    }
                                  ]
                                )}
                              >
                                <Text
                                  numberOfLines={1}
                                  style={StyleSheet.flatten(
                                    [styles.addressbooklistcontacttextlocationcode,
                                      {
                                        color: locationcolorinvert
                                      }
                                    ]
                                  )}
                                >
                                  {locationcode}
                                </Text>
                              </View>
                            )
                            : null}
                          {roleinfo != null
                            ? (
                              <Text
                                numberOfLines={1}
                                style={styles.addressbooklistcontacttextroleinfo}
                              >
                                {roleinfo}
                              </Text>
                            )
                            : null}
                        </View>
                      )
                      : null}
                  </View>
                </View>
              </TouchableHighlight>
            );
          }}
        />
      </View>
      <View style={styles.addressbooklistviewletters}>
        <ScrollView
          style={styles.addressbooklistviewlettersscrollview}
          contentContainerStyle={styles.addressbooklistviewlettersscrollviewconteiner}
        >
          {letterview}
        </ScrollView>
      </View>
    </View>
  );
});

/**
 * LatestContacts memoized component
 */
const LatestContacts = React.memo((props) => {
  const navigation = useNavigation();

  const { latestcontacts } = props;

  if (latestcontacts == null) return null;
  if (latestcontacts.length === 0) return null;

  // latest contact list
  const latestcontactitems = latestcontacts.map(
    (contact) => (
      <TouchableOpacity
        key={contact.id}
        activeOpacity={0.6}
        onPress={() => navigation.navigate(
          navpages.AddressBookContact,
          { contact }
        )}
      >
        <View style={styles.latestcontactsitem}>
          <View
            style={StyleSheet.flatten([styles.latestcontactsitemshortnamecircle,
              { backgroundColor: contact.color }])}
          >
            <Text style={StyleSheet.flatten([styles.latestcontactsitemshortname,
              { color: contact.colorinvert }])}
            >
              {contact.shortname}
            </Text>
          </View>
          <Text numberOfLines={1} style={styles.latestcontactsitemnametext}>
            {contact.namepointed}
          </Text>
        </View>
      </TouchableOpacity>
    )
  );

  return (
    <View style={styles.containerlatestcontacts}>
      {latestcontactitems}
    </View>
  );
});

/**
 * SearchBar memoized component
 */
const SearchBar = React.memo((props) => {
  const { searchtext, searchtextRef, setSearchtext } = props;

  return (
    <View style={styles.containersearchbar}>
      <Image
        source={imageSearch}
        style={styles.searchbarimagesearch}
      />
      <TextInput
        style={styles.searchbarinput}
        autoCapitalize="none"
        value={searchtext}
        ref={searchtextRef}
        placeholder={I18n.t('addressbook.searchinputplaceholder')}
        placeholderTextColor={theme.COLOR_TEXTINPUTPLACEHOLDER}
        underlineColorAndroid="transparent"
        onChangeText={(text) => setSearchtext(text)}
      />
      {searchtext == null || searchtext.length === 0
        ? null
        : (
          <TouchableHighlight
            underlayColor={theme.COLOR_ADDRESSBOOKCANCELPRESS}
            onPress={() => setSearchtext(null)}
          >
            <Image
              source={imageClear}
              style={styles.searchbarimagecancel}
            />
          </TouchableHighlight>
        )}
    </View>
  );
});

/**
 * component
 */
export default function AddressBook() {
  const { state } = useContext(MainContext);
  const { auth, settings } = state;
  const navigation = useNavigation();

  // constants
  const authtoken = (auth != null ? auth.authtoken : null);

  // states
  const [contacts, setContacts] = useState(null);
  const [latestcontacts, setLatestcontacts] = useState([]);
  const [searchtext, setSearchtext] = useState(null);
  const [loadingtimethresholdgone, setLoadingtimethresholdgone] = useState(false);

  // refs
  const searchtextRef = useRef(null);
  const contactslistRef = useRef(null);

  // max latest contacts to show
  const windowWidth = useWindowDimensions().width;
  const latestcontactsmaxitems = Math.floor(windowWidth / latestcontactsWidth);

  /**
   * upsert contacts
   * @param {boolean} forced
   */
  function doUpsertcontacts(forced, timeout) {
    // get contacts
    NetInfo.fetch()
      .then((netInfo) => {
        const isonline = (netInfo.isInternetReachable === null
          ? true
          : netInfo.isConnected && netInfo.isInternetReachable);
        if (
          (settings.getcontactsrefresh && settings.getcontactsrefreshwifi && netInfo.type === 'wifi')
          || (settings.getcontactsrefresh && netInfo.type !== 'none')
          || forced
        ) {
          AddressBookHelper.upsertContacts(
            isonline, settings.apiuri, authtoken, timeout
          )
            .then((getcontacts) => {
              if (getcontacts.errors != null) {
                setContacts([]);
                ToastHelper.showAlertMessage(getcontacts.errors);
              } else {
                setContacts(getcontacts.contacts);
                // refresh latest contacts
                AddressBookHelper.refreshLatestcontacts(
                  getcontacts.contacts,
                  latestcontactsmaxitems
                )
                  .then((latestcontactsnew) => {
                    if (latestcontactsnew != null) {
                      setLatestcontacts(latestcontactsnew.latestcontacts);
                    }
                  })
                  .catch(() => {
                    ToastHelper.showAlertMessage(I18n.t('addressbook.errorloadinglatestcontacts'));
                  });
              }
            })
            .catch(() => {
              setContacts([]);
              ToastHelper.showAlertMessage(I18n.t('addressbook.errorloadingcontacts'));
            });
        }
      })
      .catch(() => {
        setContacts([]);
        ToastHelper.showAlertMessage(I18n.t('addressbook.errornetwork'));
      });
  }

  // effects
  useEffect(() => {
    let mounted = true;

    // set loading time threshold
    setTimeout(() => {
      if (mounted) {
        setLoadingtimethresholdgone(true);
      }
    },
    Config.loadingTimeThreshold);

    // get contacts from local storage
    AddressBookHelper.getContactsStorage()
      .then((getcontacts) => {
        if (getcontacts != null) {
          setContacts(getcontacts.contacts);
          // refresh latest contacts
          AddressBookHelper.refreshLatestcontacts(
            getcontacts.contacts,
            latestcontactsmaxitems
          )
            .then((latestcontactsnew) => {
              if (latestcontactsnew != null) {
                setLatestcontacts(latestcontactsnew.latestcontacts);
              }
            })
            .catch(() => null);
        } else {
          doUpsertcontacts(true, upsertContactsFetchtimeoutonload);
        }
      })
      .catch(() => {
        setContacts([]);
      });

    // refresh contacts
    let refreshlastdate = new Date().getTime();
    const refreshtimeoutTimer = setInterval(() => {
      const now = new Date().getTime();
      if ((now - refreshlastdate) / 1000 > Config.getcontactsrefreshseconds) {
        if (mounted) doUpsertcontacts(false, upsertContactsFetchtimeout);
        refreshlastdate = new Date().getTime();
      }
    }, 1000);

    // unmount component
    return () => {
      mounted = false;
      clearInterval(refreshtimeoutTimer);
    };
  }, []);

  /**
   * press contact function
   * @param {object} contactsel
   */
  const pressContact = useMemo(() => (contact) => {
    AddressBookHelper.addLatestcontactStorage({
      latestcontact: contact,
      datetime: new Date().getTime(),
      latestcontactsmaxitems
    })
      .then((latestcontactsnew) => {
        if (latestcontactsnew != null) {
          setLatestcontacts(latestcontactsnew);
        }
        navigation.navigate(
          navpages.AddressBookContact,
          { contact }
        );
      });
  });

  // get contacts data
  const contactsData = useMemo(() => {
    const contactsDatalist = [];
    if (contacts != null) {
      // get first letter from names
      const letters = [...new Set(contacts.map((r) => r.name[0]))].sort();
      // iterate letters and load contacts
      letters.forEach((letter) => {
        let contactsdataitems = null;
        if (searchtext == null) {
          contactsdataitems = contacts
            .filter((r) => r.name[0] === letter);
        } else {
          contactsdataitems = contacts
            .filter((r) => r.name[0] === letter
              && r.searchstr.toLowerCase().includes(searchtext.toLowerCase()));
        }
        contactsdataitems = contactsdataitems
          .map((contactsel) => ({
            id: contactsel.id,
            contact: contactsel,
            onPress: () => pressContact(contactsel)
          }));
        if (contactsdataitems.length > 0) {
          contactsDatalist.push({
            title: letter,
            data: contactsdataitems
          });
        }
      });
    }
    return contactsDatalist;
  }, [contacts, searchtext]);

  // loader indicator
  if (contacts == null) {
    if (!loadingtimethresholdgone) return null;
    return (
      <View style={styles.containerloading}>
        <Text style={styles.loading}>{I18n.t('addressbook.loading')}</Text>
        <ActivityIndicator />
      </View>
    );
  }

  // no contet
  if (contacts.length === 0
      || (contactsData != null
       && contactsData.length === 0 && (searchtext == null || searchtext.length === 0))) {
    return (
      <View style={styles.containerempty}>
        <Text style={styles.textempty}>{I18n.t('addressbook.nocontent')}</Text>
        <TouchableHighlight
          underlayColor={theme.COLOR_ADDRESSBOOKRELOADPRESS}
          style={styles.touchforceupsert}
          onPress={() => doUpsertcontacts(true, upsertContactsFetchtimeout)}
        >
          <Text style={styles.textforceupsert}>{I18n.t('addressbook.taptoreload')}</Text>
        </TouchableHighlight>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={styles.container}>
      <SearchBar
        searchtext={searchtext}
        searchtextRef={searchtextRef}
        setSearchtext={(text) => setSearchtext(text)}
      />
      <LatestContacts
        latestcontacts={latestcontacts}
      />
      {contactsData.length === 0 && searchtext != null
        ? (
          <View style={styles.containerempty}>
            <Text style={styles.textempty}>
              {`${I18n.t('addressbook.nocontentfound')} "${searchtext}"`}
            </Text>
          </View>
        ) : (
          <View style={styles.containeraddressbooklist}>
            <AddressBookList
              contactsData={contactsData}
              searchtext={searchtext}
              contactslistRef={contactslistRef}
            />
          </View>
        )}
    </KeyboardAvoidingView>
  );
}

/**
 * styles
 */
const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'flex-start'
  },
  containerloading: {
    flex: 1,
    alignContent: 'center',
    justifyContent: 'center'
  },
  containerempty: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center'
  },
  containerlatestcontacts: {
    height: latestcontactsHeight + 15,
    backgroundColor: theme.COLOR_ADDRESSBOOKLATESTCONTACTBACK,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
    zIndex: 10
  },
  containersearchbar: {
    height: 45,
    backgroundColor: theme.COLOR_ADDRESSBOOKSEARCHBAR,
    borderBottomColor: theme.COLOR_ADDRESSBOOKSEARCHBARBORDER,
    borderBottomWidth: 2,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingLeft: 20,
    paddingRight: 20
  },
  containeraddressbooklist: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    backgroundColor: theme.COLOR_ADDRESSBOOKLISTBACK,
    paddingTop: 8
  },
  searchbarinput: {
    backgroundColor: theme.COLOR_ADDRESSBOOKSEARCHINPUT,
    flex: 1,
    paddingLeft: 10,
    paddingRight: 10
  },
  searchbarimagesearch: {
    height: 25,
    width: 25,
    resizeMode: 'contain'
  },
  searchbarimagecancel: {
    height: 20,
    width: 20,
    resizeMode: 'contain'
  },
  latestcontactsitem: {
    height: latestcontactsHeight,
    width: latestcontactsWidth,
    padding: 3,
    alignItems: 'center'
  },
  latestcontactsitemnametext: {
    fontSize: 16,
    paddingTop: 2
  },
  latestcontactsitemshortnamecircle: {
    width: latestcontactsHeight - 5 - 15,
    height: latestcontactsHeight - 5 - 15,
    borderRadius: (latestcontactsHeight - 5) / 2,
    alignItems: 'center',
    justifyContent: 'center'
  },
  latestcontactsitemshortname: {
    fontWeight: 'bold',
    fontSize: 20
  },
  addressbooklistview: {
    flex: 1,
    flexDirection: 'row'
  },
  addressbooklistviewlist: {
    flex: 1
  },
  addressbooklistviewletters: {
    width: 50
  },
  addressbooklistviewlettersscrollview: {
    width: '100%'
  },
  addressbooklistviewlettersscrollviewconteiner: {
    alignContent: 'center',
    justifyContent: 'center',
    flexGrow: 1
  },
  addressbooklistletterstext: {
    fontSize: 14,
    paddingBottom: 2,
    textAlign: 'center'
  },
  addressbooklistsectionview: {
    height: 30,
    backgroundColor: theme.COLOR_ADDRESSBOOKLETTERBACK,
    borderBottomColor: theme.COLOR_ADDRESSBOOKLETTERBORDER,
    borderBottomWidth: 4,
    alignContent: 'flex-end',
    justifyContent: 'center',
    marginRight: 10
  },
  addressbooklistsectiontext: {
    fontSize: 18,
    textAlign: 'right',
    paddingRight: 12
  },
  addressbooklistcontact: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    height: contactHeight
  },
  addressbooklistcontactshortname: {
    paddingLeft: 6,
    paddingRight: 8
  },
  addressbooklistcontactview: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center'
  },
  addressbooklistcontactshortnamecircle: {
    margin: 8 / 2,
    width: contactHeight - 8,
    height: contactHeight - 8,
    borderRadius: (contactHeight - 8) / 2
  },
  addressbooklistcontactviewname: {
    flex: 1,
    justifyContent: 'center'
  },
  addressbooklistcontactviewinfo: {
    flex: 1,
    justifyContent: 'flex-start',
    flexDirection: 'row'
  },
  addressbooklistcontacttextname: {
    fontSize: 16
  },
  addressbooklistcontacttextroleinfo: {
    fontSize: 12,
    color: theme.COLOR_ADDRESSBOOKROLEINFO,
    paddingLeft: 10
  },
  addressbooklistcontactviewlocationcode: {
    height: 15,
    width: 60,
    justifyContent: 'center',
    alignContent: 'center'
  },
  addressbooklistcontacttextlocationcode: {
    fontSize: 10,
    textAlign: 'center'
  },
  loading: {
    textAlign: 'center',
    paddingBottom: 5
  },
  textempty: {
    textAlign: 'center',
    fontSize: 18
  },
  textforceupsert: {
    textAlign: 'center',
    fontSize: 18,
    fontWeight: 'bold'
  },
});
