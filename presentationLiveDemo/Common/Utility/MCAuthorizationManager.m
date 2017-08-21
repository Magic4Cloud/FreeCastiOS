//
//  MCAuthorizationManager.m
//  Patrol
//
//  Created by hades on 2017/5/31.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import "MCAuthorizationManager.h"
#import <CoreLocation/CoreLocation.h>

@implementation MCAuthorizationManager
+ (BOOL)hasCameraAuthorization
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusNotDetermined){
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)hasMicrophoneAuthorization
{
    NSString *mediaType = AVMediaTypeAudio;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusNotDetermined){
        return NO;
    } else {
        return YES;
    }
}

+ (void)cameraAuthorization:(void (^)(BOOL granted))completionHandle
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        completionHandle(granted);

    }];
}

+ (void)microphoneAuthorization:(void (^)(BOOL granted))completionHandle
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        completionHandle(granted);
    }];
}
@end
