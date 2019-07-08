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
    public func getBase64(_ linkUrl: String, resolve: @escaping RCTPromiseResolveBlock,
                          rejecter reject: @escaping RCTPromiseRejectBlock ) -> Void {
        
        
      
        //Use image's path to create NSData
        let url:NSURL = NSURL(string : linkUrl)!
        //Now use image to create into NSData format
        let imageData : NSData = NSData.init(contentsOf: url as URL)!
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        resolve(strBase64)
    }
    
    @objc
    public func getAlbums(_ type: String, resolve: @escaping RCTPromiseResolveBlock,
                          rejecter reject: @escaping RCTPromiseRejectBlock ) -> Void {
        let status = PHPhotoLibrary.authorizationStatus()

        if (status == PHAuthorizationStatus.authorized) {
            resolve(getAlbumsFunc(type: type));
        }

        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            resolve(["error" : "Permission Needed!"]);
            self.showSimpleAlert();

        }

        else if (status == PHAuthorizationStatus.notDetermined) {

            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    resolve(self.getAlbumsFunc(type: type));
                }
                else {
                    resolve(["error" : "Permission Needed!"]);
                     self.showSimpleAlert();
                }
            })
        }

        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
             resolve(["error" : "Permission Needed!"]);
             self.showSimpleAlert();
        }
        
        
    }
    
    func getAlbumsFunc(type: String) -> [Any] {
        var subtypes :  [PHAssetCollectionSubtype] = []
        if( type == "Photos"){
            subtypes = [
                .smartAlbumFavorites,
                .smartAlbumPanoramas,
                .smartAlbumScreenshots,
                .smartAlbumSelfPortraits,
                .smartAlbumRecentlyAdded,
                .smartAlbumSelfPortraits,
                .smartAlbumUserLibrary,
                .smartAlbumBursts
            ]
        } else if( type == "Videos"){
            subtypes = [
                .smartAlbumVideos
            ]
        }
        
        var AlbumsArray : [Dictionary<String,Any>] = []
        var AlbumsTitlesArray : [String] = []
        DispatchQueue.global(qos: .background).sync() {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            // normal album fetchng
            [albums].forEach {
                $0.enumerateObjects { collection, index, stop in
                    let album = collection
                    if  album.estimatedAssetCount != NSNotFound {
                        let title = album.localizedTitle ?? "Album"
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
                    let title = collection.localizedTitle ?? "Album"
                    let count =  collection.photosCount as Int
                    let type = subtype.rawValue as Int
                    let data: [String: Any] = [
                        "title": title,
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
            print("1 2 4")
        }
        
        
        print("2 3 9")
        if(AlbumsTitlesArray.count > 0){
            let result =  [AlbumsArray, AlbumsTitlesArray] as [Any]
            return result
        } else {
            return []
        }
        
    }
    
    @objc
    public func fetchAssets(_ params: NSDictionary, resolve: @escaping RCTPromiseResolveBlock,
                            rejecter reject: @escaping RCTPromiseRejectBlock ) -> Void {
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            self.fetchAssetsFunc(params: params, returnCompletion: { (success) -> Void in
                resolve(success)
                })
        }
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            resolve(["error" : "Permission Needed!"]);
            self.showSimpleAlert();

        }
            
        else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.fetchAssetsFunc(params: params, returnCompletion: { (success) -> Void in
                        resolve(success)
                        })
                }
                else {
                    resolve(["error" : "Permission Needed!"]);
                    self.showSimpleAlert();
                }
            })
        }
            
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
             resolve(["error" : "Permission Needed!"]);
        }
        
    }
    
    
    func fetchAssetsFunc(params: NSDictionary, returnCompletion: @escaping ([String:Any]) -> () ){
        var AlbumName : String = "";
        var AlbumSubType : Int = 209;
        var AlbumType : Bool = false;
        var AssetType : String;
        var LastAssetUnix : Int? = nil;
        var FirstAssetUnix : Int? = nil;
        var First : Int? = nil
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
        if let first = params["first"]  as?  Int {
            First = first
            FirstAssetUnix = first
        }
        /////////##########################
        if let after = params["after"]  as?  Int {
            LastAssetUnix = after
        }
        /////////##########################
        if let count = params["count"]  as? Int  {
            Count = count
        } else {
            Count = 200
        }
        /////////##########################
        var AssetsArray : [Dictionary<String,Any>] = []
        let fetchOptions = PHFetchOptions()
        
        
        if(!AlbumType && !AlbumName.isEmpty){
            fetchOptions.predicate = NSPredicate(format: "title = %@", AlbumName)
        }
        DispatchQueue.global(qos: .background).async() {
            let fetchResult: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: (AlbumType ? .smartAlbum : .album), subtype: PHAssetCollectionSubtype(rawValue: AlbumSubType ) ?? .any, options:  fetchOptions)
            fetchResult.enumerateObjects({ (object: AnyObject!, count: Int, stop: UnsafeMutablePointer) in
                if object is PHAssetCollection {
                    let obj:PHAssetCollection = object as! PHAssetCollection
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    fetchOptions.fetchLimit = Count
                    if(First != nil) {
                        let startDate = NSDate(timeIntervalSince1970: Double(First! / 1000))
                        if(AssetType == "Videos"){
                            fetchOptions.predicate = NSPredicate(format: "(mediaType == %d) AND (creationDate > %@)", PHAssetMediaType.video.rawValue, startDate)
                        } else {
                            fetchOptions.predicate = NSPredicate(format: "(mediaType == %d) AND (creationDate > %@)", PHAssetMediaType.image.rawValue, startDate)
                        }
                    } else if(LastAssetUnix != nil) {
                        let startDate = NSDate(timeIntervalSince1970: Double(LastAssetUnix!  / 1000))
                        if(AssetType == "Videos"){
                            fetchOptions.predicate = NSPredicate(format: "(mediaType == %d) AND (creationDate < %@)", PHAssetMediaType.video.rawValue, startDate)
                        } else {
                            fetchOptions.predicate = NSPredicate(format: "(mediaType == %d) AND (creationDate < %@)", PHAssetMediaType.image.rawValue, startDate)
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
                    if(assets.count == 0 ) {
                        NoMore = true
                    } else {
                        NoMore = false
                        assets.enumerateObjects{(obj: AnyObject!,count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                            if obj is PHAsset{
                                var uri = String()
                                let asset = obj as! PHAsset
                                let assetLocalIdentifier = String(asset.localIdentifier)
                                let width = Int(asset.pixelWidth)
                                let height = Int(asset.pixelHeight)
                                let created =  Double(asset.creationDate!.timeIntervalSince1970)
                                let duration =  Double(asset.duration)
                                let latitude = asset.location?.coordinate.latitude
                                let longitude = asset.location?.coordinate.longitude
                                if(AssetType == "Photos"){
                                    uri = "ph://\(assetLocalIdentifier)"
                                } else if(AssetType == "Videos"){
                                    let originalName = PHAssetResource.assetResources(for: asset).first?.originalFilename ?? ""
                                    let mimeType =  String(originalName.suffix(3)).uppercased()
                                    let fullLink = asset.localIdentifier.components(separatedBy: "/").first!
                                    uri = "assets-library://asset/asset.\(mimeType)?id=\(String(describing: fullLink))&ext=\(mimeType)"
                                }
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
                                        ]
                                AssetsArray.append(newAlbum)
                                if((assets.count - 1) == count && assets.count > 0 ){
                                    LastAssetUnix = Int(asset.creationDate?.timeIntervalSince1970.rounded() ?? asset.modificationDate?.timeIntervalSince1970.rounded() ?? 0) * 1000
                                }
                                if(count == 0){
                                    FirstAssetUnix = Int(asset.creationDate?.timeIntervalSince1970.rounded() ?? asset.modificationDate?.timeIntervalSince1970.rounded() ?? 0) * 1000
                                }
                            }
                            
                        }
                        
                        if(assets.count < Count){
                            NoMore = true
                        }
                        if(assets.count == 0 && (First != nil)){
                            FirstAssetUnix = First!
                        }
                    }
                    
                }
            })
            let result : [String:Any] = ["noMore": NoMore, "firstAssetUnix": FirstAssetUnix as Any, "lastAssetUnix": LastAssetUnix as Any,  "assets":AssetsArray]
            print("result")
            print("result")
             print(result)
            returnCompletion(result)

        }
    }
    
    func showSimpleAlert() {
        let alert = UIAlertController(title: "Permission Request", message: "Please, Allow the access of Photos!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Setting", style: .default, handler: { action in
            RNCameraRollMedia.openAppSettings()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        //            present(alert, animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)

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
    
    func checkPermission(type: String){

        
    }
    
    static func openAppSettings() {
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    
}
