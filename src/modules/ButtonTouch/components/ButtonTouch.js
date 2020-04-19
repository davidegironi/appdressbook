// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

import React from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity
} from 'react-native';

// load settings
import theme from '../../../themes/themes.default';

/**
 * component
 * @param {object} props
 */
export default function ButtonTouch(props) {
  const { title } = props;
  const { onPress } = props;

  return (
    <TouchableOpacity
      style={styles.buttoncontainer}
      onPress={onPress}
    >
      <Text style={styles.buttontext}>
        {title}
      </Text>
    </TouchableOpacity>
  );
}

/**
 * styles
 */
const styles = StyleSheet.create({
  buttoncontainer: {
    backgroundColor: theme.COLOR_BUTTON,
    paddingVertical: 15,
    borderRadius: 8
  },
  buttontext: {
    color: theme.COLOR_BUTTONTEXT,
    textAlign: 'center',
    fontWeight: '700'
  }
});
