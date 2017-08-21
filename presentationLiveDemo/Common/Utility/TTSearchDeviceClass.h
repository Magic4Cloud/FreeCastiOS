//
//  TTSearchDeviceClass.h
//  presentationLiveDemo
//
//  Created by tc on 7/29/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "Scanner.h"
#import <Foundation/Foundation.h>

typedef void(^searchResultBlock)(Scanner * resultinfo);

/**
 搜索设备 工具类
 */
@interface TTSearchDeviceClass : NSObject

+ (instancetype)shareInstance;

- (void)searDeviceWithSecond:(NSTimeInterval )seconds CompletionHandler:(searchResultBlock )completionHandler;

@end
