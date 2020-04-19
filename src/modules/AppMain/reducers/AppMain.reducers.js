// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

export default function reducer(state = {
  auth: null,
}, action) {
  switch (action.type) {
    case 'ACTION_REFRESHAUTH': {
      return {
        ...state,
        auth: action.auth,
      };
    }
    default:
      break;
  }

  return state;
}
