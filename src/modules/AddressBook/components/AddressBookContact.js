// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import React, { useState, useEffect } from 'react';
import {
  StyleSheet,
  Text,
  View,
  ScrollView,
  TouchableHighlight,
  Linking,
  Image
} from 'react-native';
import { useRoute } from '@react-navigation/native';
import Clipboard from '@react-native-community/clipboard';

// load settings
import theme from '../../../themes/themes.default';
import I18n from '../../../locales/locales';

// load helpers
import ToastHelper from '../../AppMain/helpers/Toast.helpers';

// load images
const imageCallmade = require('../../../images/callmade.png');
const imageEmail = require('../../../images/email.png');
const imagePhone = require('../../../images/phone.png');
const imageMessage = require('../../../images/message.png');
const imageFace = require('../../../images/face.png');

/**
 * component
 */
export default function AddressBookContact() {
  const route = useRoute();

  // states
  const [enabledurls, setEnabledurls] = useState([]);

  // constants
  const contact = (
    route.params != null && route.params.contact != null
      ? route.params.contact
      : null);

  // effects
  useEffect(() => {
    // build the contacts array
    const allurls = [];
    let id = 0;
    contact.contacts.forEach((personnelcontact) => {
      if (personnelcontact.contacttype === 'email') {
        id += 1;
        allurls.push(
          {
            id,
            type: personnelcontact.contacttype,
            icon: imageEmail,
            url: `mailto:${personnelcontact.contactvalue}`,
            shortname: I18n.t('addressbookcontact.linkemail'),
            contact: personnelcontact.contactvalue,
            name: personnelcontact.contactname,
            singleline: true
          }
        );
      } else if (personnelcontact.contacttype === 'phone') {
        id += 1;
        allurls.push(
          {
            id,
            type: personnelcontact.contacttype,
            icon: imagePhone,
            url: `tel:${personnelcontact.contactvalue}`,
            shortname: I18n.t('addressbookcontact.linkcall'),
            contact: personnelcontact.contactvalue,
            name: personnelcontact.contactname,
            singleline: true
          }
        );
        id += 1;
        allurls.push(
          {
            id,
            type: personnelcontact.contacttype,
            icon: imageMessage,
            url: `sms:${personnelcontact.contactvalue}`,
            shortname: I18n.t('addressbookcontact.linksms'),
            contact: personnelcontact.contactvalue,
            name: personnelcontact.contactname,
            singleline: true
          }
        );
      } else {
        id += 1;
        allurls.push(
          {
            id,
            type: personnelcontact.contacttype,
            icon: imageFace,
            url: null,
            shortname: null,
            contact: personnelcontact.contactvalue,
            name: personnelcontact.contactname,
            singleline: false
          }
        );
      }
    });
    // openable urls
    openableUrls(allurls.filter((r) => r != null))
      .then((urls) => {
        setEnabledurls(urls);
      })
      .catch();
  }, []);

  /**
   * parse enabled urls
   * @param {object} urls
   */
  const openableUrls = async (urls) => {
    let urlsenabled = await Promise.all(urls
      .filter((url) => url.url != null)
      .map(async (url) => Linking.canOpenURL(url.url)
        .then((openable) => ({ ...url, openable }))
        .catch(() => ({ ...url, openable: false }))));
    urlsenabled = urlsenabled
      .filter((url) => url != null);
    urlsenabled = urlsenabled.concat(urls.filter((url) => url.url == null));
    return urlsenabled;
  };

  // check if contact is loaded
  if (contact == null) {
    return (
      <View style={styles.containernocontact}>
        <Text style={styles.textnocontact}>{I18n.t('addressbookcontact.nocontent')}</Text>
      </View>
    );
  }

  // get all contacts
  const contactsall = enabledurls.map((url) => (
    <TouchableHighlight
      key={url.id}
      underlayColor={theme.COLOR_ADDRESSBOOKCONTACTPRESSCONTACT}
      onPress={() => {
        if (url.openable) {
          Linking.openURL(url.url);
        } else {
          Clipboard.setString(url.contact);
          ToastHelper.showInfoMessage(I18n.t('addressbookcontact.copiedtoclipboard'), url.contact);
        }
      }}
      onLongPress={() => {
        Clipboard.setString(url.contact);
        ToastHelper.showInfoMessage(I18n.t('addressbookcontact.copiedtoclipboard'), url.contact);
      }}
    >
      <View style={styles.viewcontactrow}>
        <View style={styles.viewcontacticon}>
          <Image
            source={url.icon}
            style={styles.viewcontacticonimage}
          />
          {url.shortname != null
            ? <Text numberOfLines={1} style={styles.textcontactshortname}>{url.shortname}</Text>
            : null}
        </View>
        <View style={styles.viewcontactvalue}>
          <Text numberOfLines={1} style={styles.textcontactname}>{url.name}</Text>
          {url.singleline
            ? <Text numberOfLines={1} style={styles.textcontactcontact}>{url.contact}</Text>
            : <Text style={styles.textcontactcontact}>{url.contact}</Text>}
        </View>
        <View style={styles.viewcontactaction}>
          {url.openable
            ? (
              <Image
                source={imageCallmade}
                style={styles.viewcontactactionimage}
              />
            )
            : null}
        </View>
      </View>
    </TouchableHighlight>
  ));


  return (
    <View style={styles.container}>

      <View style={[styles.viewheader, { backgroundColor: contact.color }]}>
        <View style={styles.viewheadercontent}>
          <Text
            numberOfLines={1}
            style={[styles.textname, { color: contact.colorinvert }]}
          >
            {contact.name}
          </Text>
        </View>
      </View>

      {
          contact.locationcode != null || contact.locationname != null
          || contact.companyname != null
          || contact.roleinfo != null
            ? (
              <View
                style={[styles.viewsubheader, { backgroundColor: contact.coloropacity }]}
              >
                {contact.locationcode != null || contact.locationname != null
                  ? (
                    <View style={styles.viewsubheadercontent}>
                      <Text numberOfLines={1} style={styles.textlocation}>
                        {contact.locationcode != null ? contact.locationcode + (contact.locationname != null ? ' / ' : '') : ''}
                        {contact.locationname != null ? ` ${contact.locationname}` : ''}
                      </Text>
                    </View>
                  )
                  : null}
                {contact.companyname != null || contact.roleinfo != null
                  ? (
                    <View style={styles.viewsubheadercontent}>
                      <Text numberOfLines={1} style={styles.textcompanyandroleinfo}>
                        <Text style={styles.textcompany}>
                          {contact.companyname != null ? contact.companyname + (contact.roleinfo != null ? '  -  ' : '') : ''}
                        </Text>
                        <Text style={styles.textroleinfo}>
                          {contact.roleinfo != null ? contact.roleinfo : ''}
                        </Text>
                      </Text>
                    </View>
                  )
                  : null}
              </View>
            )
            : null
        }

      <ScrollView>
        <View style={styles.contactslist}>
          {enabledurls.length > 0
            ? (
              <View style={styles.viewcontactcontainer}>
                <View style={styles.viewcontactlist}>
                  {contactsall}
                </View>
              </View>
            )
            : null }
        </View>
      </ScrollView>

    </View>
  );
}

