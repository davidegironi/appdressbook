// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

// load settings
import I18n from '../../../locales/locales';

// load helpers
import StorageHelper from '../../AppMain/helpers/Storage.helpers';
import SettingsHelper from '../../Settings/helpers/Settings.helpers';

module.exports = {

  /**
   * set a new apiuri
   * @param {function} dispatch
   * @param {string} uri
   */
  async setApiuri(dispatch, apiuri) {
    if (apiuri != null) {
      // save settings
      return SettingsHelper.getSettingsRemote(apiuri)
        .then((settings) => StorageHelper.clear()
          .then(() => SettingsHelper.setSettings(dispatch, settings)
            .then(() => {
              dispatch({ type: 'ACTION_REFRESHAUTH', auth: null });
            })
            .catch((err) => {
              throw err;
            }))
          .catch(() => {
            throw I18n.t('apiconfig.cleansettingserrors');
          }))
        .catch((err) => {
          throw err;
        });
    }
    return StorageHelper.clear()
      .then(() => {
        dispatch({ type: 'ACTION_REFRESHSETTINGS', settings: null });
        dispatch({ type: 'ACTION_REFRESHAUTH', auth: null });
        return null;
      })
      .catch(() => {
        throw I18n.t('apiconfig.cleansettingserrors');
      });
  }

};
