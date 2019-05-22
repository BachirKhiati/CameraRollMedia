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
    public func getAlbums(_ resolve: @escaping RCTPromiseResolveBlock,
                          rejecter reject: @escaping RCTPromiseRejectBlock ) -> Void {
        let subtypes: [PHAssetCollectionSubtype] = [
            .smartAlbumFavorites,
            .smartAlbumPanoramas,
            .smartAlbumScreenshots,
            .smartAlbumSelfPortraits,
            //                .smartAlbumVideos,
            .smartAlbumRecentlyAdded,
            .smartAlbumSelfPortraits,
            .smartAlbumUserLibrary,
            //                .smartAlbumSlomoVideos,
            .smartAlbumBursts
        ]
        var AlbumsArray : [Dictionary<String,Any>] = []
        var AlbumsTitlesArray : [String] = []
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
                        let title = album.localizedTitle as! String
                        let count =  album.estimatedAssetCount as Int
                        let type = album.assetCollectionType.rawValue as Int
                        let data: [String: Any] = [
                            "title": title,
                            "count": count,
                            "subType": type,
                            "smartAlbum": "false",
                            "assetType": "Photos"
                            ]
                        if (album.localizedTitle == "Camera Roll" || album.localizedTitle == "All Photos") {
                            AlbumsArray.insert(data, at: 0)
                            AlbumsTitlesArray.insert("\(title) (\(String(count)))"  , at: 0)
                        } else {
                            AlbumsArray.append(data)
                            AlbumsTitlesArray.append("\(title) (\(String(count)))")
                        }
                    }
                }
            }
            // smart album fetchng
            for subtype in subtypes {
                if let collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: fetchOptions).firstObject, collection.photosCount > 0 {
                    let title = collection.localizedTitle
                    let count =  collection.photosCount as Int
                    let type = subtype.rawValue as Int
                    let data: [String: Any] = [
                        "title": title as! String,
                        "count": count,
                        "subType": type,
                        "smartAlbum": "true",
                        "assetType": "Photos"
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
        var AlbumName : String = "";
        var AlbumSubType : Int = 209;
        var AlbumType : Bool = false;
        var AssetType : String;
        var LastAssetUnix : Int = Int(Date().timeIntervalSince1970);
        var Count : Int = 120;
        var NoMore = false;
        if let title = params["title"] as? String {
            AlbumName = title
        }
        /////////##########################
        if let subType = params["subType"] as? Int  {
            AlbumSubType = subType
        }
        /////////##########################
        if let typeSmart = params["smartAlbum"] as? String  {
            AlbumType = (typeSmart == "true" ? true : false)
        }else {
            AlbumType = true;
        }
        /////////##########################
        if let assetType = params["assetType"] as?  String  {
            AssetType = assetType
        }else {
            AssetType = "Photos"
        }
        /////////##########################
        if let after = params["after"]  as?  Int {
            LastAssetUnix = after
        }
        /////////##########################
        if let count = params["count"]  as? Int  {
            Count = count
        } else {
            Count = 120
        }
        /////////##########################
        var AssetsArray : [Dictionary<String,Any>] = []
        let fetchOptions = PHFetchOptions()
        
        
        if(!AlbumType && !AlbumName.isEmpty){
            fetchOptions.predicate = NSPredicate(format: "title = %@", AlbumName)
        }
        //        print( AlbumName)
        //      print( AlbumSubType)
        //      print( AlbumType)
        //      print( AssetType )
        //      print( LastAssetUnix )
        //     print( Count)
        //      print( NoMore )
        //        print( fetchOptions )
        
        DispatchQueue.global(qos: .background).async() {
            let fetchResult: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: (AlbumType ? .smartAlbum : .album), subtype: PHAssetCollectionSubtype(rawValue: AlbumSubType ?? 209 ) ?? .any, options:  fetchOptions)
            fetchResult.enumerateObjects({ (object: AnyObject!, count: Int, stop: UnsafeMutablePointer) in
                if object is PHAssetCollection {
                    let obj:PHAssetCollection = object as! PHAssetCollection
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    fetchOptions.fetchLimit = Count
                    if(LastAssetUnix > 0) {
                        let startDate = Date(timeIntervalSince1970: Double(LastAssetUnix))
                        if(AssetType == "Videos"){
                            fetchOptions.predicate = NSPredicate(format: "(mediaType == %d) AND (creationDate < %@)", PHAssetMediaType.video.rawValue, startDate as NSDate)
                        } else {
                            fetchOptions.predicate = NSPredicate(format: "(mediaType == %d) AND (creationDate < %@)", PHAssetMediaType.image.rawValue, startDate as NSDate)
                        }
                    } else {
                        if(AssetType == "Videos"){
                            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
                        } else {
                            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                        }
                    }
                    
                    
                    AssetsArray = []
                    let assets = PHAsset.fetchAssets(in: obj, options: fetchOptions)
                    if(assets.count == 0) {
                        NoMore = true
                    } else {
                        NoMore = false
                        assets.enumerateObjects{(obj: AnyObject!,count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                            if obj is PHAsset{
                                var originalName = String()
                                var mimeType = String()
                                var assetLocalIdentifier = String()
                                let asset = obj as! PHAsset
                                let width = Int(asset.pixelWidth)
                                let height = Int(asset.pixelHeight)
                                let created =  Double(asset.creationDate!.timeIntervalSince1970)
                                let duration =  Double(asset.duration)
                                let latitude = asset.location?.coordinate.latitude
                                let longitude = asset.location?.coordinate.longitude
                                originalName = PHAssetResource.assetResources(for: asset).first?.originalFilename ?? ""
                                assetLocalIdentifier =  PHAssetResource.assetResources(for: asset).first?.assetLocalIdentifier ?? ""
                                mimeType =  String(originalName.suffix(3)).uppercased()
                                let fullLink = asset.localIdentifier.components(separatedBy: "/").first!
                                let uri = "assets-library://asset/asset.\(mimeType)?id=\(String(describing: fullLink))&ext=\(mimeType)"
                                
                                let newAlbum : [String: Any] =
                                    [
                                        "uri": uri,
                                        "width": width,
                                        "height": height,
                                        "created":  created,
                                        "duration":  duration,
                                        "location": [ "latitude": latitude,
                                                      "longitude": longitude
                                        ],
                                        "originalName": originalName,
                                        "mimeType": mimeType,
                                        "assetLocalIdentifier": assetLocalIdentifier
                                ]
                                AssetsArray.append(newAlbum)
                                if((assets.count - 1) == count && assets.count > 0 ){
                                    LastAssetUnix = Int(asset.creationDate?.timeIntervalSince1970 ?? asset.modificationDate?.timeIntervalSince1970 ?? 0)
                                }
                            }
                            
                        }
                        
                        if(assets.count < Count ){
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
    
}
