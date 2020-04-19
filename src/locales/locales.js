// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

// load locales
import langAppMain from '../modules/AppMain/locales/AppMain.locales';
import langApiConfig from '../modules/ApiConfig/locales/ApiConfig.locales';
import langSettings from '../modules/Settings/locales/Settings.locales';
import langAuth from '../modules/Auth/locales/Auth.locales';
import langAbout from '../modules/About/locales/About.locales';
import langPrivacy from '../modules/Privacy/locales/Privacy.locales';
import langTerms from '../modules/Terms/locales/Terms.locales';
import langAddressBook from '../modules/AddressBook/locales/AddressBook.locales';

// merge languages
const langen = {
  ...langAppMain.en,
  ...langApiConfig.en,
  ...langSettings.en,
  ...langAuth.en,
  ...langAbout.en,
  ...langPrivacy.en,
  ...langTerms.en,
  ...langAddressBook.en
};

/**
 * Get an object descending in array
 * @param {object} obj
 * @param {string} desc
 */
function getDescendantProp(obj, desc) {
  const arr = desc.split('.');
  let ret = obj;
  while (arr.length && ret) ret = ret[arr.shift()];
  return ret;
}

/**
 * export the default language function
 */
export default {
  t(keyname) {
    return getDescendantProp(langen, keyname) || keyname;
  }
};
