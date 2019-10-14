
import { NativeModules } from 'react-native'
const RNCameraRollMedia = NativeModules.RNCameraRollMedia

const ASSET_TYPE_OPTIONS = {
  Videos: 'Videos',
  Photos: 'Photos',
};


export type GetAssetsParams = {
  title?: string,
  subType?: string,
  smartAlbum?: string,
  count?: number,
  after?: number,
  assetType?: $Keys<typeof ASSET_TYPE_OPTIONS>
};
export type GetVideoParams = {
  type?: string
};

export type GetSizeParams = {
  uri?: string
};
export type PhotoSizeIdentifier = {
  width: number,
  height: number,
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
    firstAssetUnix?: string,
    lastAssetUnix?: string,
};

/**
 * `CameraRollMedia` provides access to the local camera roll or photo library.
 *
 * See https://facebook.github.io/react-native/docs/cameraroll.html
 */
class CameraRollMedia {
  static AssetTypeOptions = ASSET_TYPE_OPTIONS;


  static getAlbums (param: GetVideoParams): Promise<PhotoIdentifiersPage> {
    
    if (arguments.length > 1) {
      RNCameraRollMedia.getAlbums(param).then(successCallback, errorCallback);
    }
    return RNCameraRollMedia.getAlbums(param);
  }

  static fetchAssets(params: GetAssetsParams): Promise<PhotoIdentifiersPage> {
    if (arguments.length > 1) {
      RNCameraRollMedia.fetchAssets(params).then(successCallback, errorCallback);
    }
    return RNCameraRollMedia.fetchAssets(params);
  }

  static getSize(params: GetSizeParams): Promise<PhotoSizeIdentifier> {
    if (arguments.length > 1) {
      RNCameraRollMedia.getSize(params).then(successCallback, errorCallback);
    }
    return RNCameraRollMedia.getSize(params);
  }
  
}

module.exports = CameraRollMedia;


