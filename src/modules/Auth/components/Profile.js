// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import React, { useContext } from 'react';
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  Alert
} from 'react-native';

// load settings
import theme from '../../../themes/themes.default';
import I18n from '../../../locales/locales';

// load comopnents
import ButtonTouch from '../../ButtonTouch/components/ButtonTouch';

// load contexts
import MainContext from '../../../contexts/MainContext';

// load helpers
import AuthHelper from '../helpers/Auth.helpers';

/**
 * component
 */
export default function Profile() {
  const { state, dispatch } = useContext(MainContext);
  const { auth } = state;

  return (
    <View style={styles.container}>
      {auth.userinfo != null && auth.userinfo.username != null
        ? (
          <View style={styles.viewform}>
            <Text style={styles.textlabel}>{I18n.t('profile.loggedin')}</Text>
            <TextInput
              style={styles.input}
              value={(auth.userinfo != null ? auth.userinfo.displayname : null)}
              editable={false}
            />
          </View>
        )
        : (
          <View style={styles.viewform}>
            <Text style={styles.textlabel}>{I18n.t('profile.notloggedin')}</Text>
          </View>
        )}
      <View style={styles.viewbutton}>
        <ButtonTouch
          onPress={
            () => Alert.alert(
              I18n.t('profile.alertlogouttitle'),
              I18n.t('profile.alertlogoutmessage'),
              [
                { text: I18n.t('profile.buttoncancel'), style: 'cancel' },
                {
                  text: I18n.t('profile.buttonok'),
                  onPress: () => AuthHelper.logout(dispatch)
                },
              ]
            )
          }
          title={I18n.t('profile.buttonlogout')}
        />
      </View>
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
  viewform: {
    justifyContent: 'center',
    margin: 10,
    marginBottom: 10
  },
  viewbutton: {
    flex: 1,
    justifyContent: 'flex-end',
    margin: 10,
    marginBottom: 10
  },
  textlabel: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  input: {
    height: 40,
    backgroundColor: theme.COLOR_TEXTINPUTBACKGROUND,
    marginBottom: 10,
    padding: 10,
    color: theme.COLOR_TEXTINPUT
  }
});
