// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import axios from 'axios';

// load settings
import Config from '../../../config/config';
import I18n from '../../../locales/locales';

// load helpers
import StorageHelper from '../../AppMain/helpers/Storage.helpers';

module.exports = {

  /**
   * load settings from storage and refresh store
   * @param {function} dispatch
   */
  async loadSettings(dispatch) {
    const settings = await module.exports.getSettingsStorage();
    if (settings == null) { throw I18n.t('settings.seterror'); }
    dispatch({ type: 'ACTION_REFRESHSETTINGS', settings });
    return settings;
  },

  /**
   * set settings to storage
   * @param {object} settings
   */
  async setSettingsStorage(settings) {
    try {
      await StorageHelper.setItem('@store:settings', JSON.stringify(settings));
    } catch {
      //
    }
  },

  /**
   * get settings from storage
   */
  async getSettingsStorage() {
    try {
      let settings = {
        apiuri: null,
        apiuriloaded: false,
        company: null,
        needslogin: true,
        terms: null,
        privacy: null,
        getcontactsrefresh: true,
        getcontactsrefreshwifi: true
      };
      // load settings from storage
      const value = await StorageHelper.getItem('@store:settings');
      if (value != null) settings = JSON.parse(value);
      if (Config.apiuri != null && settings.apiuri == null) {
        settings.apiuri = Config.apiuri;
      }
      return settings;
    } catch {
      return null;
    }
  },

  /**
   * set setttings
   * @param {function} dispatch
   * @param {object} settings
   */
  async setSettings(dispatch, settings) {
    return module.exports.setSettingsStorage(settings)
      .then(() => {
        dispatch({ type: 'ACTION_REFRESHSETTINGS', settings });
      })
      .catch(() => {
        throw I18n.t('settings.seterror');
      });
  },

  /**
   * get settings from remote
   * @param {string} uri
   */
  async getSettingsRemote(uri) {
    // request remote config
    return axios.get(`${uri}appdressbookconfig`,
      {
        headers: {
          'Content-Type': 'application/json'
        }
      },
      {
        timeout: Config.fetchTimeout
      })
      .then((response) => {
        if (response != null && response.status === 200 && response.data != null) {
          const newsettings = {
            apiuri: uri,
            apiuriloaded: true,
            companyname: response.data.companyname,
            needslogin: response.data.needslogin,
            terms: response.data.terms,
            privacy: response.data.privacy,
            getcontactsrefresh: true,
            getcontactsrefreshwifi: true
          };
            // override with apiconfig only if apiuri is configured
          if (Config.apiconfig != null && Config.apiuri != null) {
            if (Config.apiconfig.companyname != null) {
              newsettings.companyname = Config.apiconfig.companyname;
            }
            if (Config.apiconfig.needslogin != null) {
              newsettings.needslogin = Config.apiconfig.needslogin;
            }
            if (Config.apiconfig.terms != null) {
              newsettings.terms = Config.apiconfig.terms;
            }
            if (Config.apiconfig.privacy != null) {
              newsettings.privacy = Config.apiconfig.privacy;
            }
          }
          return newsettings;
        }
        throw I18n.t('settings.seterrorgetremote');
      })
      .catch((err) => {
        const error = `${I18n.t('settings.seterrorgetremote')} ${err}`;
        throw error;
      });
  },

};
