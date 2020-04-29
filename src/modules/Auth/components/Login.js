// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import React, {
  useState, useEffect, useRef, useContext
} from 'react';
import {
  StyleSheet,
  Text,
  View,
  KeyboardAvoidingView,
  TextInput,
  Platform
} from 'react-native';

// load contexts
import MainContext from '../../../contexts/MainContext';

// load settings
import theme from '../../../themes/themes.default';
import I18n from '../../../locales/locales';

// load components
import ButtonTouch from '../../ButtonTouch/components/ButtonTouch';

// load helpers
import ToastHelper from '../../AppMain/helpers/Toast.helpers';
import AuthHelper from '../helpers/Auth.helpers';

/**
 * component
 */
export default function Login() {
  const { state, dispatch } = useContext(MainContext);
  const { settings } = state;

  // states
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isloading, setIsloading] = useState(false);

  // refs
  const usernameRef = useRef(null);
  const passwordRef = useRef(null);

  // effects
  useEffect(() => {
    usernameRef.current.focus();
  }, []);

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={styles.container}>
      <View style={styles.viewlogo}>
        {settings.companyname != null
          ? <Text style={styles.companyname}>{settings.companyname}</Text>
          : null}
        <Text style={styles.title}>{I18n.t('login.title')}</Text>
      </View>
      <View style={styles.viewform}>
        <TextInput
          style={styles.input}
          autoCapitalize="none"
          autoCorrect={false}
          placeholder={I18n.t('login.usernameplaceholder')}
          placeholderTextColor={theme.COLOR_TEXTINPUTPLACEHOLDER}
          underlineColorAndroid="transparent"
          returnKeyType="next"
          editable={!isloading}
          ref={usernameRef}
          onSubmitEditing={() => passwordRef.current.focus()}
          onChangeText={(text) => setUsername(text)}
        />
        <TextInput
          style={styles.input}
          secureTextEntry
          placeholder={I18n.t('login.passwordplaceholder')}
          placeholderTextColor={theme.COLOR_TEXTINPUTPLACEHOLDER}
          underlineColorAndroid="transparent"
          returnKeyType="go"
          editable={!isloading}
          ref={passwordRef}
          onChangeText={(text) => setPassword(text)}
        />
        <ButtonTouch
          onPress={() => {
            setIsloading(true);
            if (!isloading) {
              AuthHelper.login(dispatch, settings.apiuri, username, password)
                .then(() => {
                  setIsloading(false);
                })
                .catch((err) => {
                  setIsloading(false);
                  ToastHelper.showAlertMessage(err);
                });
            }
          }}
          title={!isloading ? I18n.t('login.buttonlogin') : I18n.t('login.buttonloginloading')}
        />
      </View>
    </KeyboardAvoidingView>
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
  viewlogo: {
    alignItems: 'center',
    flexGrow: 1,
    justifyContent: 'center'
  },
  viewform: {
    justifyContent: 'center',
    margin: 10,
    marginBottom: 10
  },
  companyname: {
    textAlign: 'center',
    fontWeight: 'bold',
    fontSize: 28
  },
  title: {
    textAlign: 'center',
    fontSize: 22,
    color: theme.COLOR_TEXTLOGINTITLE
  },
  input: {
    height: 40,
    backgroundColor: theme.COLOR_TEXTINPUTBACKGROUND,
    marginBottom: 10,
    padding: 10,
    color: theme.COLOR_TEXTINPUT
  }
});
