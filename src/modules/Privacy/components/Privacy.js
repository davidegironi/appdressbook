// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import React, { useContext } from 'react';
import {
  StyleSheet,
  Text,
  ScrollView,
  View
} from 'react-native';

// load contexts
import MainContext from '../../../contexts/MainContext';

// load settings
import theme from '../../../themes/themes.default';

/**
 * comopnent
 */
export default function Privacy() {
  const { state } = useContext(MainContext);
  const { settings } = state;

  return (
    <ScrollView style={styles.scrollcontainer}>
      <View style={styles.container}>
        <Text style={styles.content}>
          {settings.privacy}
        </Text>
      </View>
    </ScrollView>
  );
}

/**
 * styles
 */
const styles = StyleSheet.create({
  scrollcontainer: {
    flex: 1,
    backgroundColor: theme.COLOR_BACKGROUND
  },
  container: {
    flexGrow: 1,
    padding: 10
  },
  content: {
    fontSize: 12,
    textAlign: 'justify'
  },
});
