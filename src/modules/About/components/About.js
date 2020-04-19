// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import React from 'react';
import {
  StyleSheet,
  Text,
  View,
  Linking
} from 'react-native';

// load settings
import I18n from '../../../locales/locales';
import theme from '../../../themes/themes.default';
import Config from '../../../config/config';

/**
 * component
 */
export default function About() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>{I18n.t('about.title')}</Text>
      <Text style={styles.subtitle}>{I18n.t('about.subtitle')}</Text>
      <Text style={styles.version}>{`${I18n.t('about.version')} ${Config.version}`}</Text>
      <Text style={styles.text}>{I18n.t('about.text')}</Text>
      <Text style={styles.link} onPress={() => Linking.openURL(I18n.t('about.linklink'))}>{I18n.t('about.link')}</Text>
      <Text style={styles.copyright}>{I18n.t('about.copyright')}</Text>
      <Text style={styles.license}>
        {I18n.t('about.license')}
        <Text style={styles.licenselink} onPress={() => Linking.openURL(I18n.t('about.licenselinklink'))}>{I18n.t('about.licenselink')}</Text>
      </Text>
    </View>
  );
}

/**
 * styles
 */
const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: theme.COLOR_BACKGROUND
  },
  title: {
    fontSize: 25,
    fontWeight: 'bold',
    margin: 4,
    textAlign: 'center'
  },
  subtitle: {
    fontSize: 20,
    fontWeight: 'bold',
    fontStyle: 'italic',
    margin: 4,
    textAlign: 'center'
  },
  version: {
    fontSize: 14,
    fontStyle: 'italic',
    margin: 3,
    textAlign: 'center'
  },
  text: {
    fontSize: 14,
    margin: 3,
    marginTop: 18,
    textAlign: 'center'
  },
  link: {
    fontSize: 14,
    margin: 8,
    textAlign: 'center',
    textDecorationLine: 'underline'
  },
  copyright: {
    fontSize: 14,
    margin: 2,
    textAlign: 'center'
  },
  license: {
    fontSize: 14,
    margin: 2,
    textAlign: 'center'
  },
  licenselink: {
    fontSize: 14,
    margin: 2,
    textAlign: 'center',
    textDecorationLine: 'underline'
  }
});
