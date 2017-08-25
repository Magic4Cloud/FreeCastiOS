//
//  MediaAuthorizationManager.h
//  presentationLiveDemo
//
//  Created by 李林峰 on 2017/8/25.
//  Copyright © 2017年 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface FSMediaAuthorizationManager : NSObject
+ (BOOL)hasCameraAuthorization;
+ (BOOL)hasMicrophoneAuthorization;

+ (void)cameraAuthorization:(void (^)(BOOL granted))completionHandle;
+ (void)microphoneAuthorization:(void (^)(BOOL granted))completionHandle;

@end
