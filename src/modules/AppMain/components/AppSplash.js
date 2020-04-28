// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import React, { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  StatusBar,
  StyleSheet,
  View,
  Text
} from 'react-native';

// load settings
import theme from '../../../themes/themes.default';
import I18n from '../../../locales/locales';
import Config from '../../../config/config';

/**
 * component
 */
export default function AppSplash() {
  // states
  const [loadingtimethresholdgone, setLoadingtimethresholdgone] = useState(false);

  // effects
  useEffect(() => {
    let mounted = true;

    // set loading time threshold
    setTimeout(() => {
      if (mounted) {
        setLoadingtimethresholdgone(true);
      }
    },
    Config.loadingTimeThreshold);

    // unmount component
    return () => {
      mounted = false;
    };
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.loading}>
        { loadingtimethresholdgone
          ? I18n.t('appsplash.loading')
          : ' ' }
      </Text>
      <ActivityIndicator />
      <StatusBar barStyle="default" />
    </View>
  );
}

/**
 * styles
 */
const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: theme.COLOR_SPLASHBACKGROUND
  },
  loading: {
    textAlign: 'center',
    paddingBottom: 5
  }
});
