/* eslint-disable indent */
// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import React, { useState, useEffect, useContext } from 'react';
import {
  StyleSheet,
  Text,
  View,
  KeyboardAvoidingView,
  Platform,
  TextInput,
  Alert,
  ActivityIndicator
} from 'react-native';

// load contexts
import MainContext from '../../../contexts/MainContext';

// load settings
import theme from '../../../themes/themes.default';
import I18n from '../../../locales/locales';
import Config from '../../../config/config';

// load components
import ButtonTouch from '../../ButtonTouch/components/ButtonTouch';

// load helpers
import ApiConfigHelper from '../helpers/ApiConfig.helpers';
import ToastHelper from '../../AppMain/helpers/Toast.helpers';

/**
 * component
 */
export default function ApiConfig() {
  const { state, dispatch } = useContext(MainContext);
  const { settings } = state;

  // states
  const [apiuri, setApiuri] = useState('');
  const [isloading, setIsloading] = useState(false);

  // constants
  const canedit = Config.apiuri == null;

  // effects
  useEffect(() => {
    setApiuri((settings != null ? settings.apiuri : null));
  }, []);

  /**
   * check if a string is a valid url
   * @param {string} str
   */
  function validURL(str) {
    if (str.startsWith('http:') || str.startsWith('https:')) {
      try {
        const url = new URL(str);
        if (url != null) return true;
      } catch {
        return false;
      }
    }
    return false;
  }

  // loader indicator
  if (isloading) {
    return (
      <View style={styles.containerloading}>
        <Text style={styles.loading}>{I18n.t('apiconfig.loading')}</Text>
        <ActivityIndicator />
      </View>
    );
  }

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={styles.container}>
      <View style={styles.viewform}>
        <Text
          style={styles.textlabel}
        >
          {canedit
          ? I18n.t('apiconfig.apiurilabel')
          : I18n.t('apiconfig.apiurilabelview')}
        </Text>
        <TextInput
          style={styles.input}
          autoCapitalize="none"
          editable={canedit}
          autoCorrect={false}
          placeholder={I18n.t('apiconfig.apiuriplaceholder')}
          value={apiuri}
          placeholderTextColor={theme.COLOR_TEXTINPUTPLACEHOLDER}
          underlineColorAndroid="transparent"
          returnKeyType="next"
          onChangeText={(text) => setApiuri(text)}
        />
      </View>
      {canedit
        ? (
          <View style={styles.viewbutton}>
            <ButtonTouch
              onPress={() => {
                let uri = apiuri;
                if (uri != null) uri = uri.trim();
                if (uri === '') {
                  Alert.alert(
                    I18n.t('apiconfig.apiurlchangetitle'),
                    I18n.t('apiconfig.apiurlchangemessage'),
                    [
                      {
                        text: I18n.t('apiconfig.buttoncancel'),
                        style: 'cancel'
                      },
                      {
                        text: I18n.t('apiconfig.buttonok'),
                        onPress: () => {
                          setIsloading(true);
                          ApiConfigHelper.setApiuri(dispatch, null)
                            .catch((err) => {
                              setIsloading(false);
                              ToastHelper.showAlertMessage(err);
                            });
                        }
                      },
                    ]
                  );
                  return;
                }
                if (uri == null) {
                  ToastHelper.showAlertMessage(I18n.t('apiconfig.seterrorempty'));
                  return;
                }
                if (!(uri.startsWith('http://') && !uri.startsWith('https://'))) { uri = `http://${uri}`; }
                if (!validURL(uri)) {
                  ToastHelper.showAlertMessage(I18n.t('apiconfig.seterrorinvalidurl'));
                  return;
                }
                if (!uri.endsWith('/')) uri = `${uri}/`;
                if (settings.apiuri !== uri) {
                  if (settings.apiuri != null) {
                    Alert.alert(
                      I18n.t('apiconfig.apiurlchangetitle'),
                      I18n.t('apiconfig.apiurlchangemessage'),
                      [
                        {
                          text: I18n.t('apiconfig.buttoncancel'),
                          style: 'cancel'
                        },
                        {
                          text: I18n.t('apiconfig.buttonok'),
                          onPress: () => {
                            setIsloading(true);
                            ApiConfigHelper.setApiuri(dispatch, uri)
                              .catch((err) => {
                                setIsloading(false);
                                ToastHelper.showAlertMessage(err);
                              });
                          }
                        },
                      ]
                    );
                  } else {
                    setIsloading(true);
                    ApiConfigHelper.setApiuri(dispatch, uri)
                      .catch((err) => {
                        setIsloading(false);
                        ToastHelper.showAlertMessage(err);
                      });
                  }
                }
              }}
              title={I18n.t('apiconfig.buttonsave')}
            />
          </View>
        )
        : null }
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
  containerloading: {
    flex: 1,
    alignContent: 'center',
    justifyContent: 'center'
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
  },
  loading: {
    textAlign: 'center',
    paddingBottom: 5
  }
});
