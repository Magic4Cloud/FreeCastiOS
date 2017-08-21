//
//  MCAuthorizationManager.h
//  Patrol
//
//  Created by hades on 2017/5/31.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface MCAuthorizationManager : NSObject
+ (BOOL)hasCameraAuthorization;

+ (BOOL)hasMicrophoneAuthorization;

+ (void)cameraAuthorization:(void (^)(BOOL granted))completionHandle;

+ (void)microphoneAuthorization:(void (^)(BOOL granted))completionHandle;
@end
