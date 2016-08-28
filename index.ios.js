/**
 * @providesModule SafariViewManager
 */
'use strict';
import {
  NativeModules,
  NativeEventEmitter,
  processColor
} from 'react-native';
const NativeSafariViewManager = NativeModules.SafariViewManager;
const moduleEventEmitter = new NativeEventEmitter(NativeSafariViewManager);

/**
 * High-level docs for the SafariViewManager iOS API can be written here.
 */

export default {
  show(options, resolveOn = 'onShow') {
    if (options && options.tintColor) {
      options.tintColor = processColor(options.tintColor);
    }

    return new Promise((resolve, reject) => {
      this.once(resolveOn, resolve);
      NativeSafariViewManager.show(options, (error) => {
        if (error) {
          return reject(error);
        }
      });
    });
  },

  dismiss(data) {
    if (data !== undefined) {
      return NativeSafariViewManager.dismissWithData(data);
    }
    NativeSafariViewManager.dismiss();
  },

  isAvailable() {
    return new Promise((resolve, reject) => {
      NativeSafariViewManager.isAvailable((error) => {
        if (error) {
          return reject(error);
        }

        resolve(true);
      });
    });
  },

  addEventListener(event, listener) {
    return moduleEventEmitter.addListener(event, listener);
  },

  removeEventListener(event, listener) {
    moduleEventEmitter.removeListener(event, listener);
  },

  once(event, callback) {
    const listener = (payload) => {
      callback(payload);
      this.removeEventListener(event, listener);
    };
    this.addEventListener(event, listener);
  }
};
