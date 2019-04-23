//
//  PHAssetCollection.swift
//  RNCameraRollMedia
//
//  Created by Bachir Khiati on 23/04/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation
import Photos

extension PHAssetCollection {
    var photosCount: Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d OR mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
}
