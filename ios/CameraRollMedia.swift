//
//  CameraRollMedia.swift
//  RNCameraRollMedia
//
//  Created by Bachir Khiati on 23/04/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation
import Photos


@objc(RNCameraRollMedia)
class RNCameraRollMedia: NSObject {
    

    
    @objc func getEvent(_ resolve: @escaping RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock ) -> Void {
        
        resolve("This method is no longer troublesome")    }
    
    
    /**
     Retrieve all albums from the Photos app.
     
     - parameter completion: Called in the background when all albums were retrieved.
     */
    
    enum PHAssetMediaTypeEnum: String
    {
        case photos = "one"
        case videos = "two"
    }
    
    
    
    @objc
    public func getAlbums(_ assetType: String, resolve: @escaping RCTPromiseResolveBlock,
                          rejecter reject: @escaping RCTPromiseRejectBlock ) -> Void {
        var subtypes: [PHAssetCollectionSubtype];
        if #available(iOS 9.0, *) {
            subtypes = [
                .smartAlbumFavorites,
                .smartAlbumPanoramas,
                .smartAlbumScreenshots,
                .smartAlbumSelfPortraits,
              .smartAlbumVideos,
                .smartAlbumRecentlyAdded,
                .smartAlbumSelfPortraits,
                .smartAlbumUserLibrary,
//                .smartAlbumSlomoVideos,
                .smartAlbumBursts
            ]
        } else {
            subtypes = [
                .smartAlbumFavorites,
                .smartAlbumPanoramas,
              .smartAlbumVideos,
                .smartAlbumRecentlyAdded,
                .smartAlbumUserLibrary,
//                .smartAlbumSlomoVideos,
                .smartAlbumBursts
            ]
        }
//        print("assetType")
//        print(assetType)
        var AlbumsArray : [Dictionary<String,String>] = []
        var AlbumsTitlesArray : [String] = []
//        var MediaType = [PHAssetMediaType]()
        DispatchQueue.global(qos: .background).async() {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            //            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
            // normal album fetchng
            [albums].forEach {
                $0.enumerateObjects { collection, index, stop in
                    let album = collection
                    if  album.estimatedAssetCount != NSNotFound {
                        let data: [String: String] = [
                            "title": album.localizedTitle!,
                            "count": String(album.estimatedAssetCount),
                            "type": String(album.assetCollectionType.rawValue),
                            "smart": "false",
                            "assetType": assetType ,
                            ]
                        if (album.localizedTitle == "Camera Roll" || album.localizedTitle == "All Photos") {
                            AlbumsArray.insert(data, at: 0)
                            AlbumsTitlesArray.insert("\(album.localizedTitle!) (\(String(album.estimatedAssetCount)))"  , at: 0)
                        } else {
                            AlbumsArray.append(data)
                            AlbumsTitlesArray.append("\(album.localizedTitle!) (\(String(album.estimatedAssetCount)))")
                        }
                    }
                }
            }
            // smart album fetchng
            for subtype in subtypes {
                if let collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: fetchOptions).firstObject, collection.photosCount > 0 {
                    let data: [String: String] = [
                        "title": collection.localizedTitle!,
                        "count": String(collection.photosCount),
                        "type": String(subtype.rawValue),
                        "smart": "true",
                        "assetType": assetType
                        ]
                    if (collection.localizedTitle == "Camera Roll" || collection.localizedTitle == "All Photos") {
                        AlbumsArray.insert(data, at: 0)
                        AlbumsTitlesArray.insert("\(collection.localizedTitle!) (\(String(collection.photosCount)))"  , at: 0)
                    } else {
                        AlbumsArray.append(data)
                        AlbumsTitlesArray.append("\(collection.localizedTitle!) (\(String(collection.photosCount)))" )
                    }
                }
            }
            resolve([AlbumsArray, AlbumsTitlesArray])
        }
    }
    
    
    @objc
    public func fetchAssets(_ params: NSDictionary, resolve: @escaping RCTPromiseResolveBlock,
                                 rejecter reject: @escaping RCTPromiseRejectBlock ) -> Void {
        print("fetchAlbumPhotos")
        print(params)
        var NoMore = false;
        var Count = "60";
        var LastAssetUnix = Double();
        guard let AlbumName = params["title"] as? String else {return}
        guard let AlbumSubType = params["type"] as? String else {return}
        let AlbumType = ((params["smart"] as? String == "true") ? true : false)
        guard let assetType = params["assetType"] as? String else {return}
        if params["after"] != nil  {
            LastAssetUnix = (params["after"] as?  Double)!
        }
        if params["count"] != nil  {
            Count = params["after"] as? String ?? "60"
        }
        var AssetsArray : [Dictionary<String,Any>] = []
        let fetchOptions = PHFetchOptions()
        if(!AlbumType){
            fetchOptions.predicate = NSPredicate(format: "title = %@", AlbumName)
        }
        DispatchQueue.global(qos: .background).async() {
            let fetchResult: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: (AlbumType ? .smartAlbum : .album), subtype: PHAssetCollectionSubtype(rawValue: Int(AlbumSubType) ?? 209) ?? .any, options:  fetchOptions)
            print(1)
//            let start = DispatchTime.now()
            fetchResult.enumerateObjects({ (object: AnyObject!, count: Int, stop: UnsafeMutablePointer) in
                if object is PHAssetCollection {
                    let obj:PHAssetCollection = object as! PHAssetCollection
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    if #available(iOS 9.0, *) {
                        fetchOptions.fetchLimit = Int(Count) ?? 60
                    } else {
                        // Fallback on earlier version
                
                    }
                    if(LastAssetUnix > 0) {
                        print("filtred by date")
                        print(LastAssetUnix)
                        //Date Formatter
                        let startDate = Date(timeIntervalSince1970: LastAssetUnix)
                        print("filtred by date")
                        print(startDate)
                        if(assetType == "videos"){
                             fetchOptions.predicate = NSPredicate(format: "(mediaType == %d) AND (creationDate < %@)", PHAssetMediaType.video.rawValue, startDate as NSDate)
                        } else {
                             fetchOptions.predicate = NSPredicate(format: "(mediaType == %d) AND (creationDate < %@)", PHAssetMediaType.image.rawValue, startDate as NSDate)
                        }
                    } else {
                        print("no filter by date")
                        if(assetType == "videos"){
                            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
                        } else {
                            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                        }
                    }
                    
                   
                   AssetsArray = []
                    let assets = PHAsset.fetchAssets(in: obj, options: fetchOptions)
                    print("assets")
                    print(assets.count)
                    if(assets.count == 0) {
                        NoMore = true
                    } else {
                        NoMore = false
                        assets.enumerateObjects{(object: AnyObject!,count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                            if object is PHAsset{
                                let asset = object as! PHAsset
                                let uri = "ph://\(asset.localIdentifier)"
                                let width = String(asset.pixelWidth)
                                let height = String(asset.pixelHeight)
                                let created =  String(asset.creationDate!.timeIntervalSince1970)
                                let duration =  String(asset.duration)
                                let latitude = asset.location?.coordinate.latitude
                                let longitude = asset.location?.coordinate.longitude
                                let newAlbum : [String: Any] =
                                    [
                                        "uri": uri,
                                        "width": width,
                                        "height": height,
                                        "created":  created,
                                        "duration":  duration,
                                        "location": [ "latitude": latitude,
                                                      "longitude": longitude
                                                    ]
                                        ]
                                AssetsArray.append(newAlbum)
                                if((assets.count - 1) == count && assets.count > 0 ){
                                    LastAssetUnix = (asset.creationDate?.timeIntervalSince1970 ?? 0.0)
                                }
                            }
                           
                        }
                        if(assets.count < Int(Count)! ){
                            NoMore = true
                        }
                    }
                  
                }
            })
            resolve(["NoMore": NoMore, "lastAssetUnix": LastAssetUnix,  "assets":AssetsArray])
        }
    }
    
    func getURL(ofPhotoWith mPhasset: PHAsset, completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        
        if mPhasset.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            mPhasset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
                if(contentEditingInput != nil){
                    completionHandler(contentEditingInput!.fullSizeImageURL!.absoluteURL)
                }
            })
        } else if mPhasset.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: { (asset, audioMix, info) in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl = urlAsset.url
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
        
    }
    
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if ((UIImage(named: urlString)) != nil) {
                print("Image existing")
                return true
            }
            else {
                print("Image is not existing")
                return false
            }
        }
        return false
    }
    
    
}




