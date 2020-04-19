// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import axios from 'axios';

// load settings
import I18n from '../../../locales/locales';
import Config from '../../../config/config';

// load helpers
import StorageHelper from '../../AppMain/helpers/Storage.helpers';

module.exports = {

  /**
   * clean all the contacts
   */
  async cleanContactsStorage() {
    try {
      await StorageHelper.removeItem('@store:contacts');
      await StorageHelper.removeItem('@store:latestcontacts');
    } catch {
      //
    }
  },

  /**
   * save all contacts to storage
   * @param {object} contacts
   */
  async setContactsStorage(contacts) {
    try {
      await StorageHelper.setItem('@store:contacts', JSON.stringify(contacts));
    } catch {
      //
    }
  },

  /**
   * get all contacts from storage
   */
  async getContactsStorage() {
    try {
      const value = await StorageHelper.getItem('@store:contacts');
      if (value != null) return JSON.parse(value);
      return null;
    } catch {
      return null;
    }
  },

  /**
   * add a contact to latest contacts storage
   * @param {object} contact
   */
  async addLatestcontactStorage(contact) {
    try {
      let latestcontacts = await module.exports.getLatestcontactsStorage();
      if (latestcontacts == null) latestcontacts = [];
      const currentcontact = latestcontacts
        .find((r) => r.latestcontact.id === contact.latestcontact.id);
      if (currentcontact != null) currentcontact.datetime = contact.datetime;
      else latestcontacts.push(contact);
      latestcontacts.sort((a, b) => {
        if (a.datetime < b.datetime) return 1;
        if (b.datetime < a.datetime) return -1;
        return 0;
      });
      latestcontacts = latestcontacts.slice(0, contact.latestcontactsmaxitems);
      await StorageHelper.setItem('@store:latestcontacts', JSON.stringify(latestcontacts));
      const latestcontactsret = latestcontacts.map((latestcontact) => latestcontact.latestcontact);
      return latestcontactsret;
    } catch {
      return null;
    }
  },

  /**
   * add contacts to latest contacts storage
   * @param {object} contacts
   */
  async addLatestcontactsStorage(contacts, latestcontactsmaxitems) {
    try {
      if (contacts == null) { await StorageHelper.removeItem('@store:latestcontacts'); } else {
        const latestcontacts = contacts.slice(0, latestcontactsmaxitems);
        await StorageHelper.setItem('@store:latestcontacts', JSON.stringify(latestcontacts));
      }
      return contacts;
    } catch {
      return null;
    }
  },

  /**
   * get latest contacts from storage
   */
  async getLatestcontactsStorage() {
    try {
      const value = await StorageHelper.getItem('@store:latestcontacts');
      if (value != null) return JSON.parse(value);
      return null;
    } catch {
      return null;
    }
  },

  /**
   * refresh latest contacts based to contacts list
   * @param {object} contacts
   * @param {integer} latestcontactsmaxitems
   */
  async refreshLatestcontacts(contacts, latestcontactsmaxitems) {
    // post check latestcontacts
    return module.exports.getLatestcontactsStorage()
      .then((latestcontactsget) => {
        if (latestcontactsget != null && latestcontactsget.length > 0) {
          const newlatestcontacts = [];
          let changed = false;
          latestcontactsget.forEach((latestcontact) => {
            const contactfound = contacts
              .find((r) => r.id === latestcontact.latestcontact.id);
            if (contactfound != null) {
              if (JSON.stringify(contactfound) !== JSON.stringify(latestcontact.latestcontact)) {
                changed = true;
              }
              const contact = {
                latestcontact: contactfound,
                datetime: latestcontact.datetime,
                latestcontactsmaxitems: latestcontact.latestcontactsmaxitems
              };
              newlatestcontacts.push(contact);
            } else changed = true;
          });
          return module.exports.addLatestcontactsStorage(
            newlatestcontacts, latestcontactsmaxitems
          )
            .then((latestcontactsadded) => {
              const latestcontactsret = latestcontactsadded
                .map((latestcontact) => latestcontact.latestcontact);
              return {
                latestcontacts: latestcontactsret,
                changed
              };
            });
        }
        return {
          latestcontacts: null,
          changed: true
        };
      });
  },

  /**
   * upsert contacts from api to storage
   * @param {string} apiuri
   * @param {string} authtoken
   */
  async upsertContacts(isonline, apiuri, authtoken) {
    // capitalize first letter
    const capitalizeFirstLetter = (string) => (
      string != null
        ? string.toLowerCase().charAt(0).toUpperCase() + string.toLowerCase().slice(1)
        : null);
    // get from storage
    return module.exports.getContactsStorage()
      .then((contacts) => {
        if (isonline) {
          const timeout = (contacts != null ? 3000 : 0);
          const hash = (contacts != null ? contacts.hash : null);
          // get hash for the contacts
          return axios.get(`${apiuri}appdressbookcontacts`,
            {
              headers: {
                'Content-Type': 'application/json',
                AuthToken: authtoken
              },
              params: {
                mode: 'h'
              }
            },
            {
              timeout
            })
            .then((getappdressbookcontactshash) => {
              // check response hash
              const responsehash = (
                getappdressbookcontactshash != null && getappdressbookcontactshash.data != null
                  ? getappdressbookcontactshash.data.hash
                  : null);
              if (responsehash !== hash) {
                // get all the contacts
                return axios.get(`${apiuri}appdressbookcontacts`,
                  {
                    headers: {
                      'Content-Type': 'application/json',
                      AuthToken: authtoken
                    },
                    params: {
                      mode: 'l'
                    }
                  },
                  {
                    timeout
                  })
                  .then((getappdressbookcontacts) => {
                    const responsedata = (
                      getappdressbookcontacts != null && getappdressbookcontacts.data != null
                        ? getappdressbookcontacts.data
                        : null);
                    if (responsedata != null) {
                      try {
                        const contactsret = [];
                        if (responsedata != null) {
                          let personcount = 0;
                          responsedata.persons.forEach((person) => {
                            personcount += 1;
                            // get id
                            const personid = person.id != null
                              ? person.id
                              : personcount;
                            // get code
                            const code = person.code != null
                              ? person.code
                              : '_';
                            // get name
                            const firstname = capitalizeFirstLetter(person.firstname != null && person.firstname.length > 0 ? person.firstname : '_');
                            const lastname = capitalizeFirstLetter(person.lastname != null && person.lastname.length > 0 ? person.lastname : '_');
                            const name = `${firstname} ${lastname}`;
                            const namepointed = `${firstname[0]}. ${lastname}`;
                            // get shortname
                            const shortname = `${firstname[0]} ${lastname[0]}`.toUpperCase();
                            const shortnamecolor = module.exports.hashColor(shortname, false);
                            const shortnamecolorinvert = module.exports.invertColor(
                              shortnamecolor, true
                            );
                            // get color
                            const color = module.exports.hashColor(name, false);
                            const colorinvert = module.exports.invertColor(color, true);
                            const coloropacity = module.exports.opacityColor(color, 0.2);
                            // get location
                            const locationcode = person.locationcode != null
                              ? person.locationcode.toUpperCase()
                              : null;
                            let locationname = null;
                            let locationcolor = null;
                            const locationsel = responsedata.locationtypes != null
                              ? responsedata.locationtypes
                                .find((r) => r.code.toUpperCase() === locationcode)
                              : null;
                            if (locationsel != null) {
                              locationname = capitalizeFirstLetter(locationsel.name);
                              locationcolor = locationsel.color;
                            }
                            if (locationcolor == null) {
                              locationcolor = module.exports.hashColor(locationcode != null ? locationcode : '', false);
                            }
                            const locationcolorinvert = module.exports.invertColor(
                              locationcolor, true
                            );
                            // get role
                            const rolecode = person.rolecode != null
                              ? person.rolecode.toUpperCase()
                              : null;
                            let rolecolor = null;
                            let roleinfo = capitalizeFirstLetter(person.roleinfo);
                            const rolesel = responsedata.roletypes != null
                              ? responsedata.roletypes
                                .find((r) => r.code.toUpperCase() === rolecode)
                              : null;
                            if (rolesel != null) {
                              if (roleinfo == null) roleinfo = capitalizeFirstLetter(rolesel.name);
                            }
                            if (rolecolor == null) {
                              rolecolor = module.exports.hashColor(rolecode != null ? rolecode : '', false);
                            }
                            const rolecolorinvert = module.exports.invertColor(rolecolor, true);
                            // get company
                            const companycode = person.companycode != null
                              ? person.companycode.toUpperCase()
                              : null;
                            let companyname = null;
                            let companycolor = null;
                            const companysel = responsedata.companytypes != null
                              ? responsedata.companytypes
                                .find((r) => r.code.toUpperCase() === companycode)
                              : null;
                            if (companysel != null) {
                              companyname = capitalizeFirstLetter(companysel.name);
                              companycolor = companysel.color;
                            }
                            if (companycolor == null) {
                              companycolor = module.exports.hashColor(companycode != null ? companycode : '', false);
                            }
                            const companycolorinvert = module.exports
                              .invertColor(companycolor, true);
                            // build search string and prevent double items
                            const searchstrbase = (`${name} ${locationcode} [${personid}]`).replace(/\s/g, '');
                            let searchstr = searchstrbase;
                            const searchstrnum = contactsret
                              .filter((r) => r.searchstrbase === searchstrbase).length;
                            if (searchstrnum > 0) searchstr += `-${searchstrnum.toString()}`;
                            // get contacts
                            const personcontacts = [];
                            person.contacts.forEach((personcontact) => {
                              const contactcode = personcontact.code != null
                                ? personcontact.code.toUpperCase()
                                : null;
                              const contactvalue = personcontact.value;
                              let contactname = null;
                              let contacttype = null;
                              let contacticon = null;
                              const contactsel = responsedata.contacttypes != null
                                ? responsedata.contacttypes
                                  .find((r) => r.code.toUpperCase() === contactcode)
                                : null;
                              if (contactsel != null) {
                                contactname = capitalizeFirstLetter(contactsel.name);
                                contacttype = contactsel.type.toLowerCase();
                                if (contacttype === 'phone') contacticon = 'phone';
                                else if (contacttype === 'email') contacticon = 'email';
                              }
                              personcontacts.push({
                                contactcode,
                                contactvalue,
                                contactname,
                                contacttype,
                                contacticon
                              });
                            });
                            // add person
                            contactsret.push({
                              id: personid,
                              code,
                              name,
                              namepointed,
                              searchstr,
                              firstname,
                              lastname,
                              shortname,
                              shortnamecolor,
                              shortnamecolorinvert,
                              color,
                              coloropacity,
                              colorinvert,
                              locationcode,
                              locationcolor,
                              locationcolorinvert,
                              locationname,
                              rolecode,
                              rolecolor,
                              rolecolorinvert,
                              roleinfo,
                              companycode,
                              companycolor,
                              companycolorinvert,
                              companyname,
                              contacts: personcontacts
                            });
                          });
                        }
                        const newcontacts = {
                          contacts: contactsret,
                          hash: responsedata.hash
                        };
                        // save contacts
                        return module.exports.setContactsStorage(newcontacts)
                          .then(() => ({
                            errors: null,
                            contacts: contactsret
                          }))
                          .catch(() => ({
                            errors: null,
                            contacts
                          }));
                      } catch (err) {
                        return ({
                          errors: I18n.t('addressbook.errorinvaliddata'),
                          contacts: null
                        });
                      }
                    } else {
                      return ({
                        errors: I18n.t('addressbook.erroremptyresponse'),
                        contacts: null
                      });
                    }
                  })
                  .catch((err) => {
                    let errors = null;
                    if (err.response == null) errors = [I18n.t('addressbook.errorremoteunknown')];
                    else if (err.response.data.errors != null) errors = err.response.data.errors;
                    else errors = [I18n.t('addressbook.errorunknown')];
                    return ({
                      errors,
                      contacts: null
                    });
                  });
              }
              return ({
                errors: null,
                contacts: contacts != null ? contacts.contacts : []
              });
            })
            .catch((err) => {
              let errors = null;
              if (err.response == null)errors = [I18n.t('addressbook.errorremoteunknown')];
              else if (err.response.data.errors != null) errors = err.response.data.errors;
              else errors = [I18n.t('addressbook.errorunknown')];
              if (!Config.showRemoteServerResponseError) errors = null;
              return ({
                errors,
                contacts: contacts != null ? contacts.contacts : []
              });
            });
        }
        return ({
          errors: null,
          contacts: contacts != null ? contacts.contacts : []
        });
      })
      .catch((err) => ({
        errors: `${I18n.t('addressbook.errorloadingcontacts')} ${err}`,
        contacts: null
      }));
  },

  /**
   * make a random color from string
   * @param {string} str
   * @param {boolean} darkcolor
   */
  hashColor(str, darkcolor) {
    let s = str;
    if (s == null || s.length === 0) s = ' ';
    let hash = 0;
    for (let i = 0; i < s.length; i += 1) {
      // eslint-disable-next-line no-bitwise
      hash = s.charCodeAt(i) + ((hash << 5) - hash);
    }
    // eslint-disable-next-line no-bitwise
    const c = (darkcolor
      // eslint-disable-next-line no-bitwise
      ? `5${(hash & 0x00FFFFFF).toString(16).toUpperCase().slice(-5).toString()}`
      // eslint-disable-next-line no-bitwise
      : (hash & 0x00FFFFFF).toString(16).toUpperCase());
    return `#${'00000'.substring(0, 6 - c.length)}${c}`;
  },

  /**
   * find the inversion color for an hex color
   * @param {string} hex
   * @param {boolena, blackandwhite
   */
  invertColor(hex, blackandwhite) {
    let h = hex;
    if (h.indexOf('#') === 0) h = h.slice(1);
    if (h.length === 3) h = h[0] + h[0] + h[1] + h[1] + h[2] + h[2];
    if (h.length !== 6) return h;
    let r = parseInt(h.slice(0, 2), 16);
    let g = parseInt(h.slice(2, 4), 16);
    let b = parseInt(h.slice(4, 6), 16);
    if (blackandwhite) {
      return (r * 0.299 + g * 0.587 + b * 0.114) > 186
        ? '#000000'
        : '#FFFFFF';
    }
    r = (255 - r).toString(16);
    g = (255 - g).toString(16);
    b = (255 - b).toString(16);
    return `#${(`0${r}`).slice(-2)}${(`0${g}`).slice(-2)}${(`0${b}`).slice(-2)}`;
  },

  /**
   * add opacity to color
   * @param {string} hex
   * @param {double} opacity
   */
  opacityColor(hex, opacity) {
    let h = hex;
    if (h.indexOf('#') === 0) h = h.slice(1);
    if (h.length === 3) h = h[0] + h[0] + h[1] + h[1] + h[2] + h[2];
    if (h.length !== 6) return h;
    if (opacity < 0 || opacity > 1) return h;
    const r = Math.floor(
      parseInt(h.slice(0, 2), 16) * opacity + 0xff * (1 - opacity)
    ).toString(16);
    const g = Math.floor(
      parseInt(h.slice(2, 4), 16) * opacity + 0xff * (1 - opacity)
    ).toString(16);
    const b = Math.floor(
      parseInt(h.slice(4, 6), 16) * opacity + 0xff * (1 - opacity)
    ).toString(16);
    return `#${(`0${r}`).slice(-2)}${(`0${g}`).slice(-2)}${(`0${b}`).slice(-2)}`;
  }
};
