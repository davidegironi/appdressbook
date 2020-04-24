// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import React, { useContext } from 'react';
import {
  StyleSheet,
  Text,
  View,
  SafeAreaView,
  SectionList,
  Image,
  TouchableOpacity,
  Switch
} from 'react-native';
import { useNavigation } from '@react-navigation/native';

// load contexts
import MainContext from '../../../contexts/MainContext';

// load settings
import theme from '../../../themes/themes.default';
import I18n from '../../../locales/locales';

// load pages
import navpages from '../../AppMain/components/AppNavigator.pages';

// load helpers
import ToastHelper from '../../AppMain/helpers/Toast.helpers';
import SettingsHelper from '../helpers/Settings.helpers';

// load images
const imageKeyboardArrowRight = require('../../../images/keyboard_arrow_right.png');

/**
 * component
 */
export default function Settings() {
  const { state, dispatch } = useContext(MainContext);
  const { auth, settings } = state;
  const navigation = useNavigation();

  /**
   * render the settings items
   * @param {object} param0
   */
  const SettingsItem = ({
    text, value, type, onPress
  }) => {
    let ret = null;
    switch (type) {
      case 'switch':
        ret = (
          <View
            style={StyleSheet.flatten([styles.settingsbutton, { flexDirection: 'row' }])}
          >
            <Text
              style={StyleSheet.flatten([styles.settingstext, { flex: 1 }])}
            >
              {text}
            </Text>
            <Switch
              thumbColor={value ? theme.COLOR_SETTINGSSWITCHON : theme.COLOR_SETTINGSSWITCHOFF}
              trackColor={{
                true: theme.COLOR_SETTINGSSWITCHONBACK,
                false: theme.COLOR_SETTINGSSWITCHOFFBACK
              }}
              onValueChange={onPress}
              value={value}
              style={styles.settingsswitchright}
            />
          </View>
        );
        break;
      case 'button':
        ret = (
          <TouchableOpacity
            style={StyleSheet.flatten([styles.settingsbutton, { flexDirection: 'row' }])}
            onPress={onPress}
          >
            <Text
              style={StyleSheet.flatten([styles.settingstext, { flex: 1 }])}
            >
              {text}
            </Text>
            <Image
              source={imageKeyboardArrowRight}
              style={styles.settingsimageright}
            />
          </TouchableOpacity>
        );
        break;
      case 'text':
      default:
        ret = (
          <Text style={styles.settingstext}>
            {text}
          </Text>
        );
        break;
    }
    return ret;
  };

  /**
   * render the settings header
   * @param {object} param0
   */
  const SettingsHeader = ({
    title
  }) => (
    <View style={styles.settingsheader}>
      <Text style={styles.settingsheadertext}>
        {title}
      </Text>
    </View>
  );

  // data for the info group
  let infodata = [];
  if (settings.terms != null) {
    infodata = [...infodata,
      {
        id: 2,
        type: 'button',
        text: I18n.t('settings.terms'),
        onPress: () => navigation.navigate(navpages.Terms)
      }];
  }
  if (settings.privacy != null) {
    infodata = [...infodata,
      {
        id: 3,
        type: 'button',
        text: I18n.t('settings.privacy'),
        onPress: () => navigation.navigate(navpages.Privacy)
      }];
  }

  // settings data
  const settingsData = [
    {
      title: I18n.t('settings.account'),
      data: [
        {
          id: 1,
          type: auth.userinfo != null ? 'button' : 'text',
          text: auth.userinfo != null ? auth.userinfo.displayname : I18n.t('settings.guestuser'),
          onPress: auth.userinfo != null ? () => navigation.navigate(navpages.Profile) : null
        }
      ]
    },
    {
      title: I18n.t('settings.remoteserver'),
      data: [
        {
          id: 1,
          type: 'button',
          text: I18n.t('settings.apiconfig'),
          onPress: () => navigation.navigate(navpages.ApiConfig)
        }
      ]
    },
    {
      title: I18n.t('settings.config'),
      value: null,
      data: [
        {
          id: 1,
          type: 'switch',
          text: I18n.t('settings.getcontactsrefresh'),
          value: settings.getcontactsrefresh,
          onPress: () => {
            let getcontactsrefresh = false;
            let getcontactsrefreshwifi = false;
            if (settings.getcontactsrefresh) {
              getcontactsrefresh = false;
              getcontactsrefreshwifi = false;
            } else {
              getcontactsrefresh = true;
              getcontactsrefreshwifi = false;
            }
            // update the settings
            const newsettings = settings;
            newsettings.getcontactsrefresh = getcontactsrefresh;
            newsettings.getcontactsrefreshwifi = getcontactsrefreshwifi;
            // save settings
            SettingsHelper.setSettings(dispatch, newsettings)
              .catch((err) => {
                ToastHelper.showAlertMessage(err);
              });
          }
        },
        {
          id: 2,
          type: 'switch',
          text: I18n.t('settings.getcontactsrefreshwifi'),
          value: settings.getcontactsrefreshwifi,
          onPress: () => {
            // update the settings
            const newsettings = settings;
            newsettings.getcontactsrefreshwifi = !settings.getcontactsrefreshwifi;
            // save settings
            SettingsHelper.setSettings(dispatch, newsettings)
              .catch((err) => {
                ToastHelper.showAlertMessage(err);
              });
          }
        }
      ]
    },
    {
      title: I18n.t('settings.info'),
      data: [
        {
          id: 1,
          type: 'button',
          text: I18n.t('settings.about'),
          onPress: () => navigation.navigate(navpages.About)
        },
        ...infodata
      ]
    }
  ];

  return (
    <SafeAreaView style={styles.container}>
      <SectionList
        sections={settingsData}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <SettingsItem
            text={item.text}
            value={item.value}
            type={item.type}
            onPress={item.onPress}
          />
        )}
        renderSectionHeader={({ section: { title } }) => (
          <SettingsHeader title={title} />
        )}
      />
    </SafeAreaView>
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
  settingsheader: {
    margin: 0,
    paddingLeft: 10,
    paddingTop: 8,
    paddingBottom: 8,
    backgroundColor: theme.COLOR_SETTINGSHEADER,
    borderBottomColor: theme.COLOR_SETTINGSHEADERBORDER,
    borderBottomWidth: 2,
  },
  settingsheadertext: {
    fontSize: 18,
  },
  settingstext: {
    margin: 0,
    paddingLeft: 10,
    paddingTop: 8,
    paddingBottom: 6,
    fontSize: 16
  },
  settingsimageright: {
    marginRight: 15,
    margin: 5,
    height: 25,
    width: 25,
    resizeMode: 'contain'
  },
  settingsswitchright: {
    marginRight: 15,
    transform: [{ scaleX: 0.8 }, { scaleY: 0.8 }]
  }
});
