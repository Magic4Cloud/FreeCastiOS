//
//  FSDeviceConfigureInfo.h
//  Freestream
//
//  Created by Frank Li on 2017/11/28.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <M4CoreFoundation/M4CoreFoundation.h>

typedef NS_ENUM(NSInteger, FSResolution) {
    FSResolution480P  = 0,
    FSResolution720P  = 1,
    FSResolution1080P = 2,
};

@interface FSDeviceConfigureInfo : ModelBaseClass

@end
