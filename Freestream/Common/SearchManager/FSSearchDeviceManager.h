//
//  FSSearchDeviceManager.h
//  Freestream
//
//  Created by Frank Li on 2017/11/20.
//  Copyright © 2017年 Cloud4Magic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scanner.h"

typedef void(^searchResultBlock)(Scanner * resultInfo);

@interface FSSearchDeviceManager : NSObject

+ (instancetype)shareInstance;

- (void)beginSearchDeviceDuration:(NSTimeInterval)duration completionHandle:(searchResultBlock)completionHandle;
@end
