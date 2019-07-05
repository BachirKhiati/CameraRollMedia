//
//  RNCameraRollMediaBridge.m
//  RNCameraRollMedia
//
//  Created by Bachir Khiati on 23/04/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//
#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>


@interface RCT_EXTERN_MODULE(RNCameraRollMedia, NSObject)

RCT_EXTERN_METHOD(getBase64:(NSString *) linkUrl
                  resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getAlbums:(NSString *) type
                  resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(fetchAssets:
                  (NSDictionary *) params
                  resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )

@end
