//
//  CameraRollMedia.swift
//  RNCameraRollMedia
//
//  Created by Bachir Khiati on 23/04/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation
import Photos


@available(iOS 9.0, *)
@objc(RNCameraRollMedia)
class RNCameraRollMedia: NSObject {
    
//    @objc(addEvent:location:date:)
//    func addEvent(name: String, location: String, date: NSNumber) -> Void {
//        print("hhhaaaa work")
//         print("hhhaaaa work")
//         print("hhhaaaa work")
//        // Date is ready to use!
//    }
//    @objc
//    func constantsToExport() -> [String: Any]! {
//        return ["someKey": "someValue"]
//    }
    
    @objc func getEvent(_ resolve: @escaping RCTPromiseResolveBlock,
                              rejecter reject: @escaping RCTPromiseRejectBlock ) -> Void {
        
        resolve("This method is no longer troublesome")    }
    
    
    /**
     Retrieve all albums from the Photos app.
     
     - parameter completion: Called in the background when all albums were retrieved.
     */

    
    @objc
    public func getAlbums(_ resolve: @escaping RCTPromiseResolveBlock,
                                 rejecter reject: @escaping RCTPromiseRejectBlock ) -> Void {
        let subtypes:[PHAssetCollectionSubtype] = [
            .smartAlbumFavorites,
            .smartAlbumPanoramas,
            .smartAlbumScreenshots,
            .smartAlbumSelfPortraits,
            .smartAlbumVideos,
            .smartAlbumRecentlyAdded,
            .smartAlbumSelfPortraits,
            .smartAlbumUserLibrary,.smartAlbumSlomoVideos,
            .smartAlbumBursts
        ]
        var smartAlbums: [PHAssetCollection] = []
        var resulyarray : [Dictionary<String,String>] = []
        DispatchQueue.global(qos: .background).async() {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
            
            
            
            
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
            print("2")
            // normal album fetchng
            [albums].forEach {
                $0.enumerateObjects { collection, index, stop in
                    guard let album = collection as? PHAssetCollection else { return }
                    print("normal album result")
                    print(album)
//                    result.insert(album)
                    if  album.estimatedAssetCount != NSNotFound {
                        let data: [String: String] = [
                            "titel": album.localizedTitle!,
                            "count": String(album.estimatedAssetCount),
                            "smart": "false",
                            ]
                        resulyarray.append(data)
                    }
                }
            }
            // smart album fetchng
            for subtype in subtypes {
                if let collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: fetchOptions).firstObject, collection.photosCount > 0 {
                    let data: [String: String] = [
                        "titel": collection.localizedTitle!,
                        "count": String(collection.photosCount),
                        "smart": "true",
                        ]
                    resulyarray.append(data)
                }
            }
            
            
            print(smartAlbums)
            print("4")
            resolve(resulyarray)
        }

        
        }
    
    
    
    
    }
