// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import axios from 'axios';

// load settings
import I18n from '../../../locales/locales';
import Config from '../../../config/config';

// load helpers
import StorageHelper from '../../AppMain/helpers/Storage.helpers';
import AddressBookHelper from '../../AddressBook/helpers/AddressBook.helpers';

const jwtDecode = require('jwt-decode');

module.exports = {

  /**
   * load auth from storage and refresh store
   * @param {function} dispatch
   */
  async loadAuth(dispatch) {
    const authtoken = await module.exports.getAuthtokenStorage();
    const userinfo = await module.exports.getUserinfoStorage();
    const auth = {
      authtoken,
      userinfo
    };
    dispatch({ type: 'ACTION_REFRESHAUTH', auth });
  },

  /**
   * get user infor from storage
   */
  async getUserinfoStorage() {
    try {
      const value = await StorageHelper.getItem('@store:userinfo');
      return JSON.parse(value);
    } catch {
      return null;
    }
  },

  /**
   * set userinfo to storage
   * @param {object} userinfo
   */
  async setUserinfoStorage(userinfo) {
    try {
      await StorageHelper.setItem('@store:userinfo', userinfo);
    } catch {
      //
    }
  },

  /**
   * save auhtoken to storage
   * @param {string} authtoken
   */
  async setAuthtokenStorage(authtoken) {
    try {
      await StorageHelper.setItem('@store:authtoken', authtoken);
    } catch {
      //
    }
  },

  /**
   * get the authtoken from storage
   */
  async getAuthtokenStorage() {
    try {
      const value = await StorageHelper.getItem('@store:authtoken');
      return value;
    } catch {
      return null;
    }
  },

  /**
   * refresh the login token
   * @param {string} apiuri
   * @param {string} authtoken
   */
  async refreshLoginToken(apiuri, authtoken) {
    return axios.put(`${apiuri}appdressbookauth`,
      {
        expiresdays: null,
      },
      {
        headers: {
          'Content-Type': 'application/json',
          AuthToken: authtoken
        }
      },
      {
        timeout: Config.fetchTimeout
      })
      .then((response) => {
        if (response.data.token != null) {
          module.exports.setAuthtokenStorage(response.data.token);
        }
      })
      .catch();
  },

  /**
   * try to login
   * @param {function} dispatch
   * @param {string} apiuri
   * @param {string} username
   * @param {string} password
   */
  async login(dispatch, apiuri, username, password) {
    return axios.post(`${apiuri}appdressbookauth`,
      {
        username,
        password
      },
      {
        headers: {
          'Content-Type': 'application/json'
        }
      },
      {
        timeout: Config.fetchTimeout
      })
      .then((response) => {
        if (response.data.token != null) {
          const authtoken = response.data.token;
          const userinfo = {
            // eslint-disable-next-line no-underscore-dangle
            username: jwtDecode(authtoken)._username,
            // eslint-disable-next-line no-underscore-dangle
            displayname: jwtDecode(authtoken)._displayname
          };
          const newauth = {
            authtoken,
            userinfo
          };
          return module.exports.setAuthtokenStorage(authtoken)
            .then(() => {
              module.exports.setUserinfoStorage(JSON.stringify(userinfo))
                .then(() => {
                  dispatch({ type: 'ACTION_REFRESHAUTH', auth: newauth });
                })
                .catch(() => {
                  throw I18n.t('login.errorunknown');
                });
            })
            .catch(() => {
              throw I18n.t('login.errorunknown');
            });
        }
        throw I18n.t('login.errorunknown');
      })
      .catch((err) => {
        let messages = I18n.t('login.errorunknownorremote');
        if (err.response == null) messages = I18n.t('login.errorunknownorremote');
        else if (err.response.data.errors != null) messages = err.response.data.errors;
        throw messages;
      });
  },

  /**
   * perform logout
   */
  async logout(dispatch) {
    try {
      await StorageHelper.removeItem('@store:authtoken');
      await StorageHelper.removeItem('@store:userinfo');
      dispatch({ type: 'ACTION_REFRESHAUTH', auth: null });
      AddressBookHelper.cleanContactsStorage();
    } catch {
      //
    }
  }
};
