//
//  MediaAuthorizationManager.m
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/25.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import "FSMediaAuthorizationManager.h"

@implementation FSMediaAuthorizationManager : NSObject
+ (BOOL)hasCameraAuthorization {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusNotDetermined){
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)hasMicrophoneAuthorization {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusNotDetermined) {
        return NO;
    } else {
        return YES;
    }
}

+ (void)cameraAuthorization:(void (^)(BOOL granted))completionHandle {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        completionHandle(granted);
    }];
}

+ (void)microphoneAuthorization:(void (^)(BOOL granted))completionHandle {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        completionHandle(granted);
    }];
}

@end