/**
 * styles
 */
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.COLOR_BACKGROUND
  },
  containernocontact: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: theme.COLOR_BACKGROUND
  },
  textnocontact: {
    textAlign: 'center',
    fontSize: 18
  },
  viewheader: {
  },
  viewheadercontent: {
    padding: 30,
    alignItems: 'center',
  },
  textname: {
    fontSize: 26,
    fontWeight: 'bold'
  },
  viewsubheader: {
    backgroundColor: theme.COLOR_BACKGROUND,
    paddingTop: 5,
    paddingBottom: 5
  },
  viewsubheadercontent: {
    padding: 3
  },
  textlocation: {
    fontSize: 16,
    color: theme.COLOR_ADDRESSBOOKCONTACTINFOTEXT,
    textAlign: 'center',
    fontWeight: 'bold'
  },
  textcompanyandroleinfo: {
    color: theme.COLOR_ADDRESSBOOKCONTACTINFOTEXT,
    textAlign: 'center'
  },
  textcompany: {
    fontSize: 14,
    color: theme.COLOR_ADDRESSBOOKCONTACTINFOTEXT,
    textAlign: 'center'
  },
  textroleinfo: {
    fontSize: 14,
    color: theme.COLOR_ADDRESSBOOKCONTACTINFOTEXT,
    textAlign: 'center',
    fontWeight: 'bold'
  },
  contactslist: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'flex-start',
    justifyContent: 'center'
  },
  viewcontactcontainer: {
    flex: 0,
    flexDirection: 'row',
    alignItems: 'flex-start'
  },
  viewcontactlist: {
    flex: 1,
    flexDirection: 'column'
  },
  viewcontactrow: {
    flex: 0,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderBottomColor: theme.COLOR_ADDRESSBOOKCONTACTSECTIONBORDER,
    borderBottomWidth: 1,
    height: 50,
  },
  viewcontactvalue: {
    flex: 1,
    justifyContent: 'center',
  },
  viewcontacticon: {
    flex: 0,
    alignItems: 'center',
    justifyContent: 'center',
    width: 80
  },
  viewcontacticonimage: {
    height: 25,
    width: 25,
    resizeMode: 'contain'
  },
  viewcontactaction: {
    flex: 0,
    alignItems: 'center',
    justifyContent: 'center',
    width: 50
  },
  viewcontactactionimage: {
    height: 20,
    width: 20,
    resizeMode: 'contain'
  },
  textcontactshortname: {
    fontSize: 12
  },
  textcontactname: {
    fontSize: 14
  },
  textcontactcontact: {
    fontSize: 14,
    fontWeight: 'bold'
  }
});
