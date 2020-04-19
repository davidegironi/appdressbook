// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import React, { useEffect, useReducer } from 'react';
import {
  SafeAreaView,
  View
} from 'react-native';

// load components
import Toast from 'react-native-toast-message';

// load contexts
import MainContext from '../../../contexts/MainContext';

// load settings
import Config from '../../../config/config';
import I18n from '../../../locales/locales';

// load components
import AppSplash from './AppSplash';
import AppNavigator from './AppNavigator';

// load helpers
import ApiConfigHelper from '../../ApiConfig/helpers/ApiConfig.helpers';
import AuthHelper from '../../Auth/helpers/Auth.helpers';
import SettingsHelper from '../../Settings/helpers/Settings.helpers';
import ToastHelper from '../helpers/Toast.helpers';

// load reducers
import reducerAuth from '../../Auth/reducers/Auth.reducers';
import reducerSettings from '../../Settings/reducers/Settings.reducers';

/**
 * combine reducers
 * @param  {...any} reducers
 */
const reduceReducers = (...reducers) => (prevState, value, ...args) => reducers.reduce(
  (newState, reducer) => reducer(newState, value, ...args),
  prevState
);

/**
 * component
 */
export default function AppMain() {
  // compose the reducers
  const [state, dispatch] = useReducer(
    reduceReducers(
      reducerAuth,
      reducerSettings
    ),
    {
      auth: null,
      settings: null
    }
  );
  const { settings } = state;
  const { auth } = state;

  // effects
  useEffect(() => {
    if (settings != null && auth == null) AuthHelper.loadAuth(dispatch);
  }, [settings, auth]);

  // effects
  useEffect(() => {
    if (settings == null) {
      if (Config.apiuri != null) {
        SettingsHelper.loadSettings(dispatch)
          .then((getsettings) => {
            if (!getsettings.apiuriloaded) {
              ApiConfigHelper.setApiuri(dispatch, Config.apiuri)
                .catch((err) => {
                  ToastHelper.showAlertMessage(`${I18n.t('appmain.errorloadingsettings')} ${err}`);
                });
            }
          })
          .catch(() => null);
      } else { SettingsHelper.loadSettings(dispatch).catch(() => null); }
    }
  }, [settings]);

  // splash screen
  if (
    (
      settings == null
    )
    || (
      settings != null && settings.needslogin && (auth == null)
    )
    || (
      settings != null && !settings.apiuriloaded && settings.apiuri !== null
    )) {
    return (
      <View style={{ flex: 1 }}>
        <AppSplash />
        <Toast ref={(ref) => Toast.setRef(ref)} />
      </View>
    );
  }

  // main return
  return (
    <MainContext.Provider value={{ state, dispatch }}>
      <SafeAreaView style={{ flex: 1 }}>
        <AppNavigator />
      </SafeAreaView>
      <Toast ref={(ref) => Toast.setRef(ref)} />
    </MainContext.Provider>
  );
}
