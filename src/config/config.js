// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

// load settings
import { version } from '../../package.json';

// default config values
let apiuri = null;
let apiconfig = null;
let getcontactsrefreshseconds = 180;
const showRemoteServerResponseError = false;
const refreshLoginTokenAfterLogin = true;
const theme = 'default';
const fetchTimeout = 20000;
const loadingTimeThreshold = 3000;

// load config
// for custom config make a config.{process.env.NODE_ENV}.js file starting
// from the config.template._js file
const configdevelopment = require('./config.development.js');
const configproduction = require('./config.production.js');

// select the proper config and override sections
let config = null;
if (process.env.NODE_ENV === 'development') config = configdevelopment;
if (process.env.NODE_ENV === 'production') config = configproduction;
if (config != null) {
  apiuri = config.apiuri;
  apiconfig = config.apiconfig;
  getcontactsrefreshseconds = config.getcontactsrefreshseconds;
}

/**
 * export the config
 */
module.exports = {
  version,
  apiuri,
  apiconfig,
  getcontactsrefreshseconds,
  refreshLoginTokenAfterLogin,
  showRemoteServerResponseError,
  theme,
  fetchTimeout,
  loadingTimeThreshold
};
