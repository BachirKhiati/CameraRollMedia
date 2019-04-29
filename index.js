/**
 * Copyright (c) Bachir Khiati.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @flow
 * @format
 */
'use strict';

import RNCameraRollMedia from './js/nativeInterface';
const invariant = require('fbjs/lib/invariant');

const ASSET_TYPE_OPTIONS = {
  Videos: 'Videos',
  Photos: 'Photos',
};


export type GetAssetsParams = {
  title?: string,
  type?: string,
  smart?: string,
  count?: number,
  after?: number,
  assetType?: $Keys<typeof ASSET_TYPE_OPTIONS>
};

export type PhotoIdentifier = {
    uri: string,
    thumbnail?: string,
    height: number,
    width: number,
    duration?: number,
    created: number,
    group_name?: string,
    latitude?: number,
    location?: {
      latitude?: number,
      longitude?: number
    }
};

export type PhotoIdentifiersPage = {
    assets: Array<PhotoIdentifier>,
    NoMore: boolean,
    start_cursor?: string,
    end_cursor?: string,
};

/**
 * `CameraRollMedia` provides access to the local camera roll or photo library.
 *
 * See https://facebook.github.io/react-native/docs/cameraroll.html
 */
class CameraRollMedia {
  static AssetTypeOptions = ASSET_TYPE_OPTIONS;

  static fetchAssets(params: GetAssetsParams): Promise<PhotoIdentifiersPage> {
    if (arguments.length > 1) {
      console.warn(
        'CameraRollMedia.fetchAssets(tag, success, error) is deprecated.  Use the returned Promise instead',
      );
      let successCallback = arguments[1];
      const errorCallback = arguments[2] || (() => {});
      RNCameraRollMedia.fetchAssets(params).then(successCallback, errorCallback);
    }
    return RNCameraRollMedia.fetchAssets(params);
  }
}

module.exports = CameraRollMedia;


