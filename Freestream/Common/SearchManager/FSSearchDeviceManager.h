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

@property (nonatomic, assign) BOOL  isSearching;
@property (nonatomic, assign) BOOL  isExit;//退出搜索

- (void)beginSearchDeviceDuration:(NSTimeInterval)duration completionHandle:(searchResultBlock)completionHandle;

- (void)stopSearchDevice;
@end