//
//                            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions)
//                            { result, info in
//                                // probably some of this code is unnecessary, too,
//                                // but I'm not sure what you're doing here so leaving it alone
////                                self._selectediImages.append(result)
//                                print("info")
//                                print(info)
//                                 print(result)
//                                print(result)
//                                var photoUrl : URL!
//                                photoUrl = info!["PHImageFileURLKey"] as? URL
//                                print(photoUrl)
//                                if photoUrl != nil {
//                                    let isInCould = info!["PHImageResultIsInCloudKey"] as? String
//                                    let mimeType = info!["PHImageFileUTIKey"] as? String
//                                    let orientation = info!["PHImageFileOrientationKey"] as? String
//                                    let newAlbum: [String: String] =
//                                        [
//                                            "uri": photoUrl.absoluteURL.absoluteString,
//                                            "width": String(asset.pixelWidth),
//                                            "height": String(asset.pixelHeight),
//                                            "created":  String(asset.creationDate!.timeIntervalSince1970),
//                                            "isInCould":  isInCould ?? "false",
//                                            "mime":  mimeType ?? "public.jpeg",
//                                            "orientation":  orientation ?? "0"
//                                    ]
//                                    AssetsArray.append(newAlbum)
//                                }
//                            }
//



//####################

//                            imageManager.requestImage(for: asset,
//                                                      targetSize: imageSize,
//                                                      contentMode: .aspectFill,
//                                                      options: options,
//                                                      resultHandler:
//                                {
//                                    (image, info) -> Void in
//                                    var photoUrl : URL!
//                                    photoUrl = info!["PHImageFileURLKey"] as? URL
//                                    if photoUrl != nil {
//                                        let isInCould = info!["PHImageResultIsInCloudKey"] as? String
//                                        let mimeType = info!["PHImageFileUTIKey"] as? String
//                                        let orientation = info!["PHImageFileOrientationKey"] as? String
//                                        let newAlbum: [String: String] =
//                                            [
//                                                "uri": photoUrl.absoluteURL.absoluteString,
//                                                "width": String(asset.pixelWidth),
//                                                "height": String(asset.pixelHeight),
//                                                "created":  String(asset.creationDate!.timeIntervalSince1970),
//                                                "isInCould":  isInCould ?? "false",
//                                                "mime":  mimeType ?? "public.jpeg",
//                                                "orientation":  orientation ?? "0"
//                                        ]
//                                        AssetsArray.append(newAlbum)
//                                    }
//                            })
