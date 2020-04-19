// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import React, { useEffect, useContext } from 'react';
import {
  StyleSheet,
  TouchableOpacity,
  Image
} from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

// load contexts
import MainContext from '../../../contexts/MainContext';

// load settings
import Config from '../../../config/config';
import I18n from '../../../locales/locales';
import theme from '../../../themes/themes.default';

// load components
import Login from '../../Auth/components/Login';
import Profile from '../../Auth/components/Profile';
import Settings from '../../Settings/components/Settings';
import ApiConfig from '../../ApiConfig/components/ApiConfig';
import AddressBook from '../../AddressBook/components/AddressBook';
import AddressBookContact from '../../AddressBook/components/AddressBookContact';
import About from '../../About/components/About';
import Privacy from '../../Privacy/components/Privacy';
import Terms from '../../Terms/components/Terms';

// load helpers
import AuthHelper from '../../Auth/helpers/Auth.helpers';

// load pages
import navpages from './AppNavigator.pages';

// load images
const imageSettings = require('../../../images/settings.png');

/**
 * compoent
 */
export default function AppNavigator() {
  const { state } = useContext(MainContext);
  const { auth, settings } = state;

  // create the stack navigator
  const Stack = createStackNavigator();

  // effects
  useEffect(() => {
    // try to refresh login
    if (
      Config.refreshLoginTokenAfterLogin
      && settings != null
      && settings.needslogin
      && auth.authtoken != null) {
      AuthHelper.refreshLoginToken(settings.apiuri, auth.authtoken);
    }
  }, []);

  /**
   * apiconfig navigator stack
   */
  const ApiConfigNavigator = (
    <>
      <Stack.Screen
        name={navpages.ApiConfig_null}
        component={ApiConfig}
        options={{
          title: I18n.t('appnavigator.apiconfig'),
          headerStyle: styles.headerstyle,
          headerTintColor: theme.COLOR_NAVHEADER
        }}
      />
    </>
  );

  /**
   * guest navigator stack
   */
  const GuestNavigator = (
    <>
      <Stack.Screen
        name={navpages.Login}
        component={Login}
        options={({ navigation }) => ({
          title: I18n.t('appnavigator.login'),
          headerRight: () => (
            <TouchableOpacity
              onPress={() => navigation.navigate(navpages.ApiConfig_guest)}
            >
              <Image
                source={imageSettings}
                style={styles.headerimageright}
              />
            </TouchableOpacity>
          ),
          headerStyle: styles.headerstyle,
          headerTintColor: theme.COLOR_NAVHEADER
        })}
      />
      <Stack.Screen
        name={navpages.ApiConfig_guest}
        component={ApiConfig}
        options={{
          title: I18n.t('appnavigator.apiconfig'),
          headerStyle: styles.headerstyle,
          headerTintColor: theme.COLOR_NAVHEADER
        }}
      />
    </>
  );

  /**
   * logged navigator stack
   */
  const LoggedNavigator = (
    <>
      <Stack.Screen
        name={navpages.AddressBook}
        component={AddressBook}
        options={({ navigation }) => ({
          title: I18n.t('appnavigator.addressbook'),
          headerRight: () => (
            <TouchableOpacity
              onPress={() => navigation.navigate(navpages.Settings)}
            >
              <Image
                source={imageSettings}
                style={styles.headerimageright}
              />
            </TouchableOpacity>
          ),
          headerStyle: styles.headerstyle,
          headerTintColor: theme.COLOR_NAVHEADER
        })}
      />
      <Stack.Screen
        name={navpages.AddressBookContact}
        component={AddressBookContact}
        options={{
          title: I18n.t('appnavigator.addressbookcontact'),
          headerStyle: styles.headerstyle,
          headerTintColor: theme.COLOR_NAVHEADER
        }}
      />
      <Stack.Screen
        name={navpages.Profile}
        component={Profile}
        options={{
          title: I18n.t('appnavigator.profile'),
          headerStyle: styles.headerstyle,
          headerTintColor: theme.COLOR_NAVHEADER
        }}
      />
      <Stack.Screen
        name={navpages.ApiConfig}
        component={ApiConfig}
        options={{
          title: I18n.t('appnavigator.apiconfig'),
          headerStyle: styles.headerstyle,
          headerTintColor: theme.COLOR_NAVHEADER
        }}
      />
      <Stack.Screen
        name={navpages.Settings}
        component={Settings}
        options={{
          title: I18n.t('appnavigator.settings'),
          headerStyle: styles.headerstyle,
          headerTintColor: theme.COLOR_NAVHEADER
        }}
      />
      <Stack.Screen
        name={navpages.About}
        component={About}
        options={{
          title: I18n.t('appnavigator.about'),
          headerStyle: styles.headerstyle,
          headerTintColor: theme.COLOR_NAVHEADER
        }}
      />
      <Stack.Screen
        name={navpages.Privacy}
        component={Privacy}
        options={{
          title: I18n.t('appnavigator.privacy'),
          headerStyle: styles.headerstyle,
          headerTintColor: theme.COLOR_NAVHEADER
        }}
      />
      <Stack.Screen
        name={navpages.Terms}
        component={Terms}
        options={{
          title: I18n.t('appnavigator.terms'),
          headerStyle: styles.headerstyle,
          headerTintColor: theme.COLOR_NAVHEADER
        }}
      />
    </>
  );

  // get the navigator stack to show
  let navigatorstack = null;
  if (settings == null || (settings != null && settings.apiuri == null)) {
    navigatorstack = ApiConfigNavigator;
  } else if (
    (settings != null && settings.needslogin && auth.authtoken != null)
    || (settings != null && !settings.needslogin)) {
    navigatorstack = LoggedNavigator;
  } else {
    navigatorstack = GuestNavigator;
  }

  return (
    <NavigationContainer>
      <Stack.Navigator>
        {navigatorstack}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

/**
 * styles
 */
const styles = StyleSheet.create({
  headerstyle: {
    backgroundColor: theme.COLOR_NAVBACKGROUND
  },
  headertitlestyle: {
    color: theme.COLOR_NAVBACKBUTTONCOLOR,
    fontWeight: 'bold'
  },
  headerleftcontainerstyle: {
    color: theme.COLOR_NAVBACKBUTTONCOLOR,
  },
  headerimageright: {
    padding: 10,
    margin: 5,
    height: 25,
    width: 25,
    resizeMode: 'stretch'
  }
});
